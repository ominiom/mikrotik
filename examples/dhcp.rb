client.execute(client.command(:ip, :dhcp_server, :lease, :getall).on_done do |replies|
  puts replies.collect { |reply| "IP '#{reply.result :address}' assigned to MAC #{reply.result('mac-address')}" }
end)

client.on_pending_complete do |client|
  puts "All commands completed, closing session..."
  client.disconnect
end