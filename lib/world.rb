require 'gosu'

class Being < Gosu::Image
  attr_reader :x, :y, :a

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
    { x: @speed * Math.cos(rads), y: @speed * Math.sin(rads) }
  end
end

class Human < Being
  def initialize board
    @speed = 4
    super board, 'human.png'
  end

  def turn_undead
    Zombi.new(@board, {x:x, y:y, a:a})
  end
end

class Zombi < Being
  VISUAL_RADIUS = 20

  def initialize board, opts = {}
    @speed = 2
    super board, 'zombi.png', opts
  end

  def update
    target = closest_prey
    rads = Math.atan2((target.y - y), (target.x - x))
    @a = (rads * 180 / Math::PI) % 360
    super
  end

  def closest_prey
    @board.humans
          .group_by { |h| Gosu.distance(x, y, h.x, h.y) }
          .min_by{|k,v| k}[1].first
  end
end

class GameOfDead < Gosu::Window
  SCREEN_WIDE = 600
  SCREEN_HIGH = 700
  INFECT_DIST = 8

  attr_reader :humans, :zombis

  def initialize
    super SCREEN_WIDE, SCREEN_HIGH, false
    self.caption = "Contagion!!"
    @humans = Array.new(200){ Human.new(self) }
    @zombis = Array.new(1) { Zombi.new(self) }
    @go_on = true
  end

  def update
    if @go_on
      tick     # everybody runs!
      tock     # some people were born to turn (into zombies)
    end
  end

  def tick
    @humans.each(&:update)
    @zombis.each(&:update)
  end

  def tock
    new_zombis, survivors = @humans.partition do |h|
      @zombis.find{ |z| Gosu.distance(h.x, h.y, z.x, z.y) < INFECT_DIST }
    end

    @humans = survivors
    @zombis += new_zombis.map(&:turn_undead)

    @go_on = false if @humans.none?
  end

  def draw
    @humans.each(&:draw)
    @zombis.each(&:draw)
  end
end

window = GameOfDead.new
window.show
