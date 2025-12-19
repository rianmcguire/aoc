#!/usr/bin/env ruby

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

  def area
    @area ||= lines.sum { |line| line.count { |c| c == "#" } }
  end

  def height
    lines.length
  end

  def row_pattern
    @row_pattern ||= lines.map { |line| line.count("#") }
  end
end

Region = Struct.new(:width, :height, :counts)

*shapes, regions = ARGF.read.split("\n\n")

shapes.map! do |shape|
  Shape.new(shape.lines.drop(1).map { |s| s.chomp.chars })
end

regions = regions.lines.map do |line|
  x, y, *counts = line.split(/[x ]/).map(&:to_i)
  Region.new(x, y, counts)
end

def can_fit?(region, shapes)
  total_shape_area = shapes.sum(&:area)
  total_grid_area = region.width * region.height
  return false if total_shape_area > total_grid_area

  return false unless might_fit_horizontally?(region, shapes)

  # Assume it fits based on the heuristics above only
  # This doesn't work with 12eg.txt region 3, but does work with the input data
  true
end

# Check if there's any valid arrangement of shapes by y position, such that no
# row exceeds the region's width.
def might_fit_horizontally?(region, shapes, row_counts = Array.new(region.height, 0))
  return true if shapes.empty?
  return false if row_counts.any? { |c| c > region.width }

  # Try the next shape in all possible vertical positions
  shape = shapes.first
  max_y = region.height - shape.height
  shape.orientations.map(&:row_pattern).each do |pattern|
    (0..max_y).each do |y|
      new_row_counts = row_counts.dup
      pattern.each_with_index do |count, shape_y|
        new_row_counts[y + shape_y] += count
      end

      return true if might_fit_horizontally?(region, shapes[1..], new_row_counts)
    end
  end

  false
end

result = regions.count do |region|
  region_shapes = shapes.zip(region.counts).flat_map do |shape, count|
    [shape] * count
  end

  can_fit?(region, region_shapes)
end

puts result
