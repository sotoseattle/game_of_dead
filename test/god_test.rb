require_relative './test_helper'

class GameOfDeadTest < Minitest::Test
  def setup
    @w = GameOfDead.new h:1, z:1
    @h = @w.humans.first
    @z = @w.zombis.first
  end

  def relocate obj, opts
    opts.each do |ivar, val|
      obj.instance_variable_set("@#{ivar}", val)
    end
  end

  def str o
    "#{o.class} [#{o.x}, #{o.y}] -> #{o.a}"
  end

  def test_prey_runs_along_line_1
    relocate @h, {x: 60, y:20, a: 0}
    relocate @z, {x: 10, y:20, a: 0}
    5.times do
      @h.update
      @z.update
    end
    assert_in_delta   0, @h.a % 360, 0.1
    assert_in_delta 360, @z.a % 360, 0.1
  end

  def test_prey_runs_along_line_2
    relocate @h, {x: 60, y:60, a: 45}
    relocate @z, {x: 20, y:20, a: 45}
    @h.update
    @z.update
    assert_in_delta 45, @h.a, 0.1
    assert_in_delta 45, @z.a, 0.1
  end

  def test_bug_simulatneous_bitten
    w = GameOfDead.new h:2, z:1
    pepe, luis = w.humans
    relocate pepe, {x: 59, y:59, a: 45}
    relocate luis, {x: 61, y:61, a: 45}
    relocate w.zombis.first, {x: 60, y:60, a: 45}
    w.update
    assert_equal 3, w.zombis.count
    assert_equal 0, w.humans.count
  end

  def test_bug_scaping_human_top_left
    relocate @h, {x: 1, y:1, a: 225}
    relocate @z, {x: 5, y:5, a: 225}
    @h.update

    refute @h.x_outbound?(@h.x)
    refute @h.y_outbound?(@h.y)
  end

  def test_bug_scaping_human_top_right
    relocate @h, {x: GameOfDead::SCREEN_WIDE, y:0, a: 315}
    relocate @z, {x: GameOfDead::SCREEN_WIDE - 5, y:5, a: 315}
    @h.update

    refute @h.x_outbound? @h.x
    refute @h.y_outbound? @h.y
  end

  def test_bug_scaping_human_bottom_right
    relocate @h, {x: GameOfDead::SCREEN_WIDE, y: GameOfDead::SCREEN_HIGH, a: 45}
    relocate @z, {x: GameOfDead::SCREEN_WIDE - 5, y: GameOfDead::SCREEN_HIGH - 5, a: 45}
    @h.update

    refute @h.x_outbound? @h.x
    refute @h.y_outbound? @h.y
  end

  def test_bug_scaping_human_bottom_left
    relocate @h, {x: 0, y: GameOfDead::SCREEN_HIGH, a: 135}
    relocate @z, {x: 5, y: GameOfDead::SCREEN_HIGH + 5, a: 135}
    @h.update

    refute @h.x_outbound? @h.x
    refute @h.y_outbound? @h.y
  end
end
