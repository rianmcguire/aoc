#!/usr/bin/env ruby

def dfs(source:, adjacent_fn:, target_fn:)
  stack = [[source, [source]]]
  paths = []

  while (node, path = stack.pop)
    if target_fn.call(node)
      paths << path
    end

    adjacent_fn.call(node).filter_map do |child|
      next if path.include?(child)

      new_path = path.dup
      new_path << child
      stack.push([child, new_path])
    end
  end

  paths
end

DIRS = %w(^ v < >)

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

Keypad = Struct.new(:grid) do
  def coord(key)
    @coord_memo ||= {}
    @coord_memo[key] ||= (
      grid.each_with_index do |row, y|
        row.each_with_index do |c, x|
          return Pos.new(x, y) if c == key
        end
      end

      raise "Unknown key: #{key.inspect}"
    )
  end

  def key(pos)
    return if pos.y < 0 || pos.y > grid.length - 1
    return if pos.x < 0 || pos.x > grid[0].length - 1

    grid[pos.y][pos.x]
  end

  State = Struct.new(:pos, :last_dir) do
    def ==(other)
      eql?(other)
    end

    def eql?(other)
      pos == other.pos
    end

    def hash
      pos.hash
    end
  end

  def paths(from, to)
    @paths_memo ||= {}
    @paths_memo[[from, to]] ||= (
      all_paths = dfs(
        source: State.new(coord(from), "A"),
        adjacent_fn: proc do |state|
          DIRS.filter_map do |dir|
            new_pos = state.pos.step(dir)
            new_key = key(new_pos)
            next if !new_key || new_key == "."

            State.new(new_pos, dir)
          end
        end,
        target_fn: proc do |state|
          key(state.pos) == to
        end,
      )

      min_length = all_paths.map(&:length).min

      all_paths
        .filter { _1.length == min_length }
        .map do |path|
          path[1..].map(&:last_dir).join
        end
    )
  end
end

NUMERIC = Keypad.new([
  %w(7 8 9),
  %w(4 5 6),
  %w(1 2 3),
  %w(. 0 A),
])

DIRECTIONAL = Keypad.new([
  %w(. ^ A),
  %w(< v >),
])

def cost(from_key, to_key, keypads)
  keypads[0].paths(from_key, to_key).map { |path| path_cost("#{path}A", keypads[1..]) }.min
end

def path_cost(path, keypads)
  return path.length if keypads.empty?

  from = "A"
  sum = 0
  path.chars.each do |c|
    sum += cost(from, c, keypads)
    from = c
  end
  sum
end

codes = ARGF.each_line(chomp: true).to_a

codes.sum do |code|
  code.to_i * path_cost(code, [NUMERIC, *([DIRECTIONAL] * 2)])
end.then { puts _1 }
