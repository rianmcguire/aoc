#!/usr/bin/env ruby
DIRS = [:n, :e, :s, :w]

DIR_TO_CONST_AXIS = {
  :n => :y,
  :e => :x,
  :s => :y,
  :w => :x,
}

DIR_TO_VARYING_AXIS = {
  :n => :x,
  :e => :y,
  :s => :x,
  :w => :y,
}

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

EdgePos = Struct.new(:pos, :dir)

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

  def edge_positions
    DIRS.flat_map do |dir|
      positions
        .filter { |pos| outside?(pos, dir) }
        .map { |pos| EdgePos.new(pos, dir) }
    end
  end

  def edges
    edge_positions
      .group_by { |e| [e.dir, e.pos[DIR_TO_CONST_AXIS[e.dir]]] }
      .sum do |key, es|
        dir, _ = key
        es.map { _1.pos[DIR_TO_VARYING_AXIS[dir]] }.sort.slice_when { |a,b| b != a + 1 }.count
      end
  end

  def outside?(pos, dir)
    o = pos.step(dir)
    !o.valid? || GRID[o.y][o.x] != name
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

result = 0
regions.each do |r|
  result += r.area * r.edges
end

puts result
