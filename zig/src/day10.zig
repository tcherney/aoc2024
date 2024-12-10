const std = @import("std");
// https://adventofcode.com/2024/day/10
// --- Day 10: Hoof It ---
// You all arrive at a Lava Production Facility on a floating island in the sky. As the others begin to search the massive industrial complex, you feel a small nose boop your leg and look down to discover a reindeer wearing a hard hat.

// The reindeer is holding a book titled "Lava Island Hiking Guide". However, when you open the book, you discover that most of it seems to have been scorched by lava! As you're about to ask how you can help, the reindeer brings you a blank topographic map of the surrounding area (your puzzle input) and looks up at you excitedly.

// Perhaps you can help fill in the missing hiking trails?

// The topographic map indicates the height at each position using a scale from 0 (lowest) to 9 (highest). For example:

// 0123
// 1234
// 8765
// 9876
// Based on un-scorched scraps of the book, you determine that a good hiking trail is as long as possible and has an even, gradual, uphill slope. For all practical purposes, this means that a hiking trail is any path that starts at height 0, ends at height 9, and always increases by a height of exactly 1 at each step. Hiking trails never include diagonal steps - only up, down, left, or right (from the perspective of the map).

// You look up from the map and notice that the reindeer has helpfully begun to construct a small pile of pencils, markers, rulers, compasses, stickers, and other equipment you might need to update the map with hiking trails.

// A trailhead is any position that starts one or more hiking trails - here, these positions will always have height 0. Assembling more fragments of pages, you establish that a trailhead's score is the number of 9-height positions reachable from that trailhead via a hiking trail. In the above example, the single trailhead in the top left corner has a score of 1 because it can reach a single 9 (the one in the bottom left).

// This trailhead has a score of 2:

// ...0...
// ...1...
// ...2...
// 6543456
// 7.....7
// 8.....8
// 9.....9
// (The positions marked . are impassable tiles to simplify these examples; they do not appear on your actual topographic map.)

// This trailhead has a score of 4 because every 9 is reachable via a hiking trail except the one immediately to the left of the trailhead:

// ..90..9
// ...1.98
// ...2..7
// 6543456
// 765.987
// 876....
// 987....
// This topographic map contains two trailheads; the trailhead at the top has a score of 1, while the trailhead at the bottom has a score of 2:

// 10..9..
// 2...8..
// 3...7..
// 4567654
// ...8..3
// ...9..2
// .....01
// Here's a larger example:

// 89010123
// 78121874
// 87430965
// 96549874
// 45678903
// 32019012
// 01329801
// 10456732
// This larger example has 9 trailheads. Considering the trailheads in reading order, they have scores of 5, 6, 5, 3, 1, 3, 5, 3, and 5. Adding these scores together, the sum of the scores of all trailheads is 36.

