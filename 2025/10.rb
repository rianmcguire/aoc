#!/usr/bin/env ruby

Light = Struct.new(:goal, :buttons, :joltage) do
  def fewest_presses
    # We only need to consider pressing each button once, as pressing twice is equivalent to not pressing
    n = 0
    loop do
      return n if buttons.combination(n).any? { |bs| bs.reduce(:^) == goal }
      n += 1
    end
  end
end

lights = ARGF.each_line.map do |line|
  goal, *buttons, joltage = line.chomp.split(" ")

  # Transform the goal into an integer value (lights are bits)
  goal = goal[1...-1].tr(".#", "01").reverse.to_i(2)

  # Transform the buttons into the value they contribute to the goal
  buttons.map! do |button|
    button[1...-1].split(",").map { |n| 2 ** n.to_i }.sum
  end

  Light.new(goal, buttons, joltage)
end

result = lights.sum do |l|
  l.fewest_presses
end

puts result
