#!/usr/bin/env ruby

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

    def normalize
        Pos.new(x % (X_RANGE.max + 1), y % (Y_RANGE.max + 1))
    end

    def valid?
        n_pos = normalize
        (GRID[n_pos.y][n_pos.x] == "." || GRID[n_pos.y][n_pos.x] == "S")
    end

    def frame
        [x / (X_RANGE.max + 1), y / (Y_RANGE.max + 1)]
    end

    # def frame_shift(frame)
    #     Pos.new(x - frame[0] * (X_RANGE.max + 1), y - frame[1] * (Y_RANGE.max + 1))
    # end
end

DIRS = [:n, :s, :e, :w]

starting_pos = nil
GRID = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map do |c, x|
        if c == "S"
            starting_pos = Pos.new(x, y)
        end
        c
    end
end

Y_RANGE = (0..GRID.length - 1)
X_RANGE = (0..GRID.first.length - 1)

$next_id = 0
$frame_ids = {}
$frames_by_id = {}
$frame_sizes = {}
def cache_frame(positions)
    if $frame_ids.include?(positions)
        $frame_ids[positions]
    else
        id = ($next_id += 1)
        $frame_ids[positions] = id
        $frames_by_id[id] = positions
        $frame_sizes[id] = positions.length
        id
    end
end
null_frame = cache_frame(Set.new)
initial_frame = cache_frame( Set.new([starting_pos]))
compact_frames = {
    [0, 0] => initial_frame,
}

$oscilating = {}

def print_frames(frames)
    # x_range = Range.new(*frames.keys.map(&:first).minmax)
    # y_range = Range.new(*frames.keys.map(&:last).minmax)
    x_range = -50..50
    y_range = -50..50

    # pp x_range, y_range

    y_range.each do |y|
        x_range.each do |x|
            if $oscilating.include?([x, y])
                $stdout.write " ---- "
            elsif frames.include?([x, y])
                id = frames[[x, y]]
                size = $frame_sizes[id]
                $stdout.write " #{id.to_s.rjust(4, ' ')} "
            else
                $stdout.write "      "
            end
        end
        puts
    end
end

known_transitions = {}
last_frames = nil
last_step = nil
100.times do |step|
    new_positions = Hash.new { |h,k| h[k] = Set.new }
    outs = Hash.new { |h,k| h[k] = Set.new }
    skip_outs = Set.new
    new_compact_frames = {}
    compact_frames.each do |frame, id|
        key = [id, *DIRS.map { compact_frames.fetch(Pos.new(*frame).step(_1).to_a, null_frame) }]

        if known_transitions.include?(key)
            new_compact_frames[frame], outs[frame] = known_transitions[key]
            skip_outs << frame
        else
            positions = $frames_by_id.fetch(id)
            positions.each do |pos|
                DIRS.each do |dir|
                    new_pos = pos.step(dir)
                    next unless new_pos.valid?

                    if new_pos.frame == [0, 0]
                        new_positions[frame] << new_pos
                    else
                        outs[frame] << new_pos
                    end
                end
            end
        end
    end

    outs.each do |source_frame, positions|
        positions.each do |new_pos|
            dest_frame = new_pos.frame.zip(source_frame).map { |a,b| a + b }
            if !skip_outs.include?(dest_frame)
                # puts "applying outs"
                new_positions[dest_frame] << new_pos.normalize
            end
        end
    end

    new_positions.each do |frame, positions|
        new_compact_frames[frame] = cache_frame(positions)
    end

    compact_frames.each do |frame, id|
        key = [id, *DIRS.map { compact_frames.fetch(Pos.new(*frame).step(_1).to_a, null_frame) }]

        if !known_transitions.include?(key)
            # puts "saving new transition"
            known_transitions[key] = [new_compact_frames.fetch(frame), outs[frame]]
        end
    end

    puts "\e[H\e[2J"

    to_delete = []
    if last_frames
        last_frames.each do |frame, old_id|
            neighbours = DIRS.map { Pos.new(*frame).step(_1).to_a }
            last_key = [old_id, *neighbours.map { last_frames.fetch(_1, null_frame) }]
            new_id = new_compact_frames[frame]
            new_key = [new_id, *neighbours.map { new_compact_frames.fetch(_1, null_frame) }]

            if new_key == last_key
                # puts "oscilating #{frame}"
                # $oscilating[frame] = [old_id, new_id, step]
                # to_delete << frame
            end
        end
    end

    to_delete.each do |f|
        new_compact_frames.delete f
    end

    last_frames = compact_frames
    compact_frames = new_compact_frames

    total = compact_frames.values.map { $frame_sizes[_1] }.sum
    puts "after step #{step} frames #{compact_frames.length} total #{total} (cache #{$frames_by_id.length} transitions #{known_transitions.length})"
    # # osc_totals = compact_frames.values.filter { _1 == 45 || _1 == 37 }.map { $frame_sizes[_1] }.sum
    # # puts "osc total #{osc_totals}"
    # puts "size 37 #{$frame_sizes[37]}"
    # puts "size 45 #{$frame_sizes[45]}"
    print_frames(compact_frames)

    # if compact_frames.length != last_frame_count
    #     puts "frame count changed #{last_frame_count} -> #{compact_frames.length} delta #{compact_frames.length - last_frame_count}"
    #     puts "total changed #{last_total} -> #{total} delta #{total - last_total}"

    #     last_frame_count = compact_frames.length
    #     last_total = total
    # end
    last_step = step
end

# pp known_transitions.length

puts "frame cache size: #{$frames_by_id.length}"

total = compact_frames.values.map { $frame_sizes[_1] }.sum

osc_total = $oscilating.map do |frame, values|
    old_id, new_id, step = values

    id = if step % 2 == last_step % 2
        old_id
    else
        new_id
    end
    
    $frame_sizes[id]
end.sum

puts total + osc_total
