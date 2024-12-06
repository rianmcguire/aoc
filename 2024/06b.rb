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

DIRS_AT_POINT ||= Hash.new { |h,k| h[k] = [] }

dir = :n
pos = START
loop do
  DIRS_AT_POINT[pos] << dir

  next_pos = pos.step(dir)
  break if !next_pos.valid?

  if next_pos.obstacle?
    dir = turn_right(dir)
  else
    pos = next_pos
  end
end

def loops?(new_obstacle)
  visited = Set.new

  dir = :n
  pos = START
  loop do
    return true if !visited.add?([pos, dir])

    next_pos = pos.step(dir)
    return false if !next_pos.valid?

    if next_pos.obstacle? || next_pos == new_obstacle
      dir = turn_right(dir)
    else
      pos = next_pos
    end
  end
end

# TODO: we can search this as we go, rather than checking all the positions afterwards
result = Set.new
DIRS_AT_POINT.each do |pos, dirs|
  dirs.each do |dir|
    # If there was an obstacle in front of us here, would we loop?
    obstacle = pos.step(dir)
    if obstacle.valid? && !obstacle.obstacle? && loops?(obstacle)
      result << obstacle
    end
  end
end

puts result.length
