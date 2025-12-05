// --- Day 4: Printing Department ---
// You ride the escalator down to the printing department. They're clearly getting ready for Christmas; they have lots of large rolls of paper everywhere, and there's even a massive printer in the corner (to handle the really big print jobs).

// Decorating here will be easy: they can make their own decorations. What you really need is a way to get further into the North Pole base while the elevators are offline.

// "Actually, maybe we can help with that," one of the Elves replies when you ask for help. "We're pretty sure there's a cafeteria on the other side of the back wall. If we could break through the wall, you'd be able to keep moving. It's too bad all of our forklifts are so busy moving those big rolls of paper around."

// If you can optimize the work the forklifts are doing, maybe they would have time to spare to break through the wall.

// The rolls of paper (@) are arranged on a large grid; the Elves even have a helpful diagram (your puzzle input) indicating where everything is located.

// For example:

// ..@@.@@@@.
// @@@.@.@.@@
// @@@@@.@.@@
// @.@@@@..@.
// @@.@@@@.@@
// .@@@@@@@.@
// .@.@.@.@@@
// @.@@@.@@@@
// .@@@@@@@@.
// @.@.@@@.@.
// The forklifts can only access a roll of paper if there are fewer than four rolls of paper in the eight adjacent positions. If you can figure out which rolls of paper the forklifts can access, they'll spend less time looking and more time breaking down the wall to the cafeteria.

// In this example, there are 13 rolls of paper that can be accessed by a forklift (marked with x):

// ..xx.xx@x.
// x@@.@.@.@@
// @@@@@.x.@@
// @.@@@@..@.
// x@.@@@@.@x
// .@@@@@@@.@
// .@.@.@.@@@
// x.@@@.@@@@
// .@@@@@@@@.
// x.x.@@@.x.
// Consider your complete diagram of the paper roll locations. How many rolls of paper can be accessed by a forklift?

const std = @import("std");
pub fn day4_p2(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day4/input.txt", .{});
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
    var total: u64 = 0;
    var running: bool = true;
    while (running) {
        running = false;
        outer: for (0..h) |i| {
            for (0..w) |j| {
                if (grid.items[i * w + j] == '@') {
                    var num_adj: u32 = 0;
                    const i_i64: i64 = @bitCast(i);
                    const j_i64: i64 = @bitCast(j);
                    if (at(grid, w, h, i_i64 - 1, j_i64 - 1) == '@') num_adj += 1;
                    if (at(grid, w, h, i_i64 - 1, j_i64) == '@') num_adj += 1;
                    if (at(grid, w, h, i_i64 - 1, j_i64 + 1) == '@') num_adj += 1;
                    if (at(grid, w, h, i_i64, j_i64 - 1) == '@') num_adj += 1;
                    if (at(grid, w, h, i_i64, j_i64 + 1) == '@') num_adj += 1;
                    if (at(grid, w, h, i_i64 + 1, j_i64 - 1) == '@') num_adj += 1;
                    if (at(grid, w, h, i_i64 + 1, j_i64) == '@') num_adj += 1;
                    if (at(grid, w, h, i_i64 + 1, j_i64 + 1) == '@') num_adj += 1;
                    if (num_adj < 4) {
                        grid.items[i * w + j] = 'x';
                        total += 1;
                        running = true;
                        break :outer;
                    }
                }
            }
        }
    }
    std.debug.print("Total accessible rolls: {d}\n", .{total});
}

pub fn at(grid: std.ArrayList(u8), w: usize, h: usize, i: i64, j: i64) u8 {
    if (j >= 0 and j < w and i >= 0 and i < h) {
        return grid.items[@as(usize, @bitCast(i)) * w + @as(usize, @bitCast(j))];
    }

    return 0;
}

pub fn day4_p1(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day4/input.txt", .{});
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
    var total: u64 = 0;
    for (0..h) |i| {
        for (0..w) |j| {
            if (grid.items[i * w + j] == '@') {
                var num_adj: u32 = 0;
                const i_i64: i64 = @bitCast(i);
                const j_i64: i64 = @bitCast(j);
                if (at(grid, w, h, i_i64 - 1, j_i64 - 1) == '@') num_adj += 1;
                if (at(grid, w, h, i_i64 - 1, j_i64) == '@') num_adj += 1;
                if (at(grid, w, h, i_i64 - 1, j_i64 + 1) == '@') num_adj += 1;
                if (at(grid, w, h, i_i64, j_i64 - 1) == '@') num_adj += 1;
                if (at(grid, w, h, i_i64, j_i64 + 1) == '@') num_adj += 1;
                if (at(grid, w, h, i_i64 + 1, j_i64 - 1) == '@') num_adj += 1;
                if (at(grid, w, h, i_i64 + 1, j_i64) == '@') num_adj += 1;
                if (at(grid, w, h, i_i64 + 1, j_i64 + 1) == '@') num_adj += 1;
                if (num_adj < 4) {
                    total += 1;
                }
            }
        }
    }
    std.debug.print("Total accessible rolls: {d}\n", .{total});
}
