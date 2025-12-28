const std = @import("std");
// https://adventofcode.com/2024/day/8
// --- Day 8: Resonant Collinearity ---
// You find yourselves on the roof of a top-secret Easter Bunny installation.

// While The Historians do their thing, you take a look at the familiar huge antenna. Much to your surprise, it seems to have been reconfigured to emit a signal that makes people 0.1% more likely to buy Easter Bunny brand Imitation Mediocre Chocolate as a Christmas gift! Unthinkable!

// Scanning across the city, you find that there are actually many such antennas. Each antenna is tuned to a specific frequency indicated by a single lowercase letter, uppercase letter, or digit. You create a map (your puzzle input) of these antennas. For example:

// ............
// ........0...
// .....0......
// .......0....
// ....0.......
// ......A.....
// ............
// ............
// ........A...
// .........A..
// ............
// ............
// The signal only applies its nefarious effect at specific antinodes based on the resonant frequencies of the antennas. In particular, an antinode occurs at any point that is perfectly in line with two antennas of the same frequency - but only when one of the antennas is twice as far away as the other. This means that for any pair of antennas with the same frequency, there are two antinodes, one on either side of them.

// So, for these two antennas with frequency a, they create the two antinodes marked with #:

// ..........
// ...#......
// ..........
// ....a.....
// ..........
// .....a....
// ..........
// ......#...
// ..........
// ..........
// Adding a third antenna with the same frequency creates several more antinodes. It would ideally add four antinodes, but two are off the right side of the map, so instead it adds only two:

// ..........
// ...#......
// #.........
// ....a.....
// ........a.
// .....a....
// ..#.......
// ......#...
// ..........
// ..........
// Antennas with different frequencies don't create antinodes; A and a count as different frequencies. However, antinodes can occur at locations that contain antennas. In this diagram, the lone antenna with frequency capital A creates no antinodes but has a lowercase-a-frequency antinode at its location:

// ..........
// ...#......
// #.........
// ....a.....
// ........a.
// .....a....
// ..#.......
// ......A...
// ..........
// ..........
// The first example has antennas with two different frequencies, so the antinodes they create look like this, plus an antinode overlapping the topmost A-frequency antenna:

// ......#....#
// ...#....0...
// ....#0....#.
// ..#....0....
// ....0....#..
// .#....A.....
// ...#........
// #......#....
// ........A...
// .........A..
// ..........#.
// ..........#.
// Because the topmost A-frequency antenna overlaps with a 0-frequency antinode, there are 14 total unique locations that contain an antinode within the bounds of the map.

// Calculate the impact of the signal. How many unique locations within the bounds of the map contain an antinode?

