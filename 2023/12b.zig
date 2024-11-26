const std = @import("std");

const SPRINGS_MAX = 128;
const HASH_TABLE_CAPACITY = 8192;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    var sum: u64 = 0;

    var args_it = std.process.args();
    _ = args_it.skip();

    const filename = args_it.next() orelse std.debug.panic("No filename", .{});
    const file = try std.fs.cwd().openFile(filename, .{});

    var buf: [SPRINGS_MAX]u8 = undefined;
    var reader = file.reader();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
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
        memo.ensureTotalCapacity(HASH_TABLE_CAPACITY) catch |err| std.debug.panic("{any}", .{err});
        sum += search(springs, counts.items, 0, 0, &memo);

        _ = arena.reset(.retain_capacity);
    }

    std.debug.print("{d}\n", .{sum});
}

const MemoKey = struct {
    springs_len: usize,
    counts_len: usize,
    working_mask: u16,
    broken_mask: u16,
};

const MemoHashMap = std.AutoHashMap(MemoKey, u64);

pub fn search(springs: []u8, counts: []const u8, working_mask: u16, broken_mask: u16, memo: *MemoHashMap) u64 {
    // Skip over leading "." - they don't affect the result
    if (springs.len > 0 and springs[0] == '.' or working_mask & 1 == 1) {
        return search(springs[1..], counts, working_mask >> 1, broken_mask >> 1, memo);
    }

    // Check memoization hash table
    const memo_key = MemoKey{ .springs_len = springs.len, .counts_len = counts.len, .working_mask = working_mask, .broken_mask = broken_mask };
    if (memo.get(memo_key)) |result| {
        return result;
    }

    var leading_springs: usize = 0;
    var search_mask: u16 = 1;
    for (springs, 0..) |s, i| {
        if (s != '#' and search_mask & broken_mask == 0) break;
        leading_springs = i + 1;
        search_mask <<= 1;
    }

    // Is this group of leading broken springs complete, or could it get longer?
    const complete_group = leading_springs > 0 and (leading_springs > springs.len - 1 or // the group is at the end of the string
        springs[leading_springs] == '.' or // the spring after is working (in the string)
        working_mask & (@as(u16, 1) << @truncate(leading_springs)) != 0 // the spring after is work (in the mask)
    );

    var result: u64 = undefined;
    if (springs.len == 0 and counts.len == 0) {
        // Base case - we've matched everything!
        result = 1;
    } else if (springs.len == 0 and counts.len > 0) {
        // There are no possible springs left, but there are unmatched counts
        result = 0;
    } else if (leading_springs > 0 and (counts.len == 0 or leading_springs > counts[0])) {
        // Leading number of springs is bigger than the expected count - this will never match
        result = 0;
    } else if (complete_group) {
        // Matched a complete group - check the size
        if (leading_springs == counts[0]) {
            // Matched the first count - trim it off and go deeper
            result = search(springs[counts[0]..], counts[1..], working_mask >> @truncate(counts[0]), broken_mask >> @truncate(counts[0]), memo);
        } else {
            // Group was a different size - this will never match
            result = 0;
        }
    } else {
        search_mask = 1;
        for (springs) |s| {
            if (s == '?' and search_mask & (working_mask | broken_mask) == 0) break;
            search_mask <<= 1;
        } else {
            std.debug.panic("wtf: {s}", .{springs});
        }

        // Explore both options for unknown value
        const with_working = search(springs, counts, working_mask | search_mask, broken_mask, memo);
        const with_broken = search(springs, counts, working_mask, broken_mask | search_mask, memo);

        result = with_working + with_broken;
    }

    memo.putAssumeCapacity(memo_key, result);

    return result;
}
