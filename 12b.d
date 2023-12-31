module main;
import std.stdio;
import std.array;
import std.algorithm.iteration;
import std.conv;
import std.format;
import std.range;

void main(string[] args)
{
    long sum = 0;

    auto f = File(args[1], "r");
    long[MemoKey] memo;
    foreach (string line; lines(f))
    {
        auto parts = line.splitter(' ');
        auto springs_orig = parts.front();
        parts.popFront();
        auto counts_str_orig = parts.front();

        auto springs = format("%s?%s?%s?%s?%s", springs_orig, springs_orig, springs_orig, springs_orig, springs_orig);
        auto counts_str = format("%s,%s,%s,%s,%s", counts_str_orig, counts_str_orig, counts_str_orig, counts_str_orig, counts_str_orig);

        ubyte[] counts;
        foreach (string s; counts_str.splitter(","))
        {
            counts ~= parse!ubyte(s);
        }

        memo.clear();
        sum += search(springs, counts, 0, 0, &memo);
    }

    writefln("%d", sum);
}

struct MemoKey {
    size_t springs_len;
    size_t counts_len;
    ushort working_mask;
    ushort broken_mask;
}

long search(string springs, ubyte[] counts, ushort working_mask, ushort broken_mask, long[MemoKey]* memo)
{
    // Skip over leading "." - they don't affect the result
    if (springs.length > 0 && springs[0] == '.' || (working_mask & 1) == 1)
    {
        return search(springs[1..springs.length], counts, working_mask >> 1, broken_mask >> 1, memo);
    }

    // Check memoization hash table
    MemoKey memo_key = { springs_len: springs.length, counts_len: counts.length, working_mask: working_mask, broken_mask: broken_mask };
    if (auto result = memo_key in *memo) {
        return *result;
    }

    size_t leading_springs = 0;
    ushort search_mask = 1;
    foreach (i, s; springs) {
        if (s != '#' && (search_mask & broken_mask) == 0) break;
        leading_springs = i + 1;
        search_mask <<= 1;
    }

    // Is this group of leading broken springs complete, or could it get longer?
    auto complete_group = leading_springs > 0 && (leading_springs > springs.length - 1 || // the group is at the end of the string
        springs[leading_springs] == '.' || // the spring after is working (in the string)
        (working_mask & (1 << leading_springs)) != 0 // the spring after is work (in the mask)
    );

    long result;

    if (springs.length == 0 && counts.length == 0) {
        // Base case - we've matched everything!
        result = 1;
    } else if (springs.length == 0 && counts.length > 0) {
        // There are no possible springs left, but there are unmatched counts
        result = 0;
    } else if (leading_springs > 0 && (counts.length == 0 || leading_springs > counts[0])) {
        // Leading number of springs is bigger than the expected count - this will never match
        result = 0;
    } else if (complete_group) {
        // Matched a complete group - check the size
        if (leading_springs == counts[0]) {
            // Matched the first count - trim it off and go deeper
            result = search(springs[counts[0]..springs.length], counts[1..counts.length], working_mask >> counts[0], broken_mask >> counts[0], memo);
        } else {
            // Group was a different size - this will never match
            result = 0;
        }
    } else {
        search_mask = 1;
        foreach (s; springs) {
            if (s == '?' && (search_mask & (working_mask | broken_mask)) == 0) break;
            search_mask <<= 1;
        }

        // Explore both options for unknown value
        const with_working = search(springs, counts, working_mask | search_mask, broken_mask, memo);
        const with_broken = search(springs, counts, working_mask, broken_mask | search_mask, memo);

        result = with_working + with_broken;
    }

    (*memo)[memo_key] = result;

    return result;
}
