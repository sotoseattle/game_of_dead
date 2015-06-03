#!/usr/bin/env ruby

require './lib/world.rb'

window = GameOfDead.new

colors = [Gosu::Color::WHITE,
          Gosu::Color::AQUA,
          Gosu::Color::RED,
          Gosu::Color::GREEN,
          Gosu::Color::YELLOW,
          Gosu::Color::FUCHSIA,
          Gosu::Color::CYAN]
3.times do
  (0...7).each do |i|
    b = Ball.new(window, nil)
    b.col = colors[i]
    window << b
  end
end

window.ready

window.show
