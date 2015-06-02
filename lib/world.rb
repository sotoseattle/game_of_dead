require 'gosu'

class Vector
  attr_accessor :x, :y, :ang, :mag

  def initialize opts={}
    @x   = opts[:x] || 0.0
    @y   = opts[:y] || 0.0
    @ang = opts[:a] || rand(0...360)
    @mag = opts[:m] || 0.0
  end

  def end_point
    @ang = @ang % 360
    rads = @ang * Math::PI / 180.0
    [@x + @mag * Math.cos(rads), @y + @mag * Math.sin(rads)]
  end
end

class Ball < Gosu::Image
  SPEED = 4

  def initialize board, opts={}
    super board, 'lib/ball.png', false
    @wide = 8
    @high = 8
    @board = board
    @speed = Ball::SPEED
    @vect = Vector.new({ x: rand(0...@board.width),
                         y: rand(0...@board.height)})
  end

  def update
    @vect.mag = @speed
    @vect.x, @vect.y = verify_inside *@vect.end_point
  end

  def verify_inside new_x, new_y
    bad_x = new_x > @board.width  || new_x < 0
    bad_y = new_y > @board.height || new_y < 0

    return [new_x, new_y] if !bad_x && !bad_y

    @vect.ang = case
      when bad_x && bad_y then @vect.ang - 180
      when bad_x          then 180 - @vect.ang
      when bad_y          then 360 - @vect.ang
    end

    @vect.end_point
  end

  def draw
    super(@vect.x - @wide/2, @vect.y - @high/2, 1)
  end
end

class GameOfDead < Gosu::Window
  DEFAULT_SETUP = { n: 1 }
  SCREEN_WIDE = 500
  SCREEN_HIGH = 600

  def initialize opts={}
    super SCREEN_WIDE, SCREEN_HIGH, false
    self.caption = "Freeaaaaakkyy!!"
    opts = DEFAULT_SETUP.merge opts
    @balls = Array.new(opts[:n]){ Ball.new(self) }
    @font = Gosu::Font.new(self, 'system', 30)
  end

  def update
    @balls.each(&:update)
  end

  def draw
    @balls.each(&:draw)
    @font.draw(Gosu.fps.to_s, 20, 20, 2)
  end
end

