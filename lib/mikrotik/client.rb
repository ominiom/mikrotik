# Contains all methods for interacting with a device
# such as logging in and executing commands
#
# @see Mikrotik::Client.connect
module Mikrotik::Client
  include Events

  # Fired when the API login command has returned successfully.
  # After this event has fired it is safe to start sending commands
  has_event :login_success
  
  # Fired when the API login command returns an error -
  # for example in cases where the credentials were wrong
  has_event :login_failure
  
  # Fired when the queue of commands awaiting completion
  # becomes empty
  has_event :pending_complete

  # @return [Hash] Options used for the connection
  # @see Client#connect
  attr_reader :options

  # Connects to a RouterOS device. Required options are +:host+
  # and +:password+ - +:username+ and +:port+ default
  # to +admin+ and +8728+ respectively
  #
  # @param [Hash] options +:test+ Hash of connection options
  # @option options [String] :host Device's IP address
  # @option options [Integer] :port (8728) Port of the API service on the device
  # @option options [String] :username ('admin') API username to authenticate with
  # @option options [String] :password Password for the given username
  # @return [Client]
  # @raise [ArgumentError] If not all required options are given
  # @example Connection with minimum options set
  #   Mikrotik::Client.connect({
  #     :host => '192.168.1.1',  
  #     :password => 'topsecret'
  #   })
  # @example Connection with all options set to override defaults
  #   Mikrotik::Client.connect({
  #     :host => '10.200.0.21',
  #     :port => 3450,
  #     :username => 'apiuser',
  #     :password => 'topsecret'
  #   })
  # 
  def self.connect(options = { :username => 'admin', :port => 8728 })
    defaults = { :username => 'admin', :port => 8728 }
    options = defaults.merge(options)
    # Check required options have been given
    all_required_options = !([:host, :port, :username, :password].map { |option|
      options.key?(option) && !options[option].nil?
    }.include?(false))
    raise ArgumentError, "Options for host and password must be given" unless all_required_options

    c = EM.connect options[:host], options[:port], self, options
    c.pending_connect_timeout = 10.0
    c
  end
  
  # Logs in to the device. This is called automatically when
  # the TCP connection succeeds. To be sure the device is ready
  # to +execute+ commands before sending any register an event handler
  # on +on_login_success+ and send commands from there
  def login
    execute command(:login).on_reply { |reply|

      challenge = Mikrotik::Utilities.hex_to_bin(reply.result :ret) 
      response = "00" + Digest::MD5.hexdigest(0.chr + @options[:password] + challenge)

      execute command(:login).with(
        :name => @options[:username],
        :response => response
      ).on_done { |replies|
        Mikrotik.debug [:client, :on_login_success]
        @logged_in = true
        on_login_success(self)
      }.on_trap { |trap|
        Mikrotik.debug [:client, :on_login_failure]
        if has_event_handler? :on_login_failure then
          on_login_failure(self)
        else
          raise Mikrotik::Errors::UnhandledTrap, 'Login failed'
        end
      }

    }
  end

  # Sends a command to the device
  # @param command [Mikrotik::Command] The command to be executed
  # @return [Mikrotik::Command] The command executed
  def execute(command)
    send command
  end

  # @return [Boolean] Status of the session login
  def logged_in?
    @logged_in
  end
  
  # Shortcut for creating a Mikrotik::Command
  # @return Mikrotik::Command
  # @see Mikrotik::Command
  def command(*path)
    Mikrotik::Command.new(*path)
  end

  def inspect
    "#<#{self.class.name}:0x#{self.object_id} host=#{@options[:host]}>"
  end

  def initialize(opts = {})
    @closing = false
    @logged_in = false
    @options = opts
    @events = {}
    @buffer = ""
    @next_tag = 1
    extend Mikrotik::Connection 
  end

end
