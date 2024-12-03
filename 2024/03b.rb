#!/usr/bin/env ruby

input = ARGF.read
enabled = true
input.scan(/(mul)\((\d+),(\d+)\)|(do)\(\)|(don't)\(\)/).sum do |s|
  mul, a, b, on, off = s
  if mul
    if enabled
      a = a.to_i
      b = b.to_i
      a * b
    else
      0
    end
  elsif on
    enabled = true
    0
  elsif off
    enabled = false
    0
  else
    raise "wtf"
  end
end.then { puts _1 }
