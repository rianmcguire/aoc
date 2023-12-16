const std = @import("std");

const SPRINGS_MAX = 128;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    var sum: u64 = 0;

    var buf: [SPRINGS_MAX]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
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

        var memo = MemoHashMap.init(allocator);
        sum += search(springs, counts.items, &memo);

        _ = arena.reset(.retain_capacity);
    }

    std.debug.print("{d}\n", .{sum});
}

const MemoKey = struct {
    springs: []const u8,
    counts_len: usize,
};

const MemoKeyContext = struct {
    pub fn hash(self: @This(), key: MemoKey) u64 {
        _ = self;
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(key.springs);
        hasher.update(std.mem.asBytes(&key.counts_len));
        return hasher.final();
    }

    pub fn eql(self: @This(), a: MemoKey, b: MemoKey) bool {
        _ = self;
        return std.mem.eql(u8, a.springs, b.springs) and a.counts_len == b.counts_len;
    }
};

const MemoHashMap = std.HashMap(MemoKey, u64, MemoKeyContext, 80);

pub fn search(springs: []const u8, counts: []const u8, memo: *MemoHashMap) u64 {
    if (springs.len > 0 and springs[0] == '.') {
        return search(springs[1..], counts, memo);
    }

    if (memo.get(MemoKey{ .springs = springs, .counts_len = counts.len })) |result| {
        return result;
    }

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
            result = search(springs[counts[0]..], counts[1..], memo);
        } else {
            result = 0;
        }
    } else {
        const unknown_idx = for (springs, 0..) |s, i| {
            if (s == '?') break i;
        } else {
            std.debug.panic("wtf: {s}", .{springs});
        };

        var with_working_buf: [SPRINGS_MAX]u8 = undefined;
        var with_working = with_working_buf[0..springs.len];
        @memcpy(with_working, springs);
        with_working[unknown_idx] = '.';

        var with_broken_buf: [SPRINGS_MAX]u8 = undefined;
        var with_broken = with_broken_buf[0..springs.len];
        @memcpy(with_broken, springs);
        with_broken[unknown_idx] = '#';

        result = search(with_working, counts, memo) + search(with_broken, counts, memo);
    }

    const springs_alloc = memo.allocator.dupe(u8, springs) catch |err| std.debug.panic("{any}", .{err});
    const memoKey = MemoKey{ .springs = springs_alloc, .counts_len = counts.len };
    memo.put(memoKey, result) catch |err| std.debug.panic("{any}", .{err});

    return result;
}
