// --- Day 5: Cafeteria ---
// As the forklifts break through the wall, the Elves are delighted to discover that there was a cafeteria on the other side after all.

// You can hear a commotion coming from the kitchen. "At this rate, we won't have any time left to put the wreaths up in the dining hall!" Resolute in your quest, you investigate.

// "If only we hadn't switched to the new inventory management system right before Christmas!" another Elf exclaims. You ask what's going on.

// The Elves in the kitchen explain the situation: because of their complicated new inventory management system, they can't figure out which of their ingredients are fresh and which are spoiled. When you ask how it works, they give you a copy of their database (your puzzle input).

// The database operates on ingredient IDs. It consists of a list of fresh ingredient ID ranges, a blank line, and a list of available ingredient IDs. For example:

// 3-5
// 10-14
// 16-20
// 12-18

// 1
// 5
// 8
// 11
// 17
// 32
// The fresh ID ranges are inclusive: the range 3-5 means that ingredient IDs 3, 4, and 5 are all fresh. The ranges can also overlap; an ingredient ID is fresh if it is in any range.

// The Elves are trying to determine which of the available ingredient IDs are fresh. In this example, this is done as follows:

// Ingredient ID 1 is spoiled because it does not fall into any range.
// Ingredient ID 5 is fresh because it falls into range 3-5.
// Ingredient ID 8 is spoiled.
// Ingredient ID 11 is fresh because it falls into range 10-14.
// Ingredient ID 17 is fresh because it falls into range 16-20 as well as range 12-18.
// Ingredient ID 32 is spoiled.
// So, in this example, 3 of the available ingredient IDs are fresh.

// Process the database file from the new inventory management system. How many of the available ingredient IDs are fresh?

// --- Part Two ---
// The Elves start bringing their spoiled inventory to the trash chute at the back of the kitchen.

// So that they can stop bugging you when they get new inventory, the Elves would like to know all of the IDs that the fresh ingredient ID ranges consider to be fresh. An ingredient ID is still considered fresh if it is in any range.

// Now, the second section of the database (the available ingredient IDs) is irrelevant. Here are the fresh ingredient ID ranges from the above example:

// 3-5
// 10-14
// 16-20
// 12-18
// The ingredient IDs that these ranges consider to be fresh are 3, 4, 5, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, and 20. So, in this example, the fresh ingredient ID ranges consider a total of 14 ingredient IDs to be fresh.

// Process the database file again. How many ingredient IDs are considered to be fresh according to the fresh ingredient ID ranges?

const std = @import("std");
const common = @import("common");

var scratch_buffer: [1024]u8 = undefined;
pub fn on_render(self: anytype) !void {
    //TODO go through list highlihgting the fresh ids?
    const str = try std.fmt.bufPrint(&scratch_buffer, "Day 5\nPart 1: {d}\nPart 2: {d}", .{ part1, part2 });
    self.e.renderer.ascii.draw_text(str, 5, 0, common.Colors.GREEN, self.window);
}

pub fn deinit(_: anytype) void {
    if (state != .init) {
        ranges.deinit();
        ingredients.deinit();
    }
}

pub fn update(self: anytype) !void {
    switch (state) {
        .init => {
            try init(self);
        },
        .part1 => {
            try day5_p1();
        },
        .part2 => {
            try day5_p2();
        },
        else => {},
    }
}

pub fn init(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day5/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    ranges = std.ArrayList(Range).init(self.allocator);
    ingredients = std.ArrayList(usize).init(self.allocator);
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        if (std.mem.indexOfScalar(u8, line, '-') != null) {
            std.debug.print("{s}\n", .{line});
            var it = std.mem.splitScalar(u8, line, '-');
            try ranges.append(.{ .start = try std.fmt.parseInt(usize, it.next().?, 10), .end = try std.fmt.parseInt(usize, it.next().?, 10) });
        } else {
            try ingredients.append(try std.fmt.parseInt(usize, line, 10));
        }
    }
    std.mem.sort(Range, ranges.items, {}, struct {
        pub fn compare(_: void, lhs: Range, rhs: Range) bool {
            return if (lhs.start == rhs.start) lhs.end < rhs.end else lhs.start < rhs.start;
        }
    }.compare);
}

pub fn start(_: anytype) void {
    switch (state) {
        .done => {
            part1 = 0;
            part2 = 0;
            state = .part1;
        },
        else => {},
    }
}

pub const RunningState = enum {
    init,
    part1,
    part2,
    done,
};

var state: RunningState = .init;
var part1: u64 = 0;
var part2: u64 = 0;
var ranges: std.ArrayList(Range) = undefined;
var ingredients: std.ArrayList(usize) = undefined;

pub const Range = struct {
    start: usize,
    end: usize,
};

pub fn day5_p2() !void {
    part2 = 0;
    var prev_max: usize = 0;
    for (ranges.items) |r| {
        if (prev_max == 0 or prev_max < r.start) {
            part2 += r.end - r.start + 1;
            prev_max = r.end;
        } else {
            if (r.end < prev_max) continue;
            part2 += r.end - prev_max;
            prev_max = r.end;
        }
    }
    std.debug.print("Number of fresh ingredients: {d}\n", .{part2});
}

pub fn print() void {
    std.debug.print("Ranges\n", .{});
    for (ranges.items) |r| {
        std.debug.print("{any}-{any}\n", .{ r.start, r.end });
    }
    std.debug.print("Ingredients\n", .{});
    for (ingredients.items) |i| {
        std.debug.print("{any}\n", .{i});
    }
}

pub fn day5_p1() !void {
    part1 = 0;
    for (ingredients.items) |i| {
        for (ranges.items) |r| {
            if (i >= r.start and i <= r.end) {
                part1 += 1;
                break;
            }
        }
    }
    std.debug.print("Number of fresh ingredients: {d}\n", .{part1});
}
