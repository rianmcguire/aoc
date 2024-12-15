#!/usr/bin/env ruby

grid, moves = ARGF.read.split("\n\n")

grid.gsub!("#", "##").gsub!("O", "[]").gsub!(".", "..").gsub!("@", "@.")
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
$grid = grid.each_line.with_index.map do |row, y|
  row.chomp.chars.each_with_index.map do |c, x|
    robot = Pos.new(x,y) if c == "@"
    c
  end
end

def try_move(pos, dir, ignore=nil)
  new_pos = pos.step(dir)

  case c = $grid[new_pos.y][new_pos.x]
  when "#"
    # Wall - can't move
    return false
  when "[", "]"
    # Try to push the box in the same direction
    if c == "["
      other_half = new_pos.step(">")
    else
      other_half = new_pos.step("<")
    end

    backup_grid = $grid.map(&:dup)

    if ignore != other_half && !try_move(other_half, dir, new_pos)
      # The other half of the box can't move, so this half can't move either
      return false
    end

    if !try_move(new_pos, dir)
      # Roll back other_half move if we couldn't move this half
      $grid = backup_grid
      # If the box can't move, we can't move
      return false
    end
  end

  # The target space is empty - we can move
  $grid[new_pos.y][new_pos.x] = $grid[pos.y][pos.x]
  $grid[pos.y][pos.x] = "."
  new_pos
end

moves.chars.each do |m|
  if new_pos = try_move(robot, m)
    robot = new_pos
  end
end

$grid.each_with_index.sum do |row, y|
  row.each_with_index.sum do |c, x|
    if c == "["
      100 * y + x
    else
      0
    end
  end
end.then { puts _1 }
