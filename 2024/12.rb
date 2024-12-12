#!/usr/bin/env ruby
DIRS = [:n, :e, :s, :w]

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

  def neighbours
    DIRS.map { step(_1) }.filter(&:valid?)
  end
end

Region = Struct.new(:name, :positions) do
  def area
    positions.length
  end

  def perimeter
    positions.sum do |pos|
      same_region = pos.neighbours.count { |n_pos| GRID[n_pos.y][n_pos.x] == name }
      4 - same_region
    end
  end
end

GRID = ARGF.each_line.with_index.map do |row, y|
  row.chomp.chars
end

Y_RANGE = 0...GRID.length
X_RANGE = 0...GRID.first.length

unvisited = Set.new(Enumerator.product(X_RANGE, Y_RANGE).map { |x,y| Pos.new(x,y) })

regions = []
while unvisited.any?
  seed = unvisited.first
  unvisited.delete(seed)

  explored = Set.new
  queue = [seed]
  target = GRID[seed.y][seed.x]
  area = Set.new
  while queue.any?
    pos = queue.shift
    next unless GRID[pos.y][pos.x] == target

    area << pos
    unvisited.delete(pos)

    DIRS.each do |dir|
      new_pos = pos.step(dir)
      queue << new_pos if new_pos.valid? && !area.include?(new_pos) && explored.add?(new_pos)
    end
  end

  regions << Region.new(target, area)
end

puts regions.sum { |r| r.area * r.perimeter }
