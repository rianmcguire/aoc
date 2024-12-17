#!/usr/bin/env ruby

registers, program = ARGF.read.split("\n\n")

REG = {}
registers.each_line do |line|
  register, value = line.split(": ")
  REG[register[-1]] = value.to_i
end

REG["A"] = :a

PROGRAM = program.scan(/\d+/).map(&:to_i)

$out = []
opcodes = [
  # adv
  -> {
    REG["A"] = [:>>, REG["A"], combo]
  },
  # bxl
  -> {
    REG["B"] = [:xor, REG["B"], literal]
  },
  # bst
  -> {
    REG["B"] = [:mod8, combo]
  },
  # jnz
  -> {
    target_ip = literal
    # Assumes jnz is the last instruction, and we loop until the output is the same length as the program
    $ip = target_ip if $out.length != PROGRAM.length
  },
  # bxc
  -> {
    _ = literal
    REG["B"] = [:xor, REG["B"], REG["C"]]
  },
  # out
  -> {
    $out << [:mod8, combo]
  },
  # bdv
  -> {
    REG["B"] = [:>>, REG["A"], combo]
  },
  # cdv
  -> {
    REG["C"] = [:>>, REG["A"], combo]
  },
]

def combo
  n = PROGRAM[$ip]
  $ip += 1

  case n
  when 0..3
    n
  when 4
    REG["A"]
  when 5
    REG["B"]
  when 6
    REG["C"]
  else
    raise "invalid combo operand"
  end
end

def literal
  n = PROGRAM[$ip]
  $ip += 1
  n
end

$ip = 0
while $ip < PROGRAM.length
  opcode = PROGRAM[$ip]
  $ip += 1
  opcodes[opcode].call
end

pp $out.zip(PROGRAM)

Reverse = Struct.new(:value, :mask) do
  def eval(exp)
    op, *rest = exp
    if op.is_a?(Symbol)
      send(op, *rest)
    else
      op
    end
  end

  def a
    self
  end

  def mod8(a)
    # TODO: Is this right?
    Reverse.new(value & 7, 7).eval(a)
  end

  def xor(a, b)
    if b.is_a?(Integer)
      Reverse.new(value ^ b).eval(a)
    else
      pp self, a, b
      PANIC
    end
    # # In order for XOR to result in value (within mask), what inputs were possible
    # # 000 ^ 010 = 010
    # # 010 ^ 000 = 010
    # # 101 ^ 111 = 010
    # # 111 ^ 101 = 010
    # # ...
    # (0..mask).to_a.repeated_permutation(2)
    #   .filter { |x, y| x ^ y == value }
    #   .each do |x, y|
    #     [
    #       Reverse.new(x, mask).eval(a),
    #       Reverse.new(y, mask).eval(b),
    #     ]
    #   end
  end

  def >>(a, b)
    Reverse.new(value << b, mask << b).eval(a)
  end
end

PROGRAM.zip($out).map do |target, expr|
  r = Reverse.new(target, 7).eval(expr)
  r.value
end.reduce(:|).then { puts _1 }
