#!/usr/bin/env ruby

DIRS = [:n, :e, :s, :w]

def turn_right(dir)
  DIRS[(DIRS.index(dir) + 1) % DIRS.length]
end

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

  def valid?
    X_RANGE.include?(x) && Y_RANGE.include?(y)
  end

  def obstacle?
    GRID.fetch(y).fetch(x) == '#'
  end
end

GRID = ARGF.each_line.with_index.map do |row, y|
  row.chomp.chars.each_with_index.map do |c, x|
    if c == '^'
      START = Pos.new(x,y)
      '.'
    else
      c
    end
  end
end

Y_RANGE = 0...GRID.length
X_RANGE = 0...GRID.first.length

def loops?(pos, dir, new_obstacle, visited)
  loop do
    next_pos = pos.step(dir)
    return false if !next_pos.valid?

    if next_pos.obstacle? || next_pos == new_obstacle
      dir = turn_right(dir)
    else
      if !new_obstacle
        # Try placing a obstacle in front of the current position
        would_block_path_to_here = DIRS.any? { |dir| visited.include?([next_pos, dir]) }
        if !would_block_path_to_here && loops?(pos, dir, next_pos, visited.dup)
          yield next_pos
        end
      end

      pos = next_pos
    end

    return true if !visited.add?([pos, dir])
  end
end

result = Set.new
loops?(START, :n, nil, Set.new) do |obstacle|
  result << obstacle
end

puts result.length
