# Class encapsulating a API command to be executed on the device
class Mikrotik::Command
  include Events

  # Fired when the command completes
  # @yield [replies] 
  # @yieldparam [false, Array<Mikrotik::Protocol::Sentence>] replies All replies received from the device for this command
  has_events :done

  # Fired on each reply received from the command
  # @yield [reply]
  # @yieldparam [false, Mikrotik::Protocol::Sentence] reply The sentence received in reply
  has_event :reply

  # Fired when an error response is received from the command
  # @yield [error_message]
  # @yieldparam [false, String] error_message Error description
  has_event :trap

  # @return [Array<Mikrotik::Protocol::Sentence>] All sentences sent in response to this command so far
  attr_reader :replies

  # @return [Hash] All option name/value pairs set on the command
  attr_reader :options

  # @return [String] Path to the command
  attr_reader :command

  # Creates a new command object
  # @param [Array<String, Symbol>] path Path of the API command
  def initialize(*command_path)    
    @command = command_path.collect { |part| "#{part}".gsub('_', '-') }.join('/')
    @command = "/#{@command}" unless @command.start_with?('/')
    @options = {}
    @replies = []
  end
  
  # Adds property names and values to the command
  # @param [Hash] options
  def with(options = {})
    options.each_pair do |option, value|
      @options["=#{option}"] = value
    end
    self
  end
  
  # Adds querying conditions to the command
  # @param [Hash] conditions
  def where(conditions = {})
    conditions.each_pair do |property, value|
      @options["?#{property}"] = value
    end
    self
  end  
  
  # Specifies what properties should be returned by the device in response to this command
  # 
  # @param [Array<String, Symbol>] properties List of the names of properties to request in response 
  # @return [self]
  def returning(*properties)
    @options['=.proplist'] ||= []
    properties.each do |property|
      @options['=.proplist'] << "#{property}"
    end
    self
  end

  # Encodes the command for transmission
  # @return [String] Command encoded as an API sentence in binary string format
  def encoded    
    @command.to_mikrotik_word + @options.collect { |key, value|
      case value.class.name
      when 'Array'        
        [key, value.collect { |item| "#{item}" }.join(',')].join '='        
      else
        "#{key}=#{value}"
      end
    }.map { |option| option.to_mikrotik_word }.join + 0x00.chr
  end

end
