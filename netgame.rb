require 'gosu'
require 'socket'      # Sockets are in standard library
require 'json'

HOSTNAME = ARGV[0] || 'localhost'
PORT = ARGV[1] || 2000

class NetGame < Gosu::Window
  def initialize width=640, height=480, fullscreen=false
    super

    puts "Connecting to #{HOSTNAME}:#{PORT}"
    @socket = TCPSocket.open(HOSTNAME, PORT)
    @id = @socket.gets.to_i
    @me = {x: Gosu::random(0.0,640.0), y: Gosu::random(0.0,480.0)}
    @others = {}
    @socket.puts JSON.generate(@me)
    @img = Gosu::Image.from_text self, "X", "monospace", 30
  end

  def button_down id
    case id
    when Gosu::KbUp
      @me[:y] -= 10
    when Gosu::KbDown
      @me[:y] += 10
    when Gosu::KbLeft
      @me[:x] -= 10
    when Gosu::KbRight
      @me[:x] += 10
    end
  end

  def update
    @socket.puts JSON.generate(@me)

    count = @socket.gets.to_i
    count.times do
      packet = JSON.parse(@socket.gets)
      @others[packet['id']] = packet
    end
  end

  def draw
    @img.draw_rot @me[:x], @me[:y], 1, 0.0
    @others.each do |i,c|
      @img.draw_rot c['x'], c['y'], 1, 0.0 unless i == @id
    end
  end

  def destroy
    @socket.puts "bye"
    @socket.close
  end
end

game = NetGame.new.show

game.destroy
