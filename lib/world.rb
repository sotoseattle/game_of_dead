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

  def - v2
    v2.ang = -v2.ang
    self + v2
  end
end

class Ball < Gosu::Image
  attr_reader :vec
  attr_accessor :other, :col
  DRAG = 0.8
  GRAV = Vector.new a: 90, m: 0.8

  def initialize board, veco
    super board, 'lib/ball.png', false
    @col = Gosu::Color::WHITE
    @len = 8
    @vec = veco || Vector.new(x: rand(0...board.width),
                              y: rand(0...board.height),
                              a: rand(0...360),
                              m: 1)
    @other = board.balls - [self]
    @limit = { south: Vector.new(y: board.height, a: 270),
               north: Vector.new(y: 0, a: 90),
               east:  Vector.new(x: 0, a: 0),
               west:  Vector.new(x: board.width, a: 180) }
  end

  def update
    # apply_gravity
    check_collisions
    confine_inside
    @vec.start_point = @vec.end_point
  end

  def apply_gravity
    @vec += GRAV
  end

  def check_collisions
    near = @other.min_by { |b| Gosu.distance(@vec.x, @vec.y, b.vec.x, b.vec.y) }
    if near
      if Gosu.distance(@vec.x, @vec.y, near.vec.x, near.vec.y) < @len/2
        w = near.vec.dup
        w.mag *= DRAG
        @vec -= w
      end
    end
  end

  def confine_inside
    ex, ey = @vec.end_point
    outside_x_limits = [ex < 0, ex > @limit[:west].x]
    outside_y_limits = [ey < 0, ey > @limit[:south].y]

    return if (outside_x_limits + outside_y_limits).none?

    walls = []
    if outside_x_limits.any?
      w = outside_x_limits.first ? @limit[:east].dup : @limit[:west].dup
      w.mag = DRAG * 2 * @vec.comp_x.abs
      walls << w
    end

    if outside_y_limits.any?
      w = outside_y_limits.first ? @limit[:north].dup : @limit[:south].dup
      w.mag = DRAG *  2 * @vec.comp_y.abs
      walls << w
    end

    walls.each do |w|
      w.x ||= @vec.x
      w.y ||= @vec.y
      @vec += w
    end
  end

  def draw
    super(@vec.x - @len/2, @vec.y - @len/2, 1, 1,1, color=@col)
  end
end

class GameOfDead < Gosu::Window
  attr_reader :balls
  SCREEN_WIDE, SCREEN_HIGH = 500, 600

  def initialize
    super SCREEN_WIDE, SCREEN_HIGH, false
    self.caption = "Freeaaaaakkyy!!"
    @balls = []
    @font = Gosu::Font.new(self, 'system', 30)
  end

  def << ball
    @balls << ball
  end

  def ready
    @balls.each { |b| b.other = @balls - [b] }
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
