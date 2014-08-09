require 'socket'                # Get sockets from stdlib
require 'json'

client_id = 1
clients = {}

server = TCPServer.open(2000)   # Socket to listen on port 2000
loop {                          # Servers run forever
  Thread.start(server.accept) do |client|
    id = client_id
    client_id += 1
    client.puts id
    this = JSON.parse(client.gets)
    clients[id] = this
    alive = true

    while alive
      msg = client.gets
      if msg == 'bye'
        alive = false
      else
        packet = JSON.parse msg
        this.merge! packet
        puts "#{id}: getting #{packet}"

        client.puts clients.size
        clients.each do |i,c|
          client.puts JSON.generate(c.merge(id: i))
        end
      end
    end


    client.close                # Disconnect from the client
  end
}
