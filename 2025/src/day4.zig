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
const common = @import("common");

var scratch_buffer: [1024]u8 = undefined;
pub fn on_render(self: anytype) !void {
    //TODO show exploration of space, either with color or drawing it all
    const str = try std.fmt.bufPrint(&scratch_buffer, "Day 4\nPart 1: {d}\nPart 2: {d}", .{ part1, part2 });
    self.e.renderer.ascii.draw_text(str, 5, 0, common.Colors.GREEN, self.window);
}

pub fn deinit(_: anytype) void {
    if (state != .init) {
        grid.deinit();
    }
}

pub fn update(self: anytype) !void {
    switch (state) {
        .init => {
            try init(self);
        },
        .part1 => {
            try day4_p1();
        },
        .part2 => {
            try day4_p2();
        },
        else => {},
    }
}

pub fn init(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day4/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    grid = std.ArrayList(u8).init(self.allocator);
    w = 0;
    h = 0;
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
}

pub fn start(_: anytype) void {
    switch (state) {
        .done => {
            part1 = 0;
            part2 = 0;
            running = true;
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
var w: usize = 0;
var h: usize = 0;
var grid: std.ArrayList(u8) = undefined;
var running: bool = true;

pub fn day4_p2() !void {
    while (running) {
        running = false;
        outer: for (0..h) |i| {
            for (0..w) |j| {
                if (grid.items[i * w + j] == '@') {
                    var num_adj: u32 = 0;
                    const i_i64: i64 = @bitCast(@as(u64, @intCast(i)));
                    const j_i64: i64 = @bitCast(@as(u64, @intCast(j)));
                    if (at(i_i64 - 1, j_i64 - 1) == '@') num_adj += 1;
                    if (at(i_i64 - 1, j_i64) == '@') num_adj += 1;
                    if (at(i_i64 - 1, j_i64 + 1) == '@') num_adj += 1;
                    if (at(i_i64, j_i64 - 1) == '@') num_adj += 1;
                    if (at(i_i64, j_i64 + 1) == '@') num_adj += 1;
                    if (at(i_i64 + 1, j_i64 - 1) == '@') num_adj += 1;
                    if (at(i_i64 + 1, j_i64) == '@') num_adj += 1;
                    if (at(i_i64 + 1, j_i64 + 1) == '@') num_adj += 1;
                    if (num_adj < 4) {
                        grid.items[i * w + j] = 'x';
                        part2 += 1;
                        running = true;
                        break :outer;
                    }
                }
            }
        }
    }
}

pub fn at(i: i64, j: i64) u8 {
    if (j >= 0 and j < w and i >= 0 and i < h) {
        return grid.items[@as(usize, @intCast(@as(u64, @bitCast(i)))) * w + @as(usize, @intCast(@as(u64, @bitCast(j))))];
    }

    return 0;
}

pub fn day4_p1() !void {
    for (0..h) |i| {
        for (0..w) |j| {
            if (grid.items[i * w + j] == '@') {
                var num_adj: u32 = 0;
                const i_i64: i64 = @bitCast(@as(u64, @intCast(i)));
                const j_i64: i64 = @bitCast(@as(u64, @intCast(j)));
                if (at(i_i64 - 1, j_i64 - 1) == '@') num_adj += 1;
                if (at(i_i64 - 1, j_i64) == '@') num_adj += 1;
                if (at(i_i64 - 1, j_i64 + 1) == '@') num_adj += 1;
                if (at(i_i64, j_i64 - 1) == '@') num_adj += 1;
                if (at(i_i64, j_i64 + 1) == '@') num_adj += 1;
                if (at(i_i64 + 1, j_i64 - 1) == '@') num_adj += 1;
                if (at(i_i64 + 1, j_i64) == '@') num_adj += 1;
                if (at(i_i64 + 1, j_i64 + 1) == '@') num_adj += 1;
                if (num_adj < 4) {
                    part1 += 1;
                }
            }
        }
    }
}
