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
  # Out of all possible directional paths between from_key and to_key, use the path that's cheapest to enter on the keypad above
  @cost_memo ||= {}
  @cost_memo[[from_key, to_key, keypads]] ||= (
    keypads[0].paths(from_key, to_key).map { |path| seq_cost("#{path}A", keypads[1..]) }.min
  )
end

# Number of keypresses required to input `seq` through the stack of `keypads`
def seq_cost(seq, keypads)
  # If there are no further keypad above, the sequence will be entered by the human, and the cost is the number of keys in the sequence
  return seq.length if keypads.empty?

  # Starting at "A", sum up the cost to move between each of the keys in seq
  ["A", *seq.chars].each_cons(2).sum do |from, to|
    cost(from, to, keypads)
  end
end

codes = ARGF.each_line(chomp: true).to_a

codes.sum do |code|
  code.to_i * seq_cost(code, [NUMERIC, *([DIRECTIONAL] * 25)])
end.then { puts _1 }
