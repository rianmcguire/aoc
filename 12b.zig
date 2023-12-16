const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();

    var sum: u64 = 0;

    var buf: [128]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();

        var it = std.mem.splitScalar(u8, line, ' ');
        const springs = it.first();
        const counts_str = it.rest();

        // TODO: unfold

        var counts = std.ArrayList(u8).init(allocator);
        var counts_str_it = std.mem.splitScalar(u8, counts_str, ',');
        while (counts_str_it.next()) |count_str| {
            try counts.append(try std.fmt.parseInt(u8, count_str, 10));
        }

        std.debug.print("{s} {d}\n", .{ springs, counts.items.len });

        sum += search(springs, counts.items);
    }

    std.debug.print("{d}\n", .{sum});
}

pub fn search(springs: []const u8, counts: []const u8) u64 {
    if (springs[0] == '.') {
        return search(springs[1..], counts);
    }

    // TODO: memoization

    const leading_springs: usize = for (springs, 0..) |s, i| {
        if (s != '#') break i;
    } else {
        0
    };
    const complete_group = leading_springs > 0 and (springs.len == 0 or springs[0] == '.');

    const result = if (springs.len == 0 and counts.len == 0) {
        0;
    } else if (springs.len == 0 and counts.len > 0) {
        0;
    } else if (complete_group) {
        if (leading_springs == counts[0]) {
            search(springs[counts[0]..], counts[1..]);
        } else {
            0;
        }
    } else {
        const unknown_idx = for (springs, 0..) |s, i| {
            if (s == '?') break i;
        } else {
            std.debug.panic("wtf", .{});
        };

        var with_working: [128]u8 = undefined;
        std.mem.copy(u8, with_working, springs);
        with_working[unknown_idx] = '.';

        var with_broken: [128]u8 = undefined;
        std.mem.copy(u8, with_broken, springs);
        with_broken[unknown_idx] = '#';

        search(with_working, counts) + search(with_broken, counts);
    };

    return result;
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
