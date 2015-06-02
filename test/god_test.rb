require_relative './test_helper'

class GameOfDeadTest < Minitest::Test
  def setup
    @w = GameOfDead.new 1
    @b = @w.balls.first
  end

  def relocate obj, opts
    opts.each do |ivar, val|
      obj.instance_variable_set("@#{ivar}", val)
    end
  end

  def test_bounce_left_wall
    v = @b.vecto
    relocate v, {x: 2, y: 20, ang: 180}
    @b.update
    assert_in_delta 0, @b.vecto.ang % 360, 0.001
    assert @b.vecto.x > 0
  end

  def test_bounce_left_wall_2
    v = @b.vecto
    relocate v, {x: 2, y: 20, ang: 180+45}
    @b.update
    assert_in_delta 270+45, @b.vecto.ang % 360, 0.001
    assert @b.vecto.x > 0
  end

  def test_bounce_left_wall_2
    v = @b.vecto
    relocate v, {x:   GameOfDead::SCREEN_WIDE - 2,
                 y:   GameOfDead::SCREEN_HIGH - 2,
                 ang: 45}
    @b.update
    assert_in_delta 180+45, @b.vecto.ang % 360, 0.001
    assert @b.vecto.x < GameOfDead::SCREEN_WIDE
  end

end
