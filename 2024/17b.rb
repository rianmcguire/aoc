#!/usr/bin/env ruby

registers, program = ARGF.read.split("\n\n")

REG = {}
registers.each_line do |line|
  register, value = line.split(": ")
  REG[register[-1]] = value.to_i
end

PROGRAM = program.scan(/\d+/).map(&:to_i)

OPCODES = [
  # adv
  -> {
    REG["A"] = REG["A"] / (2**combo)
  },
  # bxl
  -> {
    REG["B"] = REG["B"] ^ literal
  },
  # bst
  -> {
    REG["B"] = combo % 8
  },
  # jnz
  -> {
    target_ip = literal
    $ip = target_ip if REG["A"] != 0
  },
  # bxc
  -> {
    _ = literal
    REG["B"] = REG["B"] ^ REG["C"]
  },
  # out
  -> {
    $out = (combo % 8)
  },
  # bdv
  -> {
    REG["B"] = REG["A"] / (2**combo)
  },
  # cdv
  -> {
    REG["C"] = REG["A"] / (2**combo)
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

# Assume the program is a loop that depends only on the A register, and shifts 3
# bits off A on every iteration.
#
# Search and build up the value for A backwards, searching for the next 3 bits to add.
def search(program, a=0)
  target = program.last
  return a if !target

  # Test every possible 3-bit value
  a <<= 3
  (0...2**3).each do |n|
    REG["A"] = a | n
    $ip = 0
    loop do
      opcode = PROGRAM[$ip]
      $ip += 1
      OPCODES[opcode].call

      # Break if we were about to loop
      break if $ip == 0 || $ip > PROGRAM.length - 1
    end

    # If we got the target output value, go deeper
    if $out == target && r = search(program[...-1], a | n)
      return r
    end
  end

  nil
end

puts search(PROGRAM)
