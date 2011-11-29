class Mikrotik::Protocol::Sentence < Hash

  # Sentence only contains a zero length word
  # @return [Boolean]
  def empty?
    super || false
  end

  # Is this the last reply for a command?
  # @return [Boolean]
  def done?
    key?('!done')
  end
  
  # Is this reply only informing that a command is done, and contains no other data?
  # @return [Boolean]
  def completely_done?
    size == 2 and done? and tagged?
  end

  # Is this informing of an error that should be trapped?
  # @return [Boolean]
  def trap?
    key?('!trap')
  end

  # Does the reply have a command tag associated with it?
  # @return [Boolean]
  def tagged?
    key?('.tag')
  end

  # Retreives the reply's command tag
  #
  # @return [nil] If the command is not tagged
  # @return [Integer] tag If the command is tagged
  def tag
    tagged? ? self['.tag'] : nil
  end

  # Fetches a returned property
  # @return value
  def result(key)
    self["=#{key}"]
  end

  # Fetches any returned value in this reply, converting it to a ruby type first
  def [](key)
    return nil unless key?(key)
    case key
    when '.tag'
      fetch(key).to_i
    else
      value = fetch(key)
      #case value
      #when /\d+/
      #  value.to_i
      #when /\d+.\d+/
      #  value.to_f
      #when 'true'
      #  true
      #when 'false'
      #  false
      #else
      #  value
      #end
    end
  end

end
