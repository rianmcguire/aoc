#!/usr/bin/env ruby

Pos = Struct.new(:x, :y, :z) do
  def dist(b)
    a = self
    Math.sqrt((a.x - b.x).pow(2) + (a.y - b.y).pow(2) + (a.z - b.z).pow(2))
  end
end

boxes = ARGF.each_line.map do |line|
  Pos.new(*line.split(",").map(&:to_i))
end

circuit_by_box = {}
boxes_by_circuit = Hash.new { |h,k| h[k] = Set.new }

boxes.each_with_index do |box, circuit|
  circuit_by_box[box] = circuit
  boxes_by_circuit[circuit] << box
end

boxes.combination(2).sort_by { |a, b| a.dist(b) }.first(1000).each do |a, b|
  next if circuit_by_box[a] == circuit_by_box[b]

  # Merge circuits. Arbitrarily choose the first one
  circuit = circuit_by_box[a]
  old_circuit = circuit_by_box[b]
  to_update = boxes_by_circuit.delete(old_circuit)
  to_update.each do |box|
    circuit_by_box[box] = circuit
    boxes_by_circuit[circuit] << box
  end
end

puts boxes_by_circuit.values.map(&:length).sort.last(3).reduce(1, :*)
