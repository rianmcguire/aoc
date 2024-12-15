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
  c = $grid[new_pos.y][new_pos.x]

  case c
  when "#"
    # Can't move
    false
  when "."
    $grid[new_pos.y][new_pos.x] = $grid[pos.y][pos.x]
    $grid[pos.y][pos.x] = "."
    new_pos
  when "[", "]"
    if c == "["
      other_half = new_pos.step(">")
    else
      other_half = new_pos.step("<")
    end

    if ignore != other_half
      backup_grid = $grid.map(&:dup)
      if try_move(other_half, dir, new_pos)
        if try_move(new_pos, dir)
          $grid[new_pos.y][new_pos.x] = $grid[pos.y][pos.x]
          $grid[pos.y][pos.x] = "."
          new_pos
        else
          # Roll back other_half move
          $grid = backup_grid
          false
        end
      else
        false
      end
    else
      if try_move(new_pos, dir)
        $grid[new_pos.y][new_pos.x] = $grid[pos.y][pos.x]
        $grid[pos.y][pos.x] = "."
        new_pos
      else
        false
      end
    end
  else
    raise "wtf: #{c.inspect}"
  end
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
