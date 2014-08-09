require 'gosu'
require 'socket'      # Sockets are in standard library
require 'json'

HOSTNAME = ARGV[0] || 'localhost'
PORT = ARGV[1] || 2000

SPEED = 0.1

class NetGame < Gosu::Window
  def initialize width=640, height=480, fullscreen=false
    super

    puts "Connecting to #{HOSTNAME}:#{PORT}"
    @me = {x: Gosu::random(0.0,640.0), y: Gosu::random(0.0,480.0),
           vx: 0.0, vy: 0.0}
    @others = {}
    @img = Gosu::Image.from_text self, "X", "monospace", 30
    @time = Gosu::milliseconds

    @running = true
    @net_thread = Thread.start(TCPSocket.open(HOSTNAME, PORT)) do |server|
      @id = server.gets.to_i
      puts "I am number #{@id}"
      server.puts JSON.generate(@me)

      do_network server while @running

      server.puts 'bye'
      server.close
    end
  end

  def do_network server
    server.puts JSON.generate(@me)

    count = server.gets.to_i
    count.times do
      packet = JSON.parse(server.gets)
      (@others[packet['id']] ||= {}).merge! packet
    end
  end

  def button_down id
    close if id == Gosu::KbEscape
  end

  def update
    newtime = Gosu::milliseconds
    @delta = newtime - @time
    @time = newtime

    vx, vy = 0.0, 0.0
    vx += 1 if button_down? Gosu::KbRight
    vy += 1 if button_down? Gosu::KbDown
    vx -= 1 if button_down? Gosu::KbLeft
    vy -= 1 if button_down? Gosu::KbUp

    @me[:vx], @me[:vy] = vx*SPEED, vy*SPEED
    @me[:x] += @me[:vx] * @delta
    @me[:y] += @me[:vy] * @delta

    @others.each do |i,o|
      o['x'] += o['vx'] * @delta
      o['y'] += o['vy'] * @delta
    end
  end

  def draw
    @img.draw_rot @me[:x], @me[:y], 1, 0.0
    @others.each do |i,c|
      @img.draw_rot c['x'], c['y'], 1, 0.0 unless i == @id
    end
  end

  def destroy
    puts "Bye Bye..."
    @running = false
    @net_thread.join
  end
end

game = NetGame.new
game.show

game.destroy
