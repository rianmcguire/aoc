#!/usr/bin/env ruby

require "matrix"

Pos = Struct.new(:x, :y)
Machine = Struct.new(:a, :b, :prize)

machines = ARGF.read.split("\n\n").map do |chunk|
  Machine.new(*chunk.scan(/\d+/).map(&:to_i).each_slice(2).map { Pos.new(*_1) })
end

machines.sum do |m|
  # Solve as a system of linear equations
  co = Matrix[
    [m.a.x, m.b.x],
    [m.a.y, m.b.y],
  ]
  rhs = Vector[m.prize.x, m.prize.y]
  a, b = co.lup.solve(rhs).to_a

  if a.denominator == 1 && b.denominator == 1
    (a * 3 + b).to_i
  else
    # No integer solution
    0
  end
end.then { puts _1 }
