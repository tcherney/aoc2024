// --- Day 9: Movie Theater ---
// You slide down the firepole in the corner of the playground and land in the North Pole base movie theater!

// The movie theater has a big tile floor with an interesting pattern. Elves here are redecorating the theater by switching out some of the square tiles in the big grid they form. Some of the tiles are red; the Elves would like to find the largest rectangle that uses red tiles for two of its opposite corners. They even have a list of where the red tiles are located in the grid (your puzzle input).

// For example:

// 7,1
// 11,1
// 11,7
// 9,7
// 9,5
// 2,5
// 2,3
// 7,3
// Showing red tiles as # and other tiles as ., the above arrangement of red tiles would look like this:

// ..............
// .......#...#..
// ..............
// ..#....#......
// ..............
// ..#......#....
// ..............
// .........#.#..
// ..............
// You can choose any two red tiles as the opposite corners of your rectangle; your goal is to find the largest rectangle possible.

// For example, you could make a rectangle (shown as O) with an area of 24 between 2,5 and 9,7:

// ..............
// .......#...#..
// ..............
// ..#....#......
// ..............
// ..OOOOOOOO....
// ..OOOOOOOO....
// ..OOOOOOOO.#..
// ..............
// Or, you could make a rectangle with area 35 between 7,1 and 11,7:

// ..............
// .......OOOOO..
// .......OOOOO..
// ..#....OOOOO..
// .......OOOOO..
// ..#....OOOOO..
// .......OOOOO..
// .......OOOOO..
// ..............
// You could even make a thin rectangle with an area of only 6 between 7,3 and 2,3:

// ..............
// .......#...#..
// ..............
// ..OOOOOO......
// ..............
// ..#......#....
// ..............
// .........#.#..
// ..............
// Ultimately, the largest rectangle you can make in this example has area 50. One way to do this is between 2,5 and 11,1:

// ..............
// ..OOOOOOOOOO..
// ..OOOOOOOOOO..
// ..OOOOOOOOOO..
// ..OOOOOOOOOO..
// ..OOOOOOOOOO..
// ..............
// .........#.#..
// ..............
// Using two red tiles as opposite corners, what is the largest area of any rectangle you can make?

// --- Part Two ---
// The Elves just remembered: they can only switch out tiles that are red or green. So, your rectangle can only include red or green tiles.

// In your list, every red tile is connected to the red tile before and after it by a straight line of green tiles. The list wraps, so the first red tile is also connected to the last red tile. Tiles that are adjacent in your list will always be on either the same row or the same column.

// Using the same example as before, the tiles marked X would be green:

// ..............
// .......#XXX#..
// .......X...X..
// ..#XXXX#...X..
// ..X........X..
// ..#XXXXXX#.X..
// .........X.X..
// .........#X#..
// ..............
// In addition, all of the tiles inside this loop of red and green tiles are also green. So, in this example, these are the green tiles:

// ..............
// .......#XXX#..
// .......XXXXX..
// ..#XXXX#XXXX..
// ..XXXXXXXXXX..
// ..#XXXXXX#XX..
// .........XXX..
// .........#X#..
// ..............
// The remaining tiles are never red nor green.

// The rectangle you choose still must have red tiles in opposite corners, but any other tiles it includes must now be red or green. This significantly limits your options.

// For example, you could make a rectangle out of red and green tiles with an area of 15 between 7,3 and 11,1:

// ..............
// .......OOOOO..
// .......OOOOO..
// ..#XXXXOOOOO..
// ..XXXXXXXXXX..
// ..#XXXXXX#XX..
// .........XXX..
// .........#X#..
// ..............
// Or, you could make a thin rectangle with an area of 3 between 9,7 and 9,5:

// ..............
// .......#XXX#..
// .......XXXXX..
// ..#XXXX#XXXX..
// ..XXXXXXXXXX..
// ..#XXXXXXOXX..
// .........OXX..
// .........OX#..
// ..............
// The largest rectangle you can make in this example using only red and green tiles has area 24. One way to do this is between 9,5 and 2,3:

// ..............
// .......#XXX#..
// .......XXXXX..
// ..OOOOOOOOXX..
// ..OOOOOOOOXX..
// ..OOOOOOOOXX..
// .........XXX..
// .........#X#..
// ..............
// Using two red tiles as opposite corners, what is the largest area of any rectangle you can make using only red and green tiles?

const std = @import("std");

pub const Point = struct {
    x: i64,
    y: i64,

    pub fn area(self: *Point, other: Point) u64 {
        return @abs(1 + self.x - other.x) * @abs(1 + self.y - other.y);
    }
};

pub fn day9_p2(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day9/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var points = std.ArrayList(Point).init(self.allocator);
    defer points.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var iter = std.mem.splitScalar(u8, line, ',');
        try points.append(.{
            .x = try std.fmt.parseInt(i64, iter.next().?, 10),
            .y = try std.fmt.parseInt(i64, iter.next().?, 10),
        });
    }
    //TODO generate all points, put all points into a hash map, take 2 points to make rectangle and create a line between them and verify all points in line are in map
    //TODO this might still be too slow, can atleast find the biggest rectangles first in a sorted list and only verify those ones

    std.debug.print("Max area of rectangle {d}\n", .{max_area(points)});
}

pub fn max_area(points: std.ArrayList(Point)) usize {
    var area: usize = 0;
    for (0..points.items.len) |i| {
        for (i + 1..points.items.len) |j| {
            //std.debug.print("P1 ({d},{d}) P2 ({d}, {d})\n", .{ points.items[i].x, points.items[i].y, points.items[j].x, points.items[j].y });
            area = @max(area, points.items[i].area(points.items[j]));
        }
    }
    return area;
}

pub fn day9_p1(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day9/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var points = std.ArrayList(Point).init(self.allocator);
    defer points.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var iter = std.mem.splitScalar(u8, line, ',');
        try points.append(.{
            .x = try std.fmt.parseInt(i64, iter.next().?, 10),
            .y = try std.fmt.parseInt(i64, iter.next().?, 10),
        });
    }
    std.debug.print("Max area of rectangle {d}\n", .{max_area(points)});
}
