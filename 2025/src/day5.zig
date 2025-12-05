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

const std = @import("std");

pub const Range = struct {
    start: usize,
    end: usize,
};

pub fn day5_p2(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day5/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var grid = std.ArrayList(u8).init(self.allocator);
    defer grid.deinit();
    var w: usize = 0;
    var h: usize = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        h += 1;
        w = line.len;
        for (line) |c| {
            try grid.append(c);
        }
    }
    std.debug.print("Grid\n", .{});
    for (0..h) |i| {
        for (0..w) |j| {
            std.debug.print("{c}", .{grid.items[i * w + j]});
        }
        std.debug.print("\n", .{});
    }
}

pub fn day5_p1(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day5/small.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var ranges = std.ArrayList(Range).init(self.allocator);
    defer ranges.deinit();
    var ingredients = std.ArrayList(usize).init(self.allocator);
    defer ingredients.deinit();
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
    std.debug.print("Ranges\n", .{});
    for (ranges.items) |r| {
        std.debug.print("{any}-{any}\n", .{ r.start, r.end });
    }
    std.debug.print("Ingredients\n", .{});
    for (ingredients.items) |i| {
        std.debug.print("{any}\n", .{i});
    }
}
