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
const common = @import("common");

pub const Point = struct {
    x: f64,
    y: f64,
    pub const Color = enum {
        Red,
        Green,
    };
    pub fn area(self: *Point, other: Point) u64 {
        return @abs(1 + self.x - other.x) * @abs(1 + self.y - other.y);
    }
};

pub const Line = struct {
    p1: Point,
    p2: Point,
    pub fn intersects_rect(self: *Line, top_left: Point, bottom_right: Point) bool {
        _ = self;
        _ = top_left;
        _ = bottom_right;
    }

    const Tuple = struct {
        first: f64,
        second: f64,
    };
    fn det(a: Tuple, b: Tuple) f64 {
        return a.first * b.second - a.second * b.first;
    }

    pub fn intersects(self: *Line, other: Line) bool {
        const xdiff = Tuple{
            .first = (self.p1.x - self.p2.x),
            .second = (other.p1.x - other.p2.x),
        };
        const ydiff = Tuple{
            .first = (self.p1.y - self.p2.y),
            .second = (other.p1.y - other.p2.y),
        };
        const div = det(xdiff, ydiff);
        if (div == 0) return false;
        const d = Tuple{ .first = det(self.p1, self.p2), .second = det(other.p1, other.p2) };
        const x = det(d, xdiff) / div;
        const y = det(d, ydiff) / div;
        const in_self = ((x >= self.p1.x and x <= self.p2.x) or (x >= self.p2.x and x <= self.p1.x)) and
            ((y >= self.p1.y and y <= self.p2.y) or (y >= self.p2.y and y <= self.p1.y));
        const in_other = ((x >= other.p1.x and x <= other.p2.x) or (x >= other.p2.x and x <= other.p1.x)) and
            ((y >= other.p1.y and y <= other.p2.y) or (y >= other.p2.y and y <= other.p1.y));
        return in_self and in_other;
    }
};

var world: []u8 = undefined;
var width: u32 = undefined;
var height: u32 = undefined;
var points: std.ArrayList(Line) = undefined;
pub var part1: bool = false;
pub var part2: bool = false;

pub fn on_render(self: anytype, _: u64) void {
    for (points.items) |l| {
        if (l.p1.x == l.p2.x) {
            const p_start = if (l.p1.y < l.p2.y) l.p1 else l.p2;
            const p_end = if (l.p1.y < l.p2.y) l.p2 else l.p1;
            var y = p_start.y + 1;
            while (y < p_end.y) : (y += 1) {
                const x = @divFloor((p_start.x * (p_end.y - y) + p_end.x * (y - p_start.y)), (p_end.y - p_start.y));

                self.e.renderer.ascii.draw_symbol(@intFromFloat(x), @intFromFloat(y), 'X', common.Colors.GREEN, self.window);
            }
        } else {
            const p_start = if (l.p1.x < l.p2.x) l.p1 else l.p2;
            const p_end = if (l.p1.x < l.p2.x) l.p2 else l.p1;
            var x = p_start.x + 1;
            std.debug.print("start x,y ({d},{d})\n", .{ p_start.x, p_start.y });
            std.debug.print("end x,y ({d},{d})\n", .{ p_end.x, p_end.y });
            while (x < p_end.x) : (x += 1) {
                const y = @divFloor((p_start.y * (p_end.x - x) + p_end.y * (x - p_start.x)), (p_end.x - p_start.x));
                std.debug.print("Green x,y ({d},{d})\n", .{ x, y });
                self.e.renderer.ascii.draw_symbol(@intFromFloat(x), @intFromFloat(y), 'X', common.Colors.GREEN, self.window);
            }
        }
        self.e.renderer.ascii.draw_symbol(@intFromFloat(l.p1.x), @intFromFloat(l.p1.y), '#', common.Colors.RED, self.window);
        self.e.renderer.ascii.draw_symbol(@intFromFloat(l.p2.x), @intFromFloat(l.p2.y), '#', common.Colors.RED, self.window);
        //std.debug.print("{any}\n", .{self.window});
    }
}

