module Mikrotik::Errors
  
  # Raised when an error response is received to a 
  # command with no on_trap event handler
  class UnhandledTrap < RuntimeError; end;
  
  # Raised when the connection to the device
  # disconnects unexpectedly
  class ConnectionDropped < RuntimeError; end;
  
end