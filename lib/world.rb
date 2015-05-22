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
    new_direction = nil
    new_direction = 180 - @a if new_x + @wide/2 >= @board.width  || new_x - @wide/2 < 0
    new_direction = 360 - @a if new_y + @high/2 >= @board.height || new_y - @high/2 < 0
    return new_coordinates(new_direction) if new_direction
    [new_x, new_y]
  end

  def draw
    super(@x - @wide/2, @y - @high/2, 1)
  end
end

class Human < Being
  OBLIVI = 2
  FREAKY = 4
  VISUAL_RADIUS = 25

  def initialize board
    super board, 'lib/human.png'
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

  def turn_undead
    Zombi.new(@board, {x:x, y:y, a:a})
  end

  def closest_predator
    distance, predators = @board.zombis
                                .group_by{ |z| Gosu.distance(x, y, z.x, z.y) }
                                .min_by{ |distance, zombie_group| distance }
    distance < VISUAL_RADIUS ? predators.first : nil
  end
end

class Zombi < Being
  OBLIVI = 1
  FREAKY = 3
  VISUAL_RADIUS = 50

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
    distance, snacks = @board.humans
                             .group_by{ |h| Gosu.distance(x, y, h.x, h.y) }
                             .min_by{ |distance, human_group| distance }
    distance < VISUAL_RADIUS ? snacks.first : nil
  end
end

class GameOfDead < Gosu::Window
  DEFAULT_SETUP = { z: 1, h: 1 }
  SCREEN_WIDE = 500
  SCREEN_HIGH = 600
  INFECT_DIST = 8

  attr_reader :humans, :zombis

  def initialize opts={}
    super SCREEN_WIDE, SCREEN_HIGH, false
    self.caption = "Zombies!!"
    opts = DEFAULT_SETUP.merge opts
    @humans = Array.new(opts[:h]){ Human.new(self) }
    @zombis = Array.new(opts[:z]) { Zombi.new(self) }
  end

  def update
    tick     # everybody runs!
    tock     # some people were born to turn (into zombies)
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
  end

  def draw
    @humans.each(&:draw)
    @zombis.each(&:draw)
  end
end

