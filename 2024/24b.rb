#!/usr/bin/env ruby

Gate = Struct.new(:op, :a, :b, :name) do
  def a
    return self[:a] if input?(self[:a])
    GATES[self[:a]]
  end

  def b
    return self[:b] if input?(self[:b])
    GATES[self[:b]]
  end

  def operands
    [a, b]
  end

  def <=>(other)
    sort_key <=> other.sort_key
  end

  def sort_key
    [op, self[:a], self[:b]]
  end

  def input?(gate)
    gate[0] == "x" || gate[0] == "y"
  end
end

initial, gates = ARGF.read.split("\n\n")

GATES = {}

gates.each_line(chomp: true).each do |l|
  a, op, b, _, out = l.split(" ")

  GATES[out] = Gate.new(op, a, b, out)
end

output_gate_names = GATES.keys.filter { _1[0] == "z" }.sort

bad_gates = []
output_gate_names
  .each_with_index do |gate, i|
    n = sprintf('%02d', i)
    n_prev = sprintf('%02d', i-1)

    # Special-ish cases. These are correct in my input data, so don't bother handling them
    next if ["z00", "z01", "z02", "z45"].include?(gate)

    g = GATES[gate]

    # Validate that the definition of this output looks like an adder with this shape:
    # z[n] = (xor
    #   (xor x[n] y[n])
    #   carry[n-1]
    # )
    # carry[n] = (or
    #   (and x[n] y[n])
    #   (and c_out[n-1] (xor x[n] y[n]))
    # )

    if g.op != "XOR"
      puts "#{gate}: no top-level XOR"
      bad_gates << gate
      next
    end

    input_xor = g.operands.find { |ex| ex.op == "XOR" && ex.operands.sort == ["x#{n}", "y#{n}"] }
    if !input_xor
      puts "#{gate}: no input XOR"
      # TODO: hard coded assumption based on input
      bad_gates << g.operands.first.name
      next
    end

    carry = g.operands.find { _1 != input_xor }
    if carry.op != "OR"
      puts "#{gate}: unexpected carry operation"
      bad_gates << carry.name
      next
    end

    c1 = carry.operands.find do |o|
      o.op == "AND" && o.operands.sort == ["x#{n_prev}", "y#{n_prev}"]
    end
    if !c1
      puts "#{gate}: could not find (and x[n] y[n])"
      # TODO: hard coded assumption based on input
      bad_gates << carry.operands.last.name
      next
    end

    c2 = carry.operands.find { _1 != c1 && _1.op == "AND" }
    if !c2
      puts "#{gate}: could not find (and c_out[n-1] (xor x[n] y[n]))"
      # TODO: hard coded assumption based on input
      bad_gates << carry.operands.last.name
      next
    end
    c2_xor = c2.operands.find { |ex| ex.op == "XOR" }

    prev_prev_carry = c2.operands.find { _1 != c2_xor }
    if prev_prev_carry.op != "OR"
      puts "#{gate}: unexpected carry in"
      bad_gates << prev_prev_carry.name
      next
    end
  end

puts bad_gates.uniq.sort.join(",")
