require 'gosu'

class Being < Gosu::Image
  attr_reader :x, :y, :a
  VELO = 4

  def initialize board, file, opts={}
    super board, file, false
    @board = board
    @x = opts[:x] || rand(0...@board.width)
    @y = opts[:y] || rand(0...@board.height)
    @a = opts[:a] || rand(0...360)
    @wide = 8
    @high = 8
  end

  def compute_speed
    @a = @a % 360
    rads = @a * Math::PI / 180.0
    @velo_x = VELO * Math.cos(rads)
    @velo_y = VELO * Math.sin(rads)
  end

  def update
    compute_speed
    new_x = @x + @velo_x
    new_y = @y + @velo_y

    @a = 180-@a if new_x + @wide/2 > @board.width  || new_x - @wide/2 < 0
    @a = 360-@a if new_y + @high/2 > @board.height || new_y - @high/2 < 0

    @x += @velo_x
    @y += @velo_y
  end

  def draw
    super(@x - @wide/2, @y - @high/2, 1)
  end

  def position
    [@x, @y]
  end
end

class Human < Being
  CONTACT = 8

  def initialize board
    super board, 'human.png'
  end

  def mutate
    # oh noooooo!
  end
end

class Zombi < Being
  def initialize board, opts = {}
    super board, 'zombi.png', opts
  end
end

class WhackARuby < Gosu::Window
  def initialize
    super 200, 200, false
    self.caption = "Game of Undead"
    @humans = Array.new(20){ Human.new(self) }
    @zombis = Array.new(1) { Zombi.new(self) }
 end

  def update
    @humans.each(&:update)
    @zombis.each(&:update)

    new_zombis, survivors = @humans.partition do |h|
      @zombis.find{|z| Gosu.distance(*h.position, *z.position) < Human::CONTACT}
    end
    @humans = survivors
    @zombis += new_zombis.map { |z| Zombi.new(self, {x:z.x, y:z.y, a:z.a}) }
  end

  def draw
    c = Gosu::Color::NONE
    #draw_quad(0,0,c,800,0,c,800,600,c,0,600,c)
    @humans.each(&:draw)
    @zombis.each(&:draw)
  end
end

window = WhackARuby.new
window.show
