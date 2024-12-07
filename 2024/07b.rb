#!/usr/bin/env ruby

OPS = [:+, :*, :concat_digits]

class Numeric
  def concat_digits(n)
    (self.to_s + n.to_s).to_i
  end
end

Eqn = Struct.new(:target, :values) do
  def n_gaps
    values.length - 1
  end

  def evaluate(operators)
    result = values[0]
    values.drop(1).zip(operators) do |n, op|
      result = result.send(op, n)
    end
    result
  end
end

eqns = ARGF.each_line.map do |line|
  target, values = line.split(": ")
  target = target.to_i
  values = values.split.map(&:to_i)
  Eqn.new(target, values)
end

result = 0
eqns.each do |eqn|
  OPS.repeated_permutation(eqn.n_gaps).each do |operators|
    if eqn.evaluate(operators) == eqn.target
      result += eqn.target
      break
    end
  end
end

puts result
