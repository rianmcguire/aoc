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

def print_frames(frames)
    x_range = -50..50
    y_range = -50..50

    y_range.each do |y|
        x_range.each do |x|
            if frames.include?([x, y])
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
last_total = 0
last_delta = 0
last_delta_delta = 0
step = 0
loop do
    step += 1
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
            known_transitions[key] = [new_compact_frames.fetch(frame), outs[frame]]
        end
    end

    compact_frames = new_compact_frames

    # puts "\e[H\e[2J"
    # print_frames(compact_frames)

    period = 131
    if ((step - 458) % period == 0)
        puts "#{step}"
        total = compact_frames.values.map { $frame_sizes[_1] }.sum
        delta = total - last_total
        delta_delta = delta - last_delta
        puts "total: #{total} delta #{delta}, delta delta #{delta_delta}"

        if delta_delta == last_delta_delta
            # We can project from here
            target_step = 26501365
            periods = (target_step - step) / period
            puts total + delta * periods + delta_delta * (periods * (periods + 1) / 2)
            exit
        end

        last_total = total
        last_delta = delta
        last_delta_delta = delta_delta
    end
end
