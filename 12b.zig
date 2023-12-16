const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();

    var sum: u64 = 0;

    var buf: [128]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitScalar(u8, line, ' ');
        const springs_orig = it.first();
        const counts_str_orig = it.rest();

        // Unfold
        const springs = try std.fmt.allocPrint(allocator, "{s}?{s}?{s}?{s}?{s}", .{ springs_orig, springs_orig, springs_orig, springs_orig, springs_orig });
        const counts_str = try std.fmt.allocPrint(allocator, "{s},{s},{s},{s},{s}", .{ counts_str_orig, counts_str_orig, counts_str_orig, counts_str_orig, counts_str_orig });

        var counts = std.ArrayList(u8).init(allocator);
        var counts_str_it = std.mem.splitScalar(u8, counts_str, ',');
        while (counts_str_it.next()) |count_str| {
            try counts.append(try std.fmt.parseInt(u8, count_str, 10));
        }

        sum += search(springs, counts.items);

        _ = arena.reset(.retain_capacity);
    }

    std.debug.print("{d}\n", .{sum});
}

pub fn search(springs: []const u8, counts: []const u8) u64 {
    if (springs.len > 0 and springs[0] == '.') {
        return search(springs[1..], counts);
    }

    // TODO: memoization

    var leading_springs: usize = 0;
    for (springs, 0..) |s, i| {
        if (s != '#') break;
        leading_springs = i + 1;
    }
    const complete_group = leading_springs > 0 and (leading_springs > springs.len - 1 or springs[leading_springs] == '.');

    var result: u64 = undefined;
    if (springs.len == 0 and counts.len == 0) {
        result = 1;
    } else if (springs.len == 0 and counts.len > 0) {
        result = 0;
    } else if (leading_springs > 0 and (counts.len == 0 or leading_springs > counts[0])) {
        result = 0;
    } else if (complete_group) {
        if (leading_springs == counts[0]) {
            result = search(springs[counts[0]..], counts[1..]);
        } else {
            result = 0;
        }
    } else {
        const unknown_idx = for (springs, 0..) |s, i| {
            if (s == '?') break i;
        } else {
            std.debug.panic("wtf: {s}", .{springs});
        };

        var with_working: [128]u8 = undefined;
        std.mem.copy(u8, &with_working, springs);
        with_working[unknown_idx] = '.';

        var with_broken: [128]u8 = undefined;
        std.mem.copy(u8, &with_broken, springs);
        with_broken[unknown_idx] = '#';

        result = search(with_working[0..springs.len], counts) + search(with_broken[0..springs.len], counts);
    }

    return result;
}
