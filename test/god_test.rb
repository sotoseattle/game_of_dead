require 'test_helper'

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

  def test_prey_runs_along_line
    relocate @h, {x: 60, y:20, a: 45}
    relocate @z, {x: 10, y:20, a: 90}
    5.times do
      @h.update
      @z.update
    end
    assert_in_delta 0, @h.a, 0.1
    assert_in_delta 0, @z.a, 0.1
  end

  def test_prey_runs_along_line
    relocate @h, {x: 60, y:60, a: 45}
    relocate @z, {x: 20, y:20, a: 45}
      @h.update
      @z.update
    assert_in_delta 45, @h.a, 0.1
    assert_in_delta 45, @z.a, 0.1
  end
end
