# Responsible for extracting replies from API sentence data
class Mikrotik::Protocol::Parser
  include Events

  # Fired when the parser extracts a complete API sentence
  # @yield [Mikrotik::Protocol::Sentence] sentence
  has_event :sentence

  def initialize
    @data = ''
    @data.force_encoding(Encoding::BINARY) if RUBY_VERSION > '1.9'
    reset!
  end

  # Discards the sentence currently being parsed
  def reset!
    @sentence = Mikrotik::Protocol::Sentence.new
  end

  # Adds data to the parser buffer and runs the parser
  def <<(data)
    @data << data
    success = true
    success = get_sentence while success
  end

  PAIR = /^(.+)=(.+)$/

  # Indentifies the size of the length field in bits
  # @return boolean, integer
  def get_length_size
    return false if @data.empty?

    # High bits used for length type
    # Low bits used as first bits of length
    
    # 0xxxxxxx = 7  bit length
    # 10xxxxxx = 14 bit length
    # 110xxxxx = 21 bit length
    # 1110xxxx = 28 bit length
    # 11110000 = 32 bit length follows

    t = @data.unpack('C').first

    return  7 if t &  0b10000000 == 0
    return 14 if t &  0b01000000 == 0
    return 21 if t &  0b00100000 == 0
    return 28 if t &  0b00010000 == 0
    return 32 if t == 0b11110000

    raise ArgumentError, "Invalid length type encoding"
  end

  def get_length
    size = get_length_size

    return false unless size

    need = bytes(size + 1)
    return false unless @data.size >= need

    length = nil
    field = @data[0, need].unpack('C*')

    case size
      when 7
        length = field[0] & 0x7f
      when 14
        length = ((field[0] & 0x3f) <<  8) | field[1]
      when 21
        length = ((field[0] & 0x1f) << 16) | field[1] <<  8 | field[2]
      when 28
        length = ((field[0] & 0x0f) << 24) | field[1] << 16 | field[2] << 8 | field[3]
      when 32
        length = field[1..4].pack('C4').unpack('N').first
    end

    if length
      return length
    else
      raise ArgumentError, "Invalid word length"
    end
  end

  def get_word
    return false if @data.empty?
    length_size = bytes(get_length_size + 1)
    length      = get_length
    
    total_size  = length_size + length
    
    if length && @data.size >= total_size
      @data.slice!(0, length_size)
      word = @data.slice!(0, length)
      Mikrotik.debug [:parser, :got_word, word]
      return word
    end

    return false
  end

  def get_sentence
    while word = get_word 
      if word.empty?
        Mikrotik.debug [:parser, :got_sentence, @sentence]
        on_sentence(@sentence)
        reset!
        return true
      else
        if word =~ PAIR
          key, value = word.scan(PAIR).flatten
          @sentence[key] = value
        else
          @sentence[word] = nil
        end
      end
    end

    return false
  end

  def bytes(bits)
    (bits / 8.0).ceil
  end

end
