#!/usr/bin/env ruby

require "matrix"

# n[0] * b[0, 0] + n[1] * b[1, 0] + ... = j[0]

Light = Struct.new(:buttons, :joltage) do
  def fewest_presses
    co = Matrix[
      *joltage.each_with_index.map do |j, j_i|
        buttons.map { |b| b[j_i] }
      end
    ]

    rhs = Vector[*joltage]

    max = joltage.max

    (0..max).to_a.repeated_permutation(buttons.length)
      .filter { |presses| pp(presses); co * Vector[*presses] == rhs }
      .map(&:sum)
      .min
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
  pp l
  l.fewest_presses
end

puts result
