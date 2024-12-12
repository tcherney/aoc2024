const std = @import("std");
// https://adventofcode.com/2024/day/12
// --- Day 12: Garden Groups ---
// Why not search for the Chief Historian near the gardener and his massive farm? There's plenty of food, so The Historians grab something to eat while they search.

// You're about to settle near a complex arrangement of garden plots when some Elves ask if you can lend a hand. They'd like to set up fences around each region of garden plots, but they can't figure out how much fence they need to order or how much it will cost. They hand you a map (your puzzle input) of the garden plots.

// Each garden plot grows only a single type of plant and is indicated by a single letter on your map. When multiple garden plots are growing the same type of plant and are touching (horizontally or vertically), they form a region. For example:

// AAAA
// BBCD
// BBCC
// EEEC
// This 4x4 arrangement includes garden plots growing five different types of plants (labeled A, B, C, D, and E), each grouped into their own region.

// In order to accurately calculate the cost of the fence around a single region, you need to know that region's area and perimeter.

// The area of a region is simply the number of garden plots the region contains. The above map's type A, B, and C plants are each in a region of area 4. The type E plants are in a region of area 3; the type D plants are in a region of area 1.

// Each garden plot is a square and so has four sides. The perimeter of a region is the number of sides of garden plots in the region that do not touch another garden plot in the same region. The type A and C plants are each in a region with perimeter 10. The type B and E plants are each in a region with perimeter 8. The lone D plot forms its own region with perimeter 4.

// Visually indicating the sides of plots in each region that contribute to the perimeter using - and |, the above map's regions' perimeters are measured as follows:

// +-+-+-+-+
// |A A A A|
// +-+-+-+-+     +-+
//               |D|
// +-+-+   +-+   +-+
// |B B|   |C|
// +   +   + +-+
// |B B|   |C C|
// +-+-+   +-+ +
//           |C|
// +-+-+-+   +-+
// |E E E|
// +-+-+-+
// Plants of the same type can appear in multiple separate regions, and regions can even appear within other regions. For example:

// OOOOO
// OXOXO
// OOOOO
// OXOXO
// OOOOO
// The above map contains five regions, one containing all of the O garden plots, and the other four each containing a single X plot.

// The four X regions each have area 1 and perimeter 4. The region containing 21 type O plants is more complicated; in addition to its outer edge contributing a perimeter of 20, its boundary with each X region contributes an additional 4 to its perimeter, for a total perimeter of 36.

// Due to "modern" business practices, the price of fence required for a region is found by multiplying that region's area by its perimeter. The total price of fencing all regions on a map is found by adding together the price of fence for every region on the map.

// In the first example, region A has price 4 * 10 = 40, region B has price 4 * 8 = 32, region C has price 4 * 10 = 40, region D has price 1 * 4 = 4, and region E has price 3 * 8 = 24. So, the total price for the first example is 140.

// In the second example, the region with all of the O plants has price 21 * 36 = 756, and each of the four smaller X regions has price 1 * 4 = 4, for a total price of 772 (756 + 4 + 4 + 4 + 4).

// Here's a larger example:

// RRRRIICCFF
// RRRRIICCCF
// VVRRRCCFFF
// VVRCCCJFFF
// VVVVCJJCFE
// VVIVCCJJEE
// VVIIICJJEE
// MIIIIIJJEE
// MIIISIJEEE
// MMMISSJEEE
// It contains:

// A region of R plants with price 12 * 18 = 216.
// A region of I plants with price 4 * 8 = 32.
// A region of C plants with price 14 * 28 = 392.
// A region of F plants with price 10 * 18 = 180.
// A region of V plants with price 13 * 20 = 260.
// A region of J plants with price 11 * 20 = 220.
// A region of C plants with price 1 * 4 = 4.
// A region of E plants with price 13 * 18 = 234.
// A region of I plants with price 14 * 22 = 308.
// A region of M plants with price 5 * 12 = 60.
// A region of S plants with price 3 * 8 = 24.
// So, it has a total price of 1930.