pub fn deinit(self: anytype) void {
    points.deinit();
    if (part2) {
        self.allocator.free(world);
    }
}

pub fn max_area2(allocator: std.mem.Allocator) usize {
    var areas = std.ArrayList(Rect).init(allocator);
    defer areas.deinit();
    for (0..points.items.len) |i| {
        for (i + 1..points.items.len) |j| {
            //std.debug.print("P1 ({d},{d}) P2 ({d}, {d})\n", .{ points.items[i].x, points.items[i].y, points.items[j].x, points.items[j].y });
            const top_indx = if (points.items[i].p1.y < points.items[j].p1.y) i else if (points.items[i].p1.y == points.items[j].p1.y and points.items[i].p1.x < points.items[j].p1.x) i else j;
            const top_left = if (top_indx == i) points.items[i].p1 else points.items[j].p1;
            const bottom_right = if (top_indx == i) points.items[j].p1 else points.items[i].p1;
            const top_right = Point{
                .x = bottom_right.x,
                .y = top_left.y,
            };
            const bottom_left = Point{ .x = top_left.x, .y = bottom_right.y };
            try areas.append(Rect{ .top_left = top_left, .top_right = top_right, .bottom_left = bottom_left, .bottom_right = bottom_right, .area = points.items[i].p1.area(points.items[j].p1) });
        }
    }
    std.mem.sort(usize, areas.items, {}, struct {
        pub fn compare(_: void, lhs: Rect, rhs: Rect) bool {
            return lhs.area > rhs.area;
        }
    }.compare);
    for (areas.items) |a| {
        std.debug.print("{d}\n", .{a.area});
    }
    return areas.items[0].area;
}

const Rect = struct {
    top_left: Point,
    top_right: Point,
    bottom_left: Point,
    bottom_right: Point,
    area: usize,
};

pub fn day9_p2(self: anytype) !void {
    part2 = true;
    const f = try std.fs.cwd().openFile("inputs/day9/small.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    points = std.ArrayList(Line).init(self.allocator);

    var first: ?Point = null;
    var prev: Point = undefined;
    var min_bound: Point = .{ .x = 0, .y = 0 };
    var max_bound: Point = .{ .x = 0, .y = 0 };
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var iter = std.mem.splitScalar(u8, line, ',');
        const new_point = Point{
            .x = try std.fmt.parseFloat(f64, iter.next().?),
            .y = try std.fmt.parseFloat(f64, iter.next().?),
        };
        if (first == null) {
            first = new_point;
            min_bound.x = new_point.x;
            min_bound.y = new_point.y;
            max_bound.x = new_point.x;
            max_bound.y = new_point.x;
        } else {
            min_bound.x = @min(min_bound.x, new_point.x);
            min_bound.y = @min(min_bound.y, new_point.y);
            max_bound.x = @max(max_bound.x, new_point.x);
            max_bound.y = @max(max_bound.y, new_point.y);
            try points.append(.{
                .p1 = prev,
                .p2 = new_point,
            });
        }
        prev = new_point;
    }
    try points.append(.{
        .p1 = prev,
        .p2 = first.?,
    });
    width = @intFromFloat(max_bound.x + 1);
    height = @intFromFloat(max_bound.y + 1);
    try self.window.rect(width, height, 0, 0, 0, 255);
    std.debug.print("Width {d}, {d}\n Height {d}, {d}\n", .{ width, self.window.width, height, self.window.height });

    std.debug.print("Max area of rectangle {d}\n", .{max_area2(self.allocator)});
}

pub fn max_area() usize {
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
    part1 = true;
    const f = try std.fs.cwd().openFile("inputs/day9/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    points = std.ArrayList(Point).init(self.allocator);
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var iter = std.mem.splitScalar(u8, line, ',');
        try points.append(.{
            .x = try std.fmt.parseInt(f64, iter.next().?),
            .y = try std.fmt.parseInt(f64, iter.next().?),
        });
    }
    std.debug.print("Max area of rectangle {d}\n", .{max_area(points)});
}
