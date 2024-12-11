const std = @import("std");
// https://adventofcode.com/2024/day/11
// --- Day 11: Plutonian Pebbles ---
// The ancient civilization on Pluto was known for its ability to manipulate spacetime, and while The Historians explore their infinite corridors, you've noticed a strange set of physics-defying stones.

// At first glance, they seem like normal stones: they're arranged in a perfectly straight line, and each stone has a number engraved on it.

// The strange part is that every time you blink, the stones change.

// Sometimes, the number engraved on a stone changes. Other times, a stone might split in two, causing all the other stones to shift over a bit to make room in their perfectly straight line.

// As you observe them for a while, you find that the stones have a consistent behavior. Every time you blink, the stones each simultaneously change according to the first applicable rule in this list:

// If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
// If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
// If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.
// No matter how the stones change, their order is preserved, and they stay on their perfectly straight line.

// How will the stones evolve if you keep blinking at them? You take a note of the number engraved on each stone in the line (your puzzle input).

// If you have an arrangement of five stones engraved with the numbers 0 1 10 99 999 and you blink once, the stones transform as follows:

// The first stone, 0, becomes a stone marked 1.
// The second stone, 1, is multiplied by 2024 to become 2024.
// The third stone, 10, is split into a stone marked 1 followed by a stone marked 0.
// The fourth stone, 99, is split into two stones marked 9.
// The fifth stone, 999, is replaced by a stone marked 2021976.
// So, after blinking once, your five stones would become an arrangement of seven stones engraved with the numbers 1 2024 1 0 9 9 2021976.

// Here is a longer example:

// Initial arrangement:
// 125 17

// After 1 blink:
// 253000 1 7

// After 2 blinks:
// 253 0 2024 14168

// After 3 blinks:
// 512072 1 20 24 28676032

// After 4 blinks:
// 512 72 2024 2 0 2 4 2867 6032

// After 5 blinks:
// 1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32

// After 6 blinks:
// 2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2
// In this example, after blinking six times, you would have 22 stones. After blinking 25 times, you would have 55312 stones!

// Consider the arrangement of stones in front of you. How many stones will you have after blinking 25 times?
var num_buf: [1024]u8 = undefined;
pub fn naive(file_name: []const u8, allocator: std.mem.Allocator, ITERATIONS: u64) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var stones = std.ArrayList(u64).init(allocator);
    defer stones.deinit();
    if (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var it = std.mem.splitScalar(u8, line, ' ');
        while (it.next()) |num| {
            try stones.append(try std.fmt.parseInt(u64, num, 10));
        }
        for (0..ITERATIONS) |_| {
            const previous_len = stones.items.len;
            var i: usize = 0;
            for (0..previous_len) |_| {
                const num_as_string = try std.fmt.bufPrint(&num_buf, "{d}", .{stones.items[i]});
                if (stones.items[i] == 0) {
                    stones.items[i] = 1;
                    i += 1;
                } else if (num_as_string.len % 2 == 0) {
                    stones.items[i] = try std.fmt.parseInt(u64, num_as_string[0 .. num_as_string.len / 2], 10);
                    try stones.insert(i + 1, try std.fmt.parseInt(u64, num_as_string[num_as_string.len / 2 ..], 10));
                    i += 2;
                } else {
                    stones.items[i] *= 2024;
                    i += 1;
                }
            }
        }
    }

    return stones.items.len;
}
pub const Score = struct {
    stones: u64,
    iterations: u64,
};
var score_cache: std.AutoHashMap(Score, u64) = undefined;
pub fn score(n: u64, iterations: u64) !u64 {
    //std.debug.print("called with value {d} on iteration {d}\n", .{ n, iterations });
    const current_score = Score{ .stones = n, .iterations = iterations };
    var calc_val: u64 = undefined;
    if (!score_cache.contains(current_score)) {
        const num_as_string = try std.fmt.bufPrint(&num_buf, "{d}", .{n});
        if (n == 0) {
            if (iterations == 0) {
                calc_val = 1;
            } else {
                calc_val = try score(n + 1, iterations - 1);
                //std.debug.print("returned path 3 value {d}, iteration {d}\n", .{ n, iterations });
            }
        } else if (num_as_string.len % 2 == 0) {
            if (iterations == 0) {
                calc_val = 1;
            } else {
                const left = try std.fmt.parseInt(u64, num_as_string[0 .. num_as_string.len / 2], 10);
                const right = try std.fmt.parseInt(u64, num_as_string[num_as_string.len / 2 ..], 10);
                //std.debug.print("splitting num {s} left {d} right {d}\n", .{ num_as_string, left, right });
                calc_val = try score(left, iterations - 1) + try score(right, iterations - 1);
                //std.debug.print("returned path 2 value {d}, iteration {d}\n", .{ n, iterations });
            }
        } else {
            if (iterations == 0) {
                calc_val = 1;
            } else {
                calc_val = try score(n * 2024, iterations - 1);
                //std.debug.print("returned path 3 value {d}, iteration {d}\n", .{ n, iterations });
            }
        }
        try score_cache.put(current_score, calc_val);
    } else {
        calc_val = score_cache.get(current_score).?;
        //std.debug.print("key exits 3 value {d}, iteration {d}\n", .{ n, iterations });
    }
    //std.debug.print("exiting value {d}, iteration {d}\n", .{ n, iterations });
    return calc_val;
}

// --- Part Two ---
// The Historians sure are taking a long time. To be fair, the infinite corridors are very large.

// How many stones would you have after blinking a total of 75 times?

pub fn mem_cache(file_name: []const u8, allocator: std.mem.Allocator, ITERATIONS: u64) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var stones = std.ArrayList(u64).init(allocator);
    defer stones.deinit();
    var result: u64 = 0;
    if (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var it = std.mem.splitScalar(u8, line, ' ');
        while (it.next()) |num| {
            try stones.append(try std.fmt.parseInt(u64, num, 10));
        }
        score_cache = std.AutoHashMap(Score, u64).init(allocator);
        defer score_cache.deinit();
        for (0..stones.items.len) |i| {
            result += try score(stones.items[i], ITERATIONS);
        }
    }

    return result;
}
test "day11" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Number of stones after 25 blinks {d} in {d}ms\n", .{ try mem_cache("inputs/day11/input.txt", allocator, 25), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Number of stones after 75 blinks {d} in {d}ms\n", .{ try mem_cache("inputs/day11/input.txt", allocator, 75), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
