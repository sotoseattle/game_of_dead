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

class Ball < Being
  attr_reader :infected

  SPEED = 4

  def initialize board
    super board, 'lib/ball.png'
    @speed = Ball::SPEED
  end

  def update
    super
  end

end

class GameOfDead < Gosu::Window
  attr_reader :balls

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
    # @font.draw(@balls.count.to_s, 20, 20, 2)
    @font.draw(Gosu.fps.to_s, 20, 20, 2)
  end
end

