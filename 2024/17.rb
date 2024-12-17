#!/usr/bin/env ruby

registers, program = ARGF.read.split("\n\n")

REG = {}
registers.each_line do |line|
  register, value = line.split(": ")
  REG[register[-1]] = value.to_i
end

PROGRAM = program.scan(/\d+/).map(&:to_i)

$out = []
opcodes = [
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
    $out << (combo % 8)
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

$ip = 0
while $ip < PROGRAM.length
  opcode = PROGRAM[$ip]
  $ip += 1
  opcodes[opcode].call
end

puts $out.join(",")
