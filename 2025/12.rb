#!/usr/bin/env ruby

Pos = Struct.new(:x, :y)
Shape = Struct.new(:lines) do
  def orientations
    @orientations ||= (
      s = self
      result = [s]
      3.times do
        s = s.rotate
        result << s
      end

      s = self.flip
      3.times do
        s = s.rotate
        result << s
      end

      result.uniq
    )
  end

  def flip
    Shape.new(lines.reverse)
  end

  def rotate
    Shape.new(lines.transpose.map(&:reverse))
  end

  def width
    lines[0].length
  end

  def height
    lines.length
  end
end
Region = Struct.new(:x, :y, :counts)

class Grid
  def initialize(grid)
    @grid = grid
  end

  def self.with_size(x, y)
    new(Array.new(y) { Array.new(x, nil) })
  end

  def dup
    Grid.new(@grid.map(&:dup))
  end

  def possible_locations(shape)
    result = []

    # TODO: can we do something with overlapping ranges instead of bruteforce?
    # or something about searching for a sequence?

    0.upto(width - shape.width) do |x|
      0.upto(height - shape.height) do |y|
        result << Pos.new(x, y)
      end
    end

    result
  end

  def width
    @grid[0].length
  end

  def height
    @grid.length
  end

  def try_add(shape, pos)
    new_grid = dup

    if new_grid.add(shape, pos)
      new_grid
    else
      nil
    end
  end

  def add(shape, pos)
    0.upto(shape.width - 1).each do |sx|
      0.upto(shape.height - 1).each do |sy|
        c = shape.lines[sy][sx]
        next unless c == "#"

        if @grid[pos.y + sy][pos.x + sx].nil?
          @grid[pos.y + sy][pos.x + sx] = c
        else
          return false
        end
      end
    end
  end
end

*shapes, regions = ARGF.read.split("\n\n")

shapes.map! do |shape|
  Shape.new(shape.lines.drop(1).map { |s| s.chomp.chars })
end

regions = regions.lines.map do |line|
  x, y, *counts = line.split(/[x ]/).map(&:to_i)
  Region.new(x, y, counts)
end

def can_fit?(shapes, grid, counts)
  i = counts.find_index { |c| c > 0 }

  # Are we done?
  return true if i.nil?

  shape = shapes[i]
  new_counts = counts.dup
  new_counts[i] -= 1

  shape.orientations.any? do |s|
    grid.possible_locations(s).any? do |pos|
      $evaluated += 1
      new_grid = grid.try_add(s, pos)
      can_fit?(shapes, new_grid, new_counts) if new_grid
    end
  end
end

result = regions.count do |region|
  pp region

  $evaluated = 0
  grid = Grid.with_size(region.x, region.y)
  pp(can_fit?(shapes, grid, region.counts))

  puts "Evaluated #{$evaluated}"
end

puts result
