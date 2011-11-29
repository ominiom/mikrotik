    client.execute(client.command(:system, :resource, :print).returning(:uptime).on_reply do |reply|
      puts "System uptime is #{reply.result :uptime}"
    end)
    
    client.on_pending_complete do |client|
      puts "All commands completed, closing session..."
      client.disconnect
    end