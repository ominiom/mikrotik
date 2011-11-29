# Add lib to load path
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mikrotik'

EventMachine.run do
  client = Mikrotik.connect :host => "192.168.1.254", :port => 8728, :username => "admin", :password => "debUwu8A"
  
  puts "Connecting..."
  
  client.on_login_success do |client|
    puts "Login successful"
    
    # Run a command every 5 seconds
    EM.add_timer(EM::PeriodicTimer.new(5) do      
      client.execute(client.command(:interface, :print).returning(:name, :bytes).where(:name => :ether1).on_reply do |reply|
        # Sum up the in and out counts
        bytes = reply.result(:bytes).split('/').map(&:to_i).inject(0) { |i, n| i = i + n }
        # Format nicely
        total = sprintf "%.2f", (bytes / 1024.0 / 1024.0)
        # Output
        puts "Interface '#{reply.result :name}' has transferred #{total} MB"      
      end)
    end)
    
  end
  
  trap 'SIGINT' do
    client.disconnect
    puts "Disconnected from #{client.options[:host]}"
    exit
  end
  
end
