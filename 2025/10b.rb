#!/usr/bin/env ruby

require "matrix"

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'opt-rb'
  gem 'highs'
end

Light = Struct.new(:buttons, :joltage) do
  def fewest_presses
    # Throw a MILP solver at it
    # TODO: find the search approach
    prob = Opt::Problem.new
    presses = buttons.length.times.map { |i| Opt::Integer.new(0...) }
    joltage.each_with_index do |j, j_i|
      prob.add(buttons.each_with_index.map { |button, b_i| presses[b_i] * button[j_i] }.reduce(:+) == j)
    end
    prob.minimize(presses.reduce(:+))

    prob.solve[:objective].to_i
  end
end

lights = ARGF.each_line.map do |line|
  _, *buttons, joltage = line.chomp.split(" ")

  joltage = joltage[1...-1].split(",").map(&:to_i)

  buttons.map! do |button|
    levels = Array.new(joltage.length, 0)
    button[1...-1].split(",").map do |s|
      levels[s.to_i] = 1
    end
    levels
  end

  Light.new(buttons, joltage)
end

result = lights.sum do |l|
  l.fewest_presses
end

puts result
