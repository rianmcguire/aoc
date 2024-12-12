#!/usr/bin/env ruby
DIRS = [:n, :e, :s, :w]

DIR_TO_CONST_AXIS = {
  :n => :y,
  :e => :x,
  :s => :y,
  :w => :x,
}

def opposite_axis(axis) = if axis == :x then :y else :x end

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
end

EdgePos = Struct.new(:pos, :dir)

Region = Struct.new(:name, :positions) do
  def area
    positions.length
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
      # Group edge positions by their external-facing direction and their constant axis (eg. all north-facing edges at y=2)
      .group_by { |e| [e.dir, e.pos[DIR_TO_CONST_AXIS[e.dir]]] }
      .sum do |(dir, _), e_positions|
        varying_axis = opposite_axis(DIR_TO_CONST_AXIS[dir])

        # Determine the number of distinct edges in this group
        e_positions
          .map { _1.pos[varying_axis] }
          .sort
          # If there's a gap in the positions, it's a new edge
          .slice_when { |a,b| b != a + 1 }
          .count
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
ALL_POSITIONS = Enumerator.product(X_RANGE, Y_RANGE).map { |x,y| Pos.new(x,y) }

def find_region(initial)
  filled = Set.new

  explored = Set.new
  target = GRID[initial.y][initial.x]

  to_explore = [initial]
  while to_explore.any?
    pos = to_explore.shift
    next unless GRID[pos.y][pos.x] == target

    filled << pos

    DIRS.each do |dir|
      new_pos = pos.step(dir)
      to_explore << new_pos if new_pos.valid? && explored.add?(new_pos)
    end
  end

  Region.new(target, filled)
end

regions = []

unvisited = Set.new(ALL_POSITIONS)
while unvisited.any?
  seed = unvisited.first
  unvisited.delete(seed)

  regions << find_region(seed)

  unvisited.subtract(regions.last.positions)
end

result = 0
regions.each do |r|
  result += r.area * r.edges
end

puts result