pub const AntennaPair = struct {
    rise: i64,
    run: i64,
    symbol: u8,
    loc1: Location,
    loc2: Location,
    pub const Location = struct {
        x: i64,
        y: i64,
    };
    fn inbounds(loc: Location, width: usize, height: usize) bool {
        if (loc.x < 0 or loc.y < 0) return false;
        return loc.x < @as(i64, @bitCast(width)) and loc.y < @as(i64, @bitCast(height));
    }
    fn manhattan(loc1: Location, loc2: Location) u64 {
        return @abs(loc2.x - loc1.x) + @abs(loc2.y - loc1.y);
    }
    pub fn add_antinodes_no_distance(self: *AntennaPair, map: []u8, width: usize, height: usize) void {
        var backwards = true;
        var searching = true;
        var current_point = Location{ .x = self.loc1.x, .y = self.loc1.y };
        while (searching) {
            if (backwards) {
                current_point.x -= self.run;
                current_point.y -= self.rise;
                if (!inbounds(current_point, width, height)) {
                    current_point.x = self.loc2.x;
                    current_point.y = self.loc2.y;
                    backwards = false;
                } else {
                    map[x_y_to_indx(current_point, width)] = '#';
                }
            } else {
                current_point.x += self.run;
                current_point.y += self.rise;
                if (!inbounds(current_point, width, height)) {
                    searching = false;
                } else {
                    map[x_y_to_indx(current_point, width)] = '#';
                }
            }
        }
    }
    pub fn add_antinodes_distance(self: *AntennaPair, map: []u8, width: usize, height: usize) void {
        var backwards = true;
        var searching = true;
        var current_point = Location{ .x = self.loc1.x, .y = self.loc1.y };
        while (searching) {
            if (backwards) {
                current_point.x -= self.run;
                current_point.y -= self.rise;
                if (!inbounds(current_point, width, height)) {
                    current_point.x = self.loc2.x;
                    current_point.y = self.loc2.y;
                    backwards = false;
                } else {
                    const d1 = manhattan(current_point, self.loc1);
                    const d2 = manhattan(current_point, self.loc2);
                    if (d1 < d2 and d2 == d1 * 2 or d2 < d1 and d1 == d2 * 2) {
                        map[x_y_to_indx(current_point, width)] = '#';
                    }
                }
            } else {
                current_point.x += self.run;
                current_point.y += self.rise;
                if (!inbounds(current_point, width, height)) {
                    searching = false;
                } else {
                    const d1 = manhattan(current_point, self.loc1);
                    const d2 = manhattan(current_point, self.loc2);
                    if (d1 < d2 and d2 == d1 * 2 or d2 < d1 and d1 == d2 * 2) {
                        map[x_y_to_indx(current_point, width)] = '#';
                    }
                }
            }
        }
    }
    fn indx_to_x_y(indx: usize, width: usize) Location {
        const x = @as(i64, @bitCast(indx % width));
        return .{
            .x = x,
            .y = @as(i64, @bitCast(@divFloor(@as(i64, @bitCast(indx)) - @as(i64, @bitCast(x)), @as(i64, @bitCast(width))))),
        };
    }
    fn x_y_to_indx(loc: Location, width: usize) usize {
        return @as(usize, @bitCast(loc.y)) * width + @as(usize, @bitCast(loc.x));
    }
    pub fn init(indx1: usize, indx2: usize, symbol: u8, width: usize) AntennaPair {
        const loc1 = indx_to_x_y(indx1, width);
        const loc2 = indx_to_x_y(indx2, width);
        return .{
            .rise = loc2.y - loc1.y,
            .run = loc2.x - loc1.x,
            .symbol = symbol,
            .loc1 = loc1,
            .loc2 = loc2,
        };
    }
};

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var width: usize = undefined;
    var buf: [4096]u8 = undefined;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.indexOfScalar(u8, line, '\r')) |indx| {
            const carriage_less = line[0..indx];
            width = carriage_less.len;
            try map.appendSlice(carriage_less);
        } else {
            width = line.len;
            try map.appendSlice(line);
        }
    }
    const height = map.items.len / width;
    for (0..height) |j| {
        for (0..width) |k| {
            std.debug.print("{c}", .{map.items[j * width + k]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
    //build list of antenna types
    var antenna_list = std.ArrayList(u8).init(allocator);
    defer antenna_list.deinit();
    for (48..58) |i| {
        try antenna_list.append(@intCast(i));
    }
    for (65..91) |i| {
        try antenna_list.append(@intCast(i));
    }
    for (97..123) |i| {
        try antenna_list.append(@intCast(i));
    }
    std.debug.print("AntennaTypes\n", .{});
    for (0..antenna_list.items.len) |i| {
        std.debug.print("{c} ", .{antenna_list.items[i]});
    }
    std.debug.print("\n", .{});
    //find antenna pairs
    var antenna_pairs = std.ArrayList(AntennaPair).init(allocator);
    defer antenna_pairs.deinit();
    for (0..antenna_list.items.len) |i| {
        var start_indx: usize = 0;
        while (std.mem.indexOfScalarPos(u8, map.items, start_indx, antenna_list.items[i])) |indx| {
            var previous_indx: usize = indx;
            while (std.mem.indexOfScalarPos(u8, map.items, previous_indx + 1, antenna_list.items[i])) |next_indx| {
                try antenna_pairs.append(AntennaPair.init(indx, next_indx, antenna_list.items[i], width));
                previous_indx = next_indx + 1;
            }
            start_indx = indx + 1;
        }
    }
    std.debug.print("AntennaPairs {d} {any}\n", .{ antenna_pairs.items.len, antenna_pairs.items });
    for (0..antenna_pairs.items.len) |i| {
        antenna_pairs.items[i].add_antinodes_distance(map.items, width, height);
    }
    for (0..height) |j| {
        for (0..width) |k| {
            std.debug.print("{c}", .{map.items[j * width + k]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
    return std.mem.count(u8, map.items, "#");
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var width: usize = undefined;
    var buf: [4096]u8 = undefined;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.indexOfScalar(u8, line, '\r')) |indx| {
            const carriage_less = line[0..indx];
            width = carriage_less.len;
            try map.appendSlice(carriage_less);
        } else {
            width = line.len;
            try map.appendSlice(line);
        }
    }
    const height = map.items.len / width;
    for (0..height) |j| {
        for (0..width) |k| {
            std.debug.print("{c}", .{map.items[j * width + k]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
    //build list of antenna types
    var antenna_list = std.ArrayList(u8).init(allocator);
    defer antenna_list.deinit();
    for (48..58) |i| {
        try antenna_list.append(@intCast(i));
    }
    for (65..91) |i| {
        try antenna_list.append(@intCast(i));
    }
    for (97..123) |i| {
        try antenna_list.append(@intCast(i));
    }
    std.debug.print("AntennaTypes\n", .{});
    for (0..antenna_list.items.len) |i| {
        std.debug.print("{c} ", .{antenna_list.items[i]});
    }
    std.debug.print("\n", .{});
    //find antenna pairs
    var antenna_pairs = std.ArrayList(AntennaPair).init(allocator);
    defer antenna_pairs.deinit();
    for (0..antenna_list.items.len) |i| {
        var start_indx: usize = 0;
        while (std.mem.indexOfScalarPos(u8, map.items, start_indx, antenna_list.items[i])) |indx| {
            var previous_indx: usize = indx;
            while (std.mem.indexOfScalarPos(u8, map.items, previous_indx + 1, antenna_list.items[i])) |next_indx| {
                try antenna_pairs.append(AntennaPair.init(indx, next_indx, antenna_list.items[i], width));
                previous_indx = next_indx + 1;
            }
            start_indx = indx + 1;
        }
    }
    std.debug.print("AntennaPairs {d} {any}\n", .{ antenna_pairs.items.len, antenna_pairs.items });
    for (0..antenna_pairs.items.len) |i| {
        antenna_pairs.items[i].add_antinodes_no_distance(map.items, width, height);
    }
    for (0..antenna_list.items.len) |i| {
        var start_indx: usize = 0;
        while (std.mem.indexOfScalarPos(u8, map.items, start_indx, antenna_list.items[i])) |indx| {
            map.items[indx] = '#';
            start_indx += 1;
        }
    }
    for (0..height) |j| {
        for (0..width) |k| {
            std.debug.print("{c}", .{map.items[j * width + k]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
    return std.mem.count(u8, map.items, "#");
}
test "day8" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Number of antinodes {d} in {d}ms\n", .{ try part1("inputs/day8/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Number of antinodes {d} in {d}ms\n", .{ try part2("inputs/day8/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
