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
    v2.start_point= end_point
    new_x, new_y = v2.end_point
    new_a = Gosu.angle(@x, @y, new_x, new_y) - 90
    new_m = Gosu.distance(@x, @y, new_x, new_y)
    Vector.new x: @x, y: @y, a: new_a, m: new_m
  end
end

class Ball < Gosu::Image
  attr_reader :vecto
  DRAG = 1.8
  GRAV = Vector.new a: 90, m: 0.8

  def initialize board, opts={}
    super board, 'lib/ball.png', false
    @wide = @high = 8
    @vecto = Vector.new x: rand(0...board.width),
                        y: rand(0...board.height),
                        m: 4
    @border = { south: Vector.new(y: board.height, a: 270),
              north: Vector.new(y: 0, a: 90),
              east:  Vector.new(x: 0, a: 0),
              west:  Vector.new(x: board.width, a: 180) }
  end

  def update
    apply_gravity
    confine_inside
    @vecto.start_point = @vecto.end_point
  end

  def apply_gravity
    @vecto = @vecto + GRAV
  end

  def confine_inside
    ex, ey = @vecto.end_point
    outside_x_limits = [ex < 0, ex > @border[:west].x]
    outside_y_limits = [ey < 0, ey > @border[:south].y]

    return if (outside_x_limits + outside_y_limits).none?

    walls = []
    if outside_x_limits.any?
      w = outside_x_limits.first ? @border[:east].dup : @border[:west].dup
      w.mag = DRAG * @vecto.comp_x.abs
      walls << w
    end

    if outside_y_limits.any?
      w = outside_y_limits.first ? @border[:north].dup : @border[:south].dup
      w.mag = DRAG * @vecto.comp_y.abs
      walls << w
    end

    bounce walls
  end

  def bounce vectors
    vectors.each do |w|
      w.x ||= @vecto.x
      w.y ||= @vecto.y
      @vecto += w
    end
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
