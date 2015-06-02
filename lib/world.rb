require 'gosu'

class Vector
  attr_accessor :x, :y, :ang, :mag

  def initialize opts={}
    @x   = opts[:x] || nil
    @y   = opts[:y] || nil
    @ang = opts[:a] || rand(0...360)
    @mag = opts[:m] || 0.0
  end

  def end_point
    @ang = @ang % 360
    [@x + comp_x, @y + comp_y]
  end

  def start_point= location
    @x, @y = *location
  end

  def comp_x
    rads = @ang * Math::PI / 180.0
    @mag * Math.cos(rads)
  end

  def comp_y
    rads = @ang * Math::PI / 180.0
    @mag * Math.sin(rads)
  end

  def + v2
    v2.start_point= end_point ##########################
    new_x, new_y = v2.end_point
    new_a = Gosu.angle(@x, @y, new_x, new_y) - 90
    new_m = Math.sqrt((new_x-@x)**2 + (new_y-@y)**2)
    Vector.new x: @x, y: @y, a: new_a, m: new_m
  end
end

class Ball < Gosu::Image
  attr_reader :vecto

  def initialize board, opts={}
    super board, 'lib/ball.png', false
    @wide = @high = 8
    @board = board
    @speed = 2
    @vecto = Vector.new x: rand(0...@board.width),
                        y: rand(0...@board.height),
                        m: 4
  end

  def update
    bounce_off_walls
    @vecto.start_point = @vecto.end_point
  end

  def bounce_off_walls
    ex, ey = @vecto.end_point
    inside_x_limits = ex.between?(0, @board.width)
    inside_y_limits = ey.between?(0, @board.height)

    return if inside_x_limits && inside_y_limits

    case
      when not(inside_x_limits) && not(inside_y_limits)
        reaction_ang = @vecto.ang - 180
        reaction_mag = 2 * @vecto.mag.abs
      when not(inside_x_limits)
        reaction_ang = (ex < 0 ? 0 : 180)
        reaction_mag = 2 * @vecto.comp_x.abs
      when not(inside_y_limits)
        reaction_ang = (ey < 0 ? 90 : 270)
        reaction_mag = 2 * @vecto.comp_y.abs
    end
    @vecto = @vecto + Vector.new(a: reaction_ang, m: reaction_mag)
  end

  def draw
    super(@vecto.x - @wide/2, @vecto.y - @high/2, 1)
  end
end

class GameOfDead < Gosu::Window
  attr_reader :balls
  SCREEN_WIDE, SCREEN_HIGH = 500, 600

  def initialize n=1
    super SCREEN_WIDE, SCREEN_HIGH, false
    self.caption = "Freeaaaaakkyy!!"
    @balls = Array.new(n){ Ball.new(self) }
    @font = Gosu::Font.new(self, 'system', 30)
  end

  def update
    @balls.each(&:update)
  end

  def draw
    @balls.each(&:draw)
    @font.draw(Gosu.fps.to_s, 20, 20, 2)
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end
end
