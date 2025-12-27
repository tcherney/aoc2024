// --- Day 2: Gift Shop ---
// You get inside and take the elevator to its only other stop: the gift shop. "Thank you for visiting the North Pole!" gleefully exclaims a nearby sign. You aren't sure who is even allowed to visit the North Pole, but you know you can access the lobby through here, and from there you can access the rest of the North Pole base.

// As you make your way through the surprisingly extensive selection, one of the clerks recognizes you and asks for your help.

// As it turns out, one of the younger Elves was playing on a gift shop computer and managed to add a whole bunch of invalid product IDs to their gift shop database! Surely, it would be no trouble for you to identify the invalid product IDs for them, right?

// They've even checked most of the product ID ranges already; they only have a few product ID ranges (your puzzle input) that you'll need to check. For example:

// 11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
// 1698522-1698528,446443-446449,38593856-38593862,565653-565659,
// 824824821-824824827,2121212118-2121212124
// (The ID ranges are wrapped here for legibility; in your input, they appear on a single long line.)

// The ranges are separated by commas (,); each range gives its first ID and last ID separated by a dash (-).

// Since the young Elf was just doing silly patterns, you can find the invalid IDs by looking for any ID which is made only of some sequence of digits repeated twice. So, 55 (5 twice), 6464 (64 twice), and 123123 (123 twice) would all be invalid IDs.

// None of the numbers have leading zeroes; 0101 isn't an ID at all. (101 is a valid ID that you would ignore.)

// Your job is to find all of the invalid IDs that appear in the given ranges. In the above example:

// 11-22 has two invalid IDs, 11 and 22.
// 95-115 has one invalid ID, 99.
// 998-1012 has one invalid ID, 1010.
// 1188511880-1188511890 has one invalid ID, 1188511885.
// 222220-222224 has one invalid ID, 222222.
// 1698522-1698528 contains no invalid IDs.
// 446443-446449 has one invalid ID, 446446.
// 38593856-38593862 has one invalid ID, 38593859.
// The rest of the ranges contain no invalid IDs.
// Adding up all the invalid IDs in this example produces 1227775554.

// What do you get if you add up all of the invalid IDs?

pub const Range = struct {
    start: usize,
    end: usize,
};

const std = @import("std");
const common = @import("common");

pub fn on_render(self: anytype) void {
    //TODO display list, highlight valid green, invalid red, show total being added
    if (state == .part1 or state == .part2) {
        self.e.renderer.ascii.draw_symbol(0, @bitCast(self.window.height / 2), '7', common.Colors.GREEN, self.window);
    }
}

pub fn deinit(_: anytype) void {
    ranges.deinit();
    num_map.deinit();
}

pub const RunningState = enum {
    init,
    part1,
    part2,
    done,
};

pub fn init(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day2/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    ranges = std.ArrayList(Range).init(self.allocator);
    while (try f.reader().readUntilDelimiterOrEof(&buf, ',')) |line| {
        //std.debug.print("{any}\n", .{std.mem.indexOf(u8, line, "-")});
        if (std.mem.indexOf(u8, line, "-") == null) continue;
        std.debug.print("{s}\n", .{line});
        var it = std.mem.splitScalar(u8, line, '-');
        try ranges.append(.{ .start = try std.fmt.parseInt(usize, it.next().?, 10), .end = try std.fmt.parseInt(usize, it.next().?, 10) });
    }
    num_map = std.AutoHashMap(usize, bool).init(self.allocator);
    num_invalid = 0;
    invalid_sum = 0;
    state = .part1;
}

pub fn start() void {
    switch (state) {
        .done => {
            state = .part1;
        },
        else => {},
    }
}

pub fn update(self: anytype) !void {
    switch (state) {
        .part1 => {
            try day2_p1(self);
        },
        .part2 => {
            try day2_p2(self);
        },
        else => {},
    }
}

var seq_scratch: [1024]u8 = undefined;
var cur_seq_scratch: [1024]u8 = undefined;
var cpy_scratch: [1024]u8 = undefined;
var ranges: std.ArrayList(Range) = undefined;
var num_map: std.AutoHashMap(usize, bool) = undefined;
var curr_iter: usize = 0;
var num_invalid: usize = 0;
var invalid_sum: usize = 0;
var state: RunningState = .init;

