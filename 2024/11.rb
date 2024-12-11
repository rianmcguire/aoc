#!/usr/bin/env ruby

stones = ARGF.read.split

25.times do
  new_stones = []

  stones.each do |s|
    if s == "0"
      new_stones << "1"
    elsif s.length.even?
      new_stones << s[...s.length / 2].to_i.to_s
      new_stones << s[s.length / 2..].to_i.to_s
    else
      new_stones << (s.to_i * 2024).to_s
    end
  end

  stones = new_stones
end

puts stones.length
