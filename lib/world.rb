require 'gosu'

class Being < Gosu::Image
  VELO = 4

  def initialize board, file
    super board, file, false
    @board = board
    @x = rand(0..@board.width)
    @y = rand(0..@board.height)
    @a = rand(0..360)
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
end

class Human < Being
  def initialize board
    super board, 'human.png'
  end
end

class Zombi < Being
  def initialize board
    super board, 'zombi.png'
  end
end

class WhackARuby < Gosu::Window
  def initialize
    super 400, 400, false
    self.caption = "Whack the Ruby!"
    @human = Human.new(self)
    @zombi = Zombi.new(self)
 end

  def update
    @human.update
    @zombi.update
  end

  def draw
    c = Gosu::Color::NONE
    #draw_quad(0,0,c,800,0,c,800,600,c,0,600,c)
    @human.draw
    @zombi.draw
  end
end

window = WhackARuby.new
window.show
