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

    # Unknown variables: number of presses required for each button
    presses = buttons.length.times.map { |i| Opt::Integer.new(0...) }

    joltage.each_with_index do |j, j_i|
      # Find the buttons that increment this joltage counter
      presses_for_joltage = buttons.each_with_index.filter { |button, b_i| button.include?(j_i) }.map { |button, b_i| presses[b_i] }

      # Their presses need to equal the required joltage
      prob.add(presses_for_joltage.reduce(:+) == j)
    end

    # Solve, minimizing the number of presses
    prob.minimize(presses.reduce(:+))
    prob.solve

    presses.map(&:value).sum
  end
end

lights = ARGF.each_line.map do |line|
  _, *buttons, joltage = line.chomp.split(" ")

  buttons.map! { |s| s[1...-1].split(",").map(&:to_i) }
  joltage = joltage[1...-1].split(",").map(&:to_i)

  Light.new(buttons, joltage)
end

result = lights.sum do |l|
  l.fewest_presses
end

puts result
