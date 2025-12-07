#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
  def step(dir)
      case dir
      when :n
          Pos.new(x, y - 1)
      when :s
          Pos.new(x, y + 1)
      when :e
          Pos.new(x + 1, y)
      when :w
          Pos.new(x - 1, y)
      end
  end
end

GRID = ARGF.each_line.each_with_index.map do |line, y|
  line.chomp.chars.each_with_index do |c, x|
    if c == "S"
      START = Pos.new(x, y)
    end

    c
  end
end

def dfs(beam, memo = {})
  memo[beam] ||= (
    y = beam.y
  
    return 1 if y == GRID.length - 1
    
    splitters = GRID[y].each_with_index.filter { |c, x| c == "^" }.map { |c, x| Pos.new(x, y) }
    splitter = splitters.find { |s| s == beam }
    
    beam = beam.step(:s)
    
    if splitter
      [splitter.step(:w), splitter.step(:e)].sum do |b|
        dfs(b, memo)
      end
    else
      dfs(beam, memo)
    end
  )
end

puts dfs(START)
