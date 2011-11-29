# Responsible for extracting replies from API sentence data
class Mikrotik::Protocol::Parser
  include Events

  # Fired when the parser extracts a complete API sentence
  # @yield [Mikrotik::Protocol::Sentence] sentence
  has_event :sentence

  def initialize
    @data = ""
    @data.force_encoding(Encoding::BINARY) if RUBY_VERSION >= '1.9.0'
    @sentence = Mikrotik::Protocol::Sentence.new
  end

  # Adds data to the parser buffer and runs the parser
  def <<(data)
    @data << data
    parse
  end

  private

  def parse
    Mikrotik.debug [:parser, :running]
    Mikrotik.debug [:parser, :buffer, @data.size, @data]
    success, word = get_word
    return unless success
    Mikrotik.debug [:parser, :word, word]
    if word.empty? then
      Mikrotik.debug [:parser, :on_sentence, @sentence]
      on_sentence(@sentence)
      @sentence = Mikrotik::Protocol::Sentence.new
    else
      m = /^(.+)=(.+)$/.match(word)
      unless m.nil?
        @sentence[m[1]] = m[2]
      else
        @sentence[word] = nil
      end
    end
    parse if @data.size > 0
  end

  def get_word
 
     unless @data.length > 0
       return false, nil   ## Not enough data to parse
     end
 
     ## The first byte tells us how the word length is encoded:
     len = 0
     len_byte = cbyte(@data, 0)
     if len_byte & 0x80 == 0
       len = len_byte & 0x7f
       if len == 0 then
         @data[0, 1] = ''
         return true, ''
       end
       i = 1
     elsif len_byte & 0x40 == 0
       unless @data.length > 0x81
         return false, nil   ## Not enough data to parse
       end
       len = ((len_byte & 0x3f) << 8) | cbyte(@data, 1)
       i = 2
     elsif len_byte & 0x20 == 0
       unless @data.length > 0x4002
         return false, nil   ## Not enough data to parse
       end
       len = ((len_byte & 0x1f) << 16) | (cbyte(@data, 1) << 8) | cbyte(@data, 2)
       i = 3
     elsif len_byte & 0x10 == 0
       unless @data.length > 0x200003
         return false, nil   ## Not enough data to parse
       end
       len = ((len_byte & 0x0f) << 24) | (cbyte(@data, 1) << 16) | (cbyte(@data, 2) << 8) | cbyte(@data, 3)
       i = 4
     elsif len_byte == 0xf0
       len = (cbyte(@data, 1) << 24) | (cbyte(@data, 2) << 16) | (cbyte(@data, 3) << 8) | cbyte(@data, 4)
       i = 5
     else
       ## This will also catch reserved control words where the first byte is >= 0xf8
       raise ArgumentError, "String length encoding is invalid"
     end
     if @data.length - i < len
       return false, nil   ## Not enough data to parse
     end
     success, data = true, @data[i, len]
     @data[0, i + len] = ""
     return success, data
   end

   def cbyte(str, offset)
     return str[offset].ord
   end

end