// What is the total price of fencing all regions on your map?

var mapped: std.ArrayList(bool) = undefined;
var map_width: usize = undefined;
var map_height: usize = undefined;
pub const Region = struct {
    symbol: u8,
    nodes: std.ArrayList(Location),
    allocator: std.mem.Allocator,
    pub const Location = struct {
        x: i64,
        y: i64,
        fn init(indx: usize) Location {
            const x = @as(i64, @bitCast(indx % map_width));
            return .{
                .x = x,
                .y = @as(i64, @bitCast(@divFloor(@as(i64, @bitCast(indx)) - @as(i64, @bitCast(x)), @as(i64, @bitCast(map_width))))),
            };
        }
        fn to_indx(loc: *const Location) usize {
            return @as(usize, @bitCast(loc.y)) * map_width + @as(usize, @bitCast(loc.x));
        }
    };
    pub fn init(allocator: std.mem.Allocator) Region {
        return .{
            .symbol = undefined,
            .nodes = std.ArrayList(Location).init(allocator),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *Region) void {
        self.nodes.deinit();
    }
    pub const FenceSegment = struct {
        loc: Location,
        side: FenceSide,
        pub const FenceSide = enum {
            Left,
            Right,
            Top,
            Bottom,
        };
    };
    pub fn walk_perimeter(self: *Region, map: []const u8) !u64 {
        var line_segments = std.ArrayList(FenceSegment).init(self.allocator);
        defer line_segments.deinit();
        for (0..self.nodes.items.len) |i| {
            if (self.nodes.items[i].x - 1 < 0) {
                try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Left });
            } else {
                const left = Location{ .x = self.nodes.items[i].x - 1, .y = self.nodes.items[i].y };
                if (map[left.to_indx()] != self.symbol) {
                    try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Left });
                }
            }
            if (self.nodes.items[i].x + 1 >= map_width) {
                try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Right });
            } else {
                const right = Location{ .x = self.nodes.items[i].x + 1, .y = self.nodes.items[i].y };
                if (map[right.to_indx()] != self.symbol) {
                    try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Right });
                }
            }
            if (self.nodes.items[i].y + 1 >= map_height) {
                try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Bottom });
            } else {
                const up = Location{ .x = self.nodes.items[i].x, .y = self.nodes.items[i].y + 1 };
                if (map[up.to_indx()] != self.symbol) {
                    try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Bottom });
                }
            }
            if (self.nodes.items[i].y - 1 < 0) {
                try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Top });
            } else {
                const down = Location{ .x = self.nodes.items[i].x, .y = self.nodes.items[i].y - 1 };
                if (map[down.to_indx()] != self.symbol) {
                    try line_segments.append(FenceSegment{ .loc = self.nodes.items[i], .side = FenceSegment.FenceSide.Top });
                }
            }
        }
        //std.debug.print("Region {c} segments {any}\n", .{ self.symbol, line_segments.items });
        var sides: u64 = 0;
        while (line_segments.items.len > 0) {
            const starting_segment = line_segments.pop();
            //std.debug.print("Starting fence with {any}\n", .{starting_segment});
            sides += 1;
            switch (starting_segment.side) {
                .Top => {
                    var found_left = false;
                    var found_right = false;
                    var searching_left = true;
                    var searching_right = true;
                    var left_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    var right_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    while (searching_left or searching_right) {
                        found_left = false;
                        found_right = false;
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Top and line_segments.items[i].loc.x == left_loc.x - 1 and line_segments.items[i].loc.y == left_loc.y) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_left = true;
                                _ = line_segments.orderedRemove(i);
                                left_loc.x -= 1;
                                break;
                            }
                        }
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Top and line_segments.items[i].loc.x == right_loc.x + 1 and line_segments.items[i].loc.y == right_loc.y) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_left = true;
                                _ = line_segments.orderedRemove(i);
                                right_loc.x += 1;
                                break;
                            }
                        }
                        searching_left = found_left;
                        searching_right = found_right;
                    }
                },
                .Bottom => {
                    var found_left = false;
                    var found_right = false;
                    var searching_left = true;
                    var searching_right = true;
                    var left_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    var right_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    while (searching_left or searching_right) {
                        found_left = false;
                        found_right = false;
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Bottom and line_segments.items[i].loc.x == left_loc.x - 1 and line_segments.items[i].loc.y == left_loc.y) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_left = true;
                                _ = line_segments.orderedRemove(i);
                                left_loc.x -= 1;
                                break;
                            }
                        }
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Bottom and line_segments.items[i].loc.x == right_loc.x + 1 and line_segments.items[i].loc.y == right_loc.y) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_left = true;
                                _ = line_segments.orderedRemove(i);
                                right_loc.x += 1;
                                break;
                            }
                        }
                        searching_left = found_left;
                        searching_right = found_right;
                    }
                },
                .Left => {
                    var found_top = false;
                    var found_bottom = false;
                    var searching_top = true;
                    var searching_bottom = true;
                    var top_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    var bottom_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    while (searching_top or searching_bottom) {
                        found_top = false;
                        found_bottom = false;
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Left and line_segments.items[i].loc.y == top_loc.y - 1 and line_segments.items[i].loc.x == top_loc.x) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_top = true;
                                _ = line_segments.orderedRemove(i);
                                top_loc.y -= 1;
                                break;
                            }
                        }
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Left and line_segments.items[i].loc.y == bottom_loc.y + 1 and line_segments.items[i].loc.x == bottom_loc.x) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_bottom = true;
                                _ = line_segments.orderedRemove(i);
                                bottom_loc.y += 1;
                                break;
                            }
                        }
                        searching_top = found_top;
                        searching_bottom = found_bottom;
                    }
                },
                .Right => {
                    var found_top = false;
                    var found_bottom = false;
                    var searching_top = true;
                    var searching_bottom = true;
                    var top_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    var bottom_loc = Location{ .x = starting_segment.loc.x, .y = starting_segment.loc.y };
                    while (searching_top or searching_bottom) {
                        found_top = false;
                        found_bottom = false;
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Right and line_segments.items[i].loc.y == top_loc.y - 1 and line_segments.items[i].loc.x == top_loc.x) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_top = true;
                                _ = line_segments.orderedRemove(i);
                                top_loc.y -= 1;
                                break;
                            }
                        }
                        for (0..line_segments.items.len) |i| {
                            if (line_segments.items[i].side == .Right and line_segments.items[i].loc.y == bottom_loc.y + 1 and line_segments.items[i].loc.x == bottom_loc.x) {
                                //std.debug.print("adding {any} to fence\n", .{line_segments.items[i]});
                                found_bottom = true;
                                _ = line_segments.orderedRemove(i);
                                bottom_loc.y += 1;
                                break;
                            }
                        }
                        searching_top = found_top;
                        searching_bottom = found_bottom;
                    }
                },
            }
        }
        return sides;
    }
    pub fn bulk_cost(self: *Region, map: []const u8) !u64 {
        const area = self.nodes.items.len;
        const sides = try self.walk_perimeter(map);
        //std.debug.print("Region {c} {d} * {d} = {d}\n", .{ self.symbol, area, sides, area * sides });
        return area * sides;
    }
    pub fn cost(self: *Region, map: []const u8) u64 {
        const area = self.nodes.items.len;
        var perimeter: usize = 0;
        for (0..self.nodes.items.len) |i| {
            if (self.nodes.items[i].x - 1 < 0) {
                perimeter += 1;
            } else {
                const left = Location{ .x = self.nodes.items[i].x - 1, .y = self.nodes.items[i].y };
                if (map[left.to_indx()] != self.symbol) perimeter += 1;
            }
            if (self.nodes.items[i].x + 1 >= map_width) {
                perimeter += 1;
            } else {
                const right = Location{ .x = self.nodes.items[i].x + 1, .y = self.nodes.items[i].y };
                if (map[right.to_indx()] != self.symbol) perimeter += 1;
            }
            if (self.nodes.items[i].y + 1 >= map_height) {
                perimeter += 1;
            } else {
                const up = Location{ .x = self.nodes.items[i].x, .y = self.nodes.items[i].y + 1 };
                if (map[up.to_indx()] != self.symbol) perimeter += 1;
            }
            if (self.nodes.items[i].y - 1 < 0) {
                perimeter += 1;
            } else {
                const down = Location{ .x = self.nodes.items[i].x, .y = self.nodes.items[i].y - 1 };
                if (map[down.to_indx()] != self.symbol) perimeter += 1;
            }
        }
        //std.debug.print("Region {c} {d} * {d} = {d}\n", .{ self.symbol, area, perimeter, area * perimeter });
        return area * perimeter;
    }
    pub fn setup_region(self: *Region, map: []const u8, start: usize) !void {
        self.symbol = map[start];
        //std.debug.print("starting region {c} at index {d}\n", .{ self.symbol, start });
        const current_loc = Location.init(start);
        try self.nodes.append(current_loc);
        mapped.items[start] = true;
        if (current_loc.x - 1 >= 0) {
            const new_loc = Location{ .x = current_loc.x - 1, .y = current_loc.y };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
        if (current_loc.x + 1 < map_width) {
            const new_loc = Location{ .x = current_loc.x + 1, .y = current_loc.y };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
        if (current_loc.y + 1 < map_height) {
            const new_loc = Location{ .x = current_loc.x, .y = current_loc.y + 1 };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
        if (current_loc.y - 1 >= 0) {
            const new_loc = Location{ .x = current_loc.x, .y = current_loc.y - 1 };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
    }

    pub fn build_region(self: *Region, map: []const u8, current_indx: usize) !void {
        //std.debug.print("exploring region {c} at index {d}\n", .{ self.symbol, current_indx });
        const current_loc = Location.init(current_indx);
        try self.nodes.append(current_loc);
        mapped.items[current_indx] = true;
        if (current_loc.x - 1 >= 0) {
            const new_loc = Location{ .x = current_loc.x - 1, .y = current_loc.y };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
        if (current_loc.x + 1 < map_width) {
            const new_loc = Location{ .x = current_loc.x + 1, .y = current_loc.y };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
        if (current_loc.y + 1 < map_height) {
            const new_loc = Location{ .x = current_loc.x, .y = current_loc.y + 1 };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
        if (current_loc.y - 1 >= 0) {
            const new_loc = Location{ .x = current_loc.x, .y = current_loc.y - 1 };
            if (map[new_loc.to_indx()] == self.symbol and !mapped.items[new_loc.to_indx()]) {
                try self.build_region(map, new_loc.to_indx());
            }
        }
    }
};

var num_buf: [1024]u8 = undefined;
pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        map_width = line.len;
        _ = try map.writer().write(line);
    }
    map_height = map.items.len / map_width;
    //std.debug.print("map {s}\nwidth {d} height {d} len {d}\n", .{ map.items, map_width, map_height, map.items.len });
    // find all regions
    var regions = std.ArrayList(Region).init(allocator);
    defer regions.deinit();
    mapped = try std.ArrayList(bool).initCapacity(allocator, map.items.len);
    mapped.expandToCapacity();
    defer mapped.deinit();
    for (0..mapped.items.len) |i| {
        mapped.items[i] = false;
    }
    for (0..map.items.len) |i| {
        if (!mapped.items[i]) {
            var region = Region.init(allocator);
            try region.setup_region(map.items, i);
            try regions.append(region);
            //std.debug.print("Region {c} with nodes {any}\n", .{ region.symbol, region.nodes });
        }
    }
    var result: u64 = 0;
    for (0..regions.items.len) |i| {
        result += regions.items[i].cost(map.items);
        regions.items[i].deinit();
    }
    return result;
}

// --- Part Two ---
// Fortunately, the Elves are trying to order so much fence that they qualify for a bulk discount!

// Under the bulk discount, instead of using the perimeter to calculate the price, you need to use the number of sides each region has. Each straight section of fence counts as a side, regardless of how long it is.

// Consider this example again:

// AAAA
// BBCD
// BBCC
// EEEC
// The region containing type A plants has 4 sides, as does each of the regions containing plants of type B, D, and E. However, the more complex region containing the plants of type C has 8 sides!

// Using the new method of calculating the per-region price by multiplying the region's area by its number of sides, regions A through E have prices 16, 16, 32, 4, and 12, respectively, for a total price of 80.

// The second example above (full of type X and O plants) would have a total price of 436.

// Here's a map that includes an E-shaped region full of type E plants:

// EEEEE
// EXXXX
// EEEEE
// EXXXX
// EEEEE
// The E-shaped region has an area of 17 and 12 sides for a price of 204. Including the two regions full of type X plants, this map has a total price of 236.

// This map has a total price of 368:

// AAAAAA
// AAABBA
// AAABBA
// ABBAAA
// ABBAAA
// AAAAAA
// It includes two regions full of type B plants (each with 4 sides) and a single region full of type A plants (with 4 sides on the outside and 8 more sides on the inside, a total of 12 sides). Be especially careful when counting the fence around regions like the one full of type A plants; in particular, each section of fence has an in-side and an out-side, so the fence does not connect across the middle of the region (where the two B regions touch diagonally). (The Elves would have used the Möbius Fencing Company instead, but their contract terms were too one-sided.)

// The larger example from before now has the following updated prices:

// A region of R plants with price 12 * 10 = 120.
// A region of I plants with price 4 * 4 = 16.
// A region of C plants with price 14 * 22 = 308.
// A region of F plants with price 10 * 12 = 120.
// A region of V plants with price 13 * 10 = 130.
// A region of J plants with price 11 * 12 = 132.
// A region of C plants with price 1 * 4 = 4.
// A region of E plants with price 13 * 8 = 104.
// A region of I plants with price 14 * 16 = 224.
// A region of M plants with price 5 * 6 = 30.
// A region of S plants with price 3 * 6 = 18.
// Adding these together produces its new total price of 1206.

// What is the new total price of fencing all regions on your map?

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        map_width = line.len;
        _ = try map.writer().write(line);
    }
    map_height = map.items.len / map_width;
    //std.debug.print("map {s}\nwidth {d} height {d} len {d}\n", .{ map.items, map_width, map_height, map.items.len });
    // find all regions
    var regions = std.ArrayList(Region).init(allocator);
    defer regions.deinit();
    mapped = try std.ArrayList(bool).initCapacity(allocator, map.items.len);
    mapped.expandToCapacity();
    defer mapped.deinit();
    for (0..mapped.items.len) |i| {
        mapped.items[i] = false;
    }
    for (0..map.items.len) |i| {
        if (!mapped.items[i]) {
            var region = Region.init(allocator);
            try region.setup_region(map.items, i);
            try regions.append(region);
            //std.debug.print("Region {c} with nodes {any}\n", .{ region.symbol, region.nodes });
        }
    }
    var result: u64 = 0;
    for (0..regions.items.len) |i| {
        result += try regions.items[i].bulk_cost(map.items);
        regions.items[i].deinit();
    }
    return result;
}
test "day12" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Total price of fencing all regions {d} in {d}ms\n", .{ try part1("inputs/day12/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Total price of fencing all regions {d} in {d}ms\n", .{ try part2("inputs/day12/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