// The reindeer gleefully carries over a protractor and adds it to the pile. What is the sum of the scores of all trailheads on your topographic map?
pub const Location = struct {
    x: i64,
    y: i64,

    fn init(indx: usize, width: usize) Location {
        const x = @as(i64, @bitCast(indx % width));
        return .{
            .x = x,
            .y = @as(i64, @bitCast(@divFloor(@as(i64, @bitCast(indx)) - @as(i64, @bitCast(x)), @as(i64, @bitCast(width))))),
        };
    }
    fn to_indx(loc: *const Location, width: usize) usize {
        return @as(usize, @bitCast(loc.y)) * width + @as(usize, @bitCast(loc.x));
    }
};
pub fn dfs_setup(map: []const u8, width: usize, height: usize, allocator: std.mem.Allocator) !u64 {
    var current_indx: usize = 0;
    var nodes = std.ArrayList(usize).init(allocator);
    defer nodes.deinit();
    var num_trails: u64 = 0;
    while (std.mem.indexOfScalarPos(u8, map, current_indx, '0')) |indx| {
        nodes.clearRetainingCapacity();
        try dfs(&nodes, width, height, map, Location.init(indx, width));
        num_trails += nodes.items.len;
        current_indx = indx + 1;
    }
    return num_trails;
}
pub fn dfs(nodes: *std.ArrayList(usize), width: usize, height: usize, map: []const u8, indx: Location) !void {
    //std.debug.print("exploring {any} value {c}\n", .{ indx, map[indx.to_indx(width)] });
    if (map[indx.to_indx(width)] == '9') {
        //std.debug.print("found at {any}\n", .{indx});
        const to_indx = indx.to_indx(width);
        const exists = for (nodes.items) |i| {
            if (i == to_indx) break i;
        } else null;
        if (exists == null) {
            try nodes.append(to_indx);
        }
    } else {
        if (indx.x > 0) {
            const new_indx = Location{ .x = indx.x - 1, .y = indx.y };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs(nodes, width, height, map, new_indx);
        }
        if (indx.x + 1 < width) {
            const new_indx = Location{ .x = indx.x + 1, .y = indx.y };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs(nodes, width, height, map, new_indx);
        }
        if (indx.y > 0) {
            const new_indx = Location{ .x = indx.x, .y = indx.y - 1 };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs(nodes, width, height, map, new_indx);
        }
        if (indx.y + 1 < height) {
            const new_indx = Location{ .x = indx.x, .y = indx.y + 1 };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs(nodes, width, height, map, new_indx);
        }
    }
}
pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var result: u64 = 0;
    var width: usize = 0;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        width = line.len;
        _ = try map.writer().write(line);
    }
    const height: usize = map.items.len / width;
    for (0..height) |i| {
        for (0..width) |j| {
            std.debug.print("{c}", .{map.items[i * width + j]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("Map width {d} height {d} len {d}\n", .{ width, height, map.items.len });
    result = try dfs_setup(map.items, width, height, allocator);
    return result;
}

// --- Part Two ---
// The reindeer spends a few minutes reviewing your hiking trail map before realizing something, disappearing for a few minutes, and finally returning with yet another slightly-charred piece of paper.

// The paper describes a second way to measure a trailhead called its rating. A trailhead's rating is the number of distinct hiking trails which begin at that trailhead. For example:

// .....0.
// ..4321.
// ..5..2.
// ..6543.
// ..7..4.
// ..8765.
// ..9....
// The above map has a single trailhead; its rating is 3 because there are exactly three distinct hiking trails which begin at that position:

// .....0.   .....0.   .....0.
// ..4321.   .....1.   .....1.
// ..5....   .....2.   .....2.
// ..6....   ..6543.   .....3.
// ..7....   ..7....   .....4.
// ..8....   ..8....   ..8765.
// ..9....   ..9....   ..9....
// Here is a map containing a single trailhead with rating 13:

// ..90..9
// ...1.98
// ...2..7
// 6543456
// 765.987
// 876....
// 987....
// This map contains a single trailhead with rating 227 (because there are 121 distinct hiking trails that lead to the 9 on the right edge and 106 that lead to the 9 on the bottom edge):

// 012345
// 123456
// 234567
// 345678
// 4.6789
// 56789.
// Here's the larger example from before:

// 89010123
// 78121874
// 87430965
// 96549874
// 45678903
// 32019012
// 01329801
// 10456732
// Considering its trailheads in reading order, they have ratings of 20, 24, 10, 4, 1, 4, 5, 8, and 5. The sum of all trailhead ratings in this larger example topographic map is 81.

// You're not sure how, but the reindeer seems to have crafted some tiny flags out of toothpicks and bits of paper and is using them to mark trailheads on your topographic map. What is the sum of the ratings of all trailheads?
pub fn dfs_setup2(map: []const u8, width: usize, height: usize, allocator: std.mem.Allocator) !u64 {
    var current_indx: usize = 0;
    var nodes = std.ArrayList(usize).init(allocator);
    defer nodes.deinit();
    var num_trails: u64 = 0;
    while (std.mem.indexOfScalarPos(u8, map, current_indx, '0')) |indx| {
        nodes.clearRetainingCapacity();
        try dfs2(&nodes, width, height, map, Location.init(indx, width));
        num_trails += nodes.items.len;
        current_indx = indx + 1;
    }
    return num_trails;
}
pub fn dfs2(nodes: *std.ArrayList(usize), width: usize, height: usize, map: []const u8, indx: Location) !void {
    //std.debug.print("exploring {any} value {c}\n", .{ indx, map[indx.to_indx(width)] });
    if (map[indx.to_indx(width)] == '9') {
        //std.debug.print("found at {any}\n", .{indx});
        const to_indx = indx.to_indx(width);
        try nodes.append(to_indx);
    } else {
        if (indx.x > 0) {
            const new_indx = Location{ .x = indx.x - 1, .y = indx.y };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs2(nodes, width, height, map, new_indx);
        }
        if (indx.x + 1 < width) {
            const new_indx = Location{ .x = indx.x + 1, .y = indx.y };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs2(nodes, width, height, map, new_indx);
        }
        if (indx.y > 0) {
            const new_indx = Location{ .x = indx.x, .y = indx.y - 1 };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs2(nodes, width, height, map, new_indx);
        }
        if (indx.y + 1 < height) {
            const new_indx = Location{ .x = indx.x, .y = indx.y + 1 };
            if (map[new_indx.to_indx(width)] == map[indx.to_indx(width)] + 1) try dfs2(nodes, width, height, map, new_indx);
        }
    }
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var result: u64 = 0;
    var width: usize = 0;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        width = line.len;
        _ = try map.writer().write(line);
    }
    const height: usize = map.items.len / width;
    for (0..height) |i| {
        for (0..width) |j| {
            std.debug.print("{c}", .{map.items[i * width + j]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("Map width {d} height {d} len {d}\n", .{ width, height, map.items.len });
    result = try dfs_setup2(map.items, width, height, allocator);
    return result;
}
test "day10" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Sum of the scores of all trailheads {d} in {d}ms\n", .{ try part1("inputs/day10/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Sum of the ratings of all trailheads {d} in {d}ms\n", .{ try part2("inputs/day10/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
