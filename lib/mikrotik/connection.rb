# Contains logic for sending and receiving data to and from the device
module Mikrotik::Connection

  # @private
  def connection_completed
    @commands = {}
    @sentences = []
    @parser = Mikrotik::Protocol::Parser.new
    @parser.on_sentence do |sentence|
      handle_reply(sentence)
    end
    login
  end

  # Disconnects from the device
  def disconnect
    Mikrotik.debug [:connection, :disconnect]
    @closing = true
    close_connection(true)
  end

  # @private
  def send(command)
    command.options['.tag'] = @next_tag
    Mikrotik.debug [:connection, :send, command.encoded]
    @commands[@next_tag] = command
    send_data(command.encoded)
    @next_tag = @next_tag + 1
    command
  end

  # @private
  def receive_data(data)
    Mikrotik.debug [:connection, :receive, data.size, data]
    @parser << data
  end
  
  # @private
  def unbind
    raise Mikrotik::Errors::ConnectionDropped unless @closing
  end

  private

  # @private
  def handle_reply(reply)
    unless reply.tagged? then
      Mikrotik.debug [:connection, :handle_reply, :untagged]
      return
    end
    Mikrotik.debug [:connection, :handle_reply, :tagged, reply.tag]
    # Retreive the command this reply is intended for by its tag
    command = @commands[reply.tag]
    command.replies << reply unless reply.completely_done?
    # Catch those nasty errors
    if reply.trap? then
      Mikrotik.debug [:command, :on_trap]
      # If there's an error handler, fire it...
      if command.has_event_handler?(:on_trap) then
        command.on_trap(reply.param(:message))
      else
        # ...if not, raise an error
        raise Mikrotik::Errors::UnhandledTrap, reply.result(:message) || "Unknown error"
      end
      return
    end
    # Still fire on_reply events for done messages that contain more data
    unless reply.completely_done? then
      Mikrotik.debug [:command, :on_reply]
      command.on_reply(reply)
    end    
    # If this was the last reply, fire the on_done event handler
    if reply.done? then
      Mikrotik.debug [:command, :on_done, reply.tag]
      command.on_done(command.replies)
      # As the command has completed remove it from the list of active commands
      @commands.delete(reply.tag)
      Mikrotik.debug [:client, :commands, :size, @commands.size]
    end
    # If there are no more active commands fire the event
    on_pending_complete(self) if @commands.empty?
  end

end
