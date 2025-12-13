#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
  def area(b)
    a = self
    ((a.x - b.x).abs + 1) * ((a.y - b.y).abs + 1)
  end

  def cross(b)
    a = self
    a.x * b.y - a.y * b.x
  end

  def -(b)
    Pos.new(x - b.x, y - b.y)
  end
end

tiles = ARGF.each_line.map do |line|
  Pos.new(*line.split(",").map(&:to_i))
end

# https://en.wikipedia.org/wiki/Even%E2%80%93odd_rule
def point_in_poly?(pos, poly)
  c = false
  poly.length.times do |i|
    a = poly[i]
    b = poly[i - 1]

    # point is a corner
    return true if pos == a

    if (a.y > pos.y) != (b.y > pos.y)
      slope = orient(pos, a, b)

      # point is on boundary
      return true if slope == 0

      if (slope < 0) != (b.y < a.y)
        c = !c
      end
    end
  end
  c
end

def rect_points(a, b)
  [a, Pos.new(a.x, b.y), b, Pos.new(b.x, a.y)]
end

def orient(a, b, c)
  (b - a).cross(c - a)
end

# https://old.reddit.com/r/algorithms/comments/9moad4/what_is_the_simplest_to_implement_line_segment/
def segments_intersect?(a, b, c, d)
  oa = orient(c, d, a)
  ob = orient(c, d, b)
  oc = orient(a, b, c)
  od = orient(a, b, d)

  # Proper intersection exists iff opposite signs
  return (oa*ob < 0 && oc*od < 0)
end

def rect_inside_poly?(rect, poly)
  return false unless rect.all? { |p| point_in_poly?(p, poly) }

  rect_edges = rect.zip(rect.rotate(1))
  poly_edges = poly.zip(poly.rotate(1))

  rect_edges.each do |re|
    poly_edges.each do |pe|
      return false if segments_intersect?(*re, *pe)
    end
  end

  true
end

puts tiles.combination(2)
  .filter { |a, b| rect_inside_poly?(rect_points(a, b), tiles) }
  .map { |a, b| a.area(b) }.max
