require 'socket'                # Get sockets from stdlib
require 'json'

client_id = 1
clients = {}

PORT = ARGV[0] || 2000

server = TCPServer.open(PORT)   # Socket to listen on port 2000
puts "Server running on #{PORT}"
loop {                          # Servers run forever
  Thread.start(server.accept) do |client|
    id = client_id
    puts "Client #{id} connected."
    client_id += 1
    client.puts id
    this = JSON.parse(client.gets.chomp)
    puts "Client #{id} is #{this}"
    clients[id] = this
    alive = true

    while alive
      msg = client.gets.chomp
      if msg == 'bye'
        clients.delete id
        alive = false
        puts "Client #{id} signing off"
      else
        packet = JSON.parse msg
        this.merge! packet

        client.puts clients.size-1
        clients.each do |i,c|
          client.puts JSON.generate(c.merge(id: i)) unless i == id
        end
      end
    end

    client.close                # Disconnect from the client
    puts "Client #{id} disconnected"
  end
}
