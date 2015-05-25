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
    @x, @y = verify_inside *new_coordinates
  end

  def new_coordinates direction=@a
    @a = direction % 360
    rads = @a * Math::PI / 180.0
    [@x + @speed * Math.cos(rads), @y + @speed * Math.sin(rads)]
  end

  def verify_inside new_x, new_y
    if x_outbound?(new_x) && y_outbound?(new_y)
      new_coordinates @a - 180
    elsif x_outbound?(new_x)
      new_coordinates 180 - @a
    elsif y_outbound?(new_y)
      new_coordinates 360 - @a
    else
      [new_x, new_y]
    end
  end

  def x_outbound? a
    a > @board.width  || a < 0
  end

  def y_outbound? b
    b > @board.height || b < 0
  end

  def draw
    super(@x - @wide/2, @y - @high/2, 1)
  end
end

class Human < Being
  attr_reader :infected

  OBLIVI = 2
  FREAKY = 4
  VISUAL_RADIUS = 25

  def initialize board
    super board, 'lib/human.png'
    @infected = false
  end

  def update
    if (danger = closest_predator)
      @a = Gosu.angle(danger.x, danger.y, x, y) - 90
      @speed = Human::FREAKY
    else
      @speed = Human::OBLIVI
    end
    super
  end

  def bitten
    @infected = true
  end

  def turn_undead
    Zombi.new(@board, {x:x, y:y, a:a})
  end

  def closest_predator
    predator = @board.zombis.sort_by{ |z| Gosu.distance(x, y, z.x, z.y) }.first
    distance = Gosu.distance(x, y, predator.x, predator.y)
    distance < VISUAL_RADIUS ? predator : nil
  end
end

class Zombi < Being
  OBLIVI = 1
  FREAKY = 3
  VISUAL_RADIUS = 50
  INFECT_DIST = 8

  def initialize board, opts = {}
    super board, 'lib/zombi.png', opts
  end

  def update
    if (target = closest_prey)
      @a = Gosu.angle(target.x, target.y, x, y) + 90
      @speed = Zombi::FREAKY
    else
      @speed = Zombi::OBLIVI
    end
    super
  end

  def closest_prey
    sorted = @board.humans.sort_by{ |h| Gosu.distance(x, y, h.x, h.y) }
    guy = sorted.shift
    while guy && Gosu.distance(x, y, guy.x, guy.y) <= INFECT_DIST do
      guy.bitten
      guy = sorted.shift
    end
    guy
  end
end

class GameOfDead < Gosu::Window
  attr_reader :humans, :zombis

  DEFAULT_SETUP = { z: 1, h: 1 }
  SCREEN_WIDE = 500
  SCREEN_HIGH = 600

  def initialize opts={}
    super SCREEN_WIDE, SCREEN_HIGH, false
    self.caption = "Zombies!!"
    opts = DEFAULT_SETUP.merge opts
    @humans = Array.new(opts[:h]){ Human.new(self) }
    @zombis = Array.new(opts[:z]) { Zombi.new(self) }
    @font = Gosu::Font.new(self, 'system', 30)
  end

  def update
    @humans.each(&:update)
    @zombis.each(&:update)

    bitten, @humans = @humans.partition(&:infected)
    @zombis += bitten.map &:turn_undead
  end

  def draw
    @humans.each(&:draw)
    @zombis.each(&:draw)
    @font.draw(@humans.count.to_s, 20, 20, 2)
    @font.draw(@zombis.count.to_s, SCREEN_WIDE - 60, 20, 2, 1, 1, color = Gosu::Color::RED)
  end
end

