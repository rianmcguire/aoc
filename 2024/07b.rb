#!/usr/bin/env ruby

RubyVM::YJIT.enable

OPS = [:+, :*, :concat_digits]

class Numeric
  def concat_digits(n)
    power = 10
    while n >= power
      power *= 10
    end
    self * power + n
  end
end

# There's a limited set of permutations. Avoid re-generating them for every equation we test.
module MemoizedRepeatedPermutation
  def repeated_permutation(n)
    @repeated_permutation ||= {}
    @repeated_permutation[n] ||= super.to_a
  end
end
Array.prepend(MemoizedRepeatedPermutation)

Eqn = Data.define(:target, :values) do
  def n_gaps
    values.length - 1
  end

  def valid_with?(operators)
    result = values[0]
    values.drop(1).zip(operators) do |n, op|
      return false if result > target
      case op
      when :+ then result += n
      when :* then result *= n
      when :concat_digits then result = result.concat_digits(n)
      end
    end
    result == target
  end

  def solveable?
    OPS.repeated_permutation(n_gaps).any? { |operators| valid_with?(operators) }
  end
end

result = 0
ARGF.each_line do |line|
  target, values = line.split(": ")
  target = target.to_i
  values = values.split.map(&:to_i)
  eqn = Eqn.new(target, values)

  result += eqn.target if eqn.solveable?
end

puts result
