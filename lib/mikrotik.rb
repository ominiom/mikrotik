require 'eventmachine'
require 'digest/md5'

# TODO : Allow underscores to be used instead of dashes in command paths and properties - e.g. in dhcp-server and mac-address

module Mikrotik

  module Protocol; end;
  
  # @return [Boolean] Whether debugging prints are enabled or not
  def self.debugging
    false
  end

  # Prints message if debugging is enabled
  # @param [Array<String>] message Parts of the message 
  def self.debug(message)
    puts message.join(' ') if debugging
  end

  # Shorthand for Mikrotik::Client.connect
  # @return [Mikrotik::Client]
  def self.connect(*args)
    Client.connect(*args)
  end

end

# Add ourselves to the load path
$: << File.dirname(__FILE__)

# Load up the code
require 'extensions/string'
require 'extensions/events'
require 'mikrotik/errors'
require 'mikrotik/client'
require 'mikrotik/connection'
require 'mikrotik/command'
require 'mikrotik/utilities'
require 'mikrotik/protocol/parser'
require 'mikrotik/protocol/sentence'