pub fn day2_p2(self: anytype) !void {
    if (curr_iter >= ranges.items.len) {
        std.debug.print("Part 2: Number of invalid ids {d}, total {d}\n", .{ num_invalid, invalid_sum });
        curr_iter = 0;
        num_invalid = 0;
        invalid_sum = 0;
        state = .done;
        return;
    }
    const r = ranges.items[curr_iter];
    curr_iter += 1;
    var min_digits: usize = 1;
    var max_digits: usize = 1;
    var cur_min = r.start;
    var cur_max = r.end;
    while (@divFloor(cur_min, 10) > 0) {
        cur_min = @divFloor(cur_min, 10);
        min_digits += 1;
    }
    while (@divFloor(cur_max, 10) > 0) {
        cur_max = @divFloor(cur_max, 10);
        max_digits += 1;
    }
    const repeated_len = @divFloor(max_digits, 2);
    const max_seq = std.math.pow(usize, 10, repeated_len + 1);
    const adjust = std.math.pow(usize, 10, repeated_len);
    num_map.clearRetainingCapacity();
    //std.debug.print("Init {any}--{any}--{any}\n", .{ repeated_len, max_seq, adjust });
    //std.debug.print("{any}-{any}", .{ r.start, r.end });
    for (0..max_seq) |i| {
        const val = i + (i * adjust);
        if (val >= r.start and val <= r.end) {
            if (!num_map.contains(val)) {
                var num_digits: usize = 1;
                var cur_val = val;
                while (@divFloor(cur_val, 10) > 0) {
                    cur_val = @divFloor(cur_val, 10);
                    num_digits += 1;
                }
                if (num_digits % 2 == 0) {
                    try num_map.put(val, true);
                    num_invalid += 1;
                    invalid_sum += val;
                    //std.debug.print(" {d}({d})", .{ val, i });
                    continue;
                }
            }
        }
        const string_seq = try std.fmt.bufPrint(&seq_scratch, "{d}", .{i});
        var j = string_seq.len;
        var cur_seq = try std.fmt.bufPrint(&cur_seq_scratch, "{d}", .{i});
        while (j <= max_digits) {
            const cur_cpy = try self.allocator.dupe(u8, cur_seq);
            cur_seq = try std.fmt.bufPrint(&cur_seq_scratch, "{s}{s}", .{ cur_cpy, string_seq });
            self.allocator.free(cur_cpy);
            const num_val = try std.fmt.parseInt(usize, cur_seq, 10);
            if (num_val >= r.start and num_val <= r.end) {
                if (!num_map.contains(num_val)) {
                    try num_map.put(num_val, true);
                    num_invalid += 1;
                    invalid_sum += num_val;
                    //std.debug.print(" {d}({d})", .{ num_val, i });
                    break;
                }
            }
            j += string_seq.len;
        }
    }
    //std.debug.print("\n", .{});
}

pub fn day2_p1(_: anytype) !void {
    if (curr_iter >= ranges.items.len) {
        std.debug.print("Part 1: Number of invalid ids {d}, total {d}\n", .{ num_invalid, invalid_sum });
        curr_iter = 0;
        num_invalid = 0;
        invalid_sum = 0;
        state = .part2;
        return;
    }
    const r = ranges.items[curr_iter];
    curr_iter += 1;
    var min_digits: usize = 1;
    var max_digits: usize = 1;
    var cur_min = r.start;
    var cur_max = r.end;
    while (@divFloor(cur_min, 10) > 0) {
        cur_min = @divFloor(cur_min, 10);
        min_digits += 1;
    }
    while (@divFloor(cur_max, 10) > 0) {
        cur_max = @divFloor(cur_max, 10);
        max_digits += 1;
    }
    const repeated_len = @divFloor(max_digits, 2);
    const max_seq = std.math.pow(usize, 10, repeated_len + 1);
    const adjust = std.math.pow(usize, 10, repeated_len);
    //std.debug.print("Init {any}--{any}--{any}\n", .{ repeated_len, max_seq, adjust });
    //std.debug.print("{any}-{any}", .{ r.start, r.end });
    for (0..max_seq) |i| {
        const val = i + (i * adjust);
        if (val >= r.start and val <= r.end) {
            var num_digits: usize = 1;
            var cur_val = val;
            while (@divFloor(cur_val, 10) > 0) {
                cur_val = @divFloor(cur_val, 10);
                num_digits += 1;
            }
            if (num_digits % 2 == 0) {
                num_invalid += 1;
                invalid_sum += val;
                //std.debug.print(" {d}({d})", .{ val, i });
            }
        }
    }
    //std.debug.print("\n", .{});
}
