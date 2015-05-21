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

  def update
    velo = compute_speed
    new_x = @x + velo[:x]
    new_y = @y + velo[:y]

    @a = 180-@a if new_x + @wide/2 > @board.width  || new_x - @wide/2 < 0
    @a = 360-@a if new_y + @high/2 > @board.height || new_y - @high/2 < 0

    @x += velo[:x]
    @y += velo[:y]
  end

  def draw
    super(@x - @wide/2, @y - @high/2, 1)
  end

  def compute_speed
    @a = @a % 360
    rads = @a * Math::PI / 180.0
    { x: VELO * Math.cos(rads), y: VELO * Math.sin(rads) }
  end

  def position
    [@x, @y]
  end
end

class Human < Being
  def initialize board
    super board, 'human.png'
  end
end

class Zombi < Being
  def initialize board, opts = {}
    super board, 'zombi.png', opts
  end

  def something
  end
end

class GameOfDead < Gosu::Window
  SCREEN_WIDE = 600
  SCREEN_HIGH = 700
  SPREAD_RADIUS = 8

  def initialize
    super SCREEN_WIDE, SCREEN_HIGH, false
    self.caption = "Contagion!!"
    @humans = Array.new(5){ Human.new(self) }
    @zombis = Array.new(1) { Zombi.new(self) }
    @go_on = true
  end

  def update
    if @go_on
      tick     # everybody runs!
      tock     # some people become zombies
    end
  end

  def tick
    @humans.each(&:update)
    @zombis.each(&:update)
  end

  def tock
    new_zombis, survivors = @humans.partition do |h|
      @zombis.find{|z| Gosu.distance(*h.position, *z.position) < SPREAD_RADIUS}
    end

    @humans = survivors
    @zombis += new_zombis.map { |z| Zombi.new(self, {x:z.x, y:z.y, a:z.a}) }

    @go_on = false if @humans.none?
  end

  def draw
    @humans.each(&:draw)
    @zombis.each(&:draw)
  end
end

window = GameOfDead.new
window.show
