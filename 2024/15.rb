#!/usr/bin/env ruby

grid, moves = ARGF.read.split("\n\n")

moves.gsub!("\n", "")

Pos = Struct.new(:x, :y) do
  def step(dir)
    case dir
    when "^"
      Pos.new(x, y - 1)
    when "v"
      Pos.new(x, y + 1)
    when ">"
      Pos.new(x + 1, y)
    when "<"
      Pos.new(x - 1, y)
    else
      raise "wtf"
    end
  end
end

robot = nil
GRID = grid.each_line.with_index.map do |row, y|
  row.chomp.chars.each_with_index.map do |c, x|
    robot = Pos.new(x,y) if c == "@"
    c
  end
end

def try_move(pos, dir)
  new_pos = pos.step(dir)

  case GRID[new_pos.y][new_pos.x]
  when "#"
    # Can't move
    false
  when "."
    GRID[new_pos.y][new_pos.x] = GRID[pos.y][pos.x]
    GRID[pos.y][pos.x] = "."
    new_pos
  when "O"
    if try_move(new_pos, dir)
      GRID[new_pos.y][new_pos.x] = GRID[pos.y][pos.x]
      GRID[pos.y][pos.x] = "."
      new_pos
    else
      false
    end
  else
    raise "wtf"
  end
end

moves.chars.each do |m|
  if new_pos = try_move(robot, m)
    robot = new_pos
  end
end

GRID.each_with_index.sum do |row, y|
  row.each_with_index.sum do |c, x|
    if c == "O"
      100 * y + x
    else
      0
    end
  end
end.then { puts _1 }
