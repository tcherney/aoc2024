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

var scratch_buffer: [1024]u8 = undefined;
//TODO have to figure this out
pub fn init(self: anytype) !void {}

pub const Point = struct {
    x: f64,
    y: f64,
    pub const Color = enum {
        Red,
        Green,
    };
    pub fn eql(self: *const Point, other: Point) bool {
        return self.x == other.x or self.y == other.y;
    }
    pub fn area(self: *const Point, other: Point) u64 {
        const min_x = @min(self.x, other.x);
        const min_y = @min(self.y, other.y);
        const max_x = @max(self.x, other.x);
        const max_y = @max(self.y, other.y);
        return @as(u64, @intFromFloat(@abs(1 + max_x - min_x))) * @as(u64, @intFromFloat(@abs(1 + max_y - min_y)));
    }
};

pub const Line = struct {
    p1: Point,
    p2: Point,
    pub fn intersects_rect(self: *const Line, top_left: Point, top_right: Point, bottom_left: Point, bottom_right: Point) bool {
        const l1 = Line{
            .p1 = top_left,
            .p2 = top_right,
        };
        const l2 = Line{
            .p1 = top_right,
            .p2 = bottom_right,
        };
        const l3 = Line{
            .p1 = bottom_left,
            .p2 = bottom_right,
        };
        const l4 = Line{
            .p1 = top_left,
            .p2 = bottom_left,
        };
        return self.intersects(l1) or self.intersects(l2) or self.intersects(l3) or self.intersects(l4);
    }

    pub fn contains(self: *const Line, p: Point) bool {
        const min_x = @min(self.p1.x, self.p2.x);
        const min_y = @min(self.p1.y, self.p2.y);
        const max_x = @max(self.p1.x, self.p2.x);
        const max_y = @max(self.p1.y, self.p2.y);
        return p.x >= min_x and p.x <= max_x and p.y >= min_y and p.y <= max_y;
    }

    const Tuple = struct {
        first: f64,
        second: f64,
    };
    fn det(a: Tuple, b: Tuple) f64 {
        return a.first * b.second - a.second * b.first;
    }
    //TODO fix this
    pub fn intersects(self: *const Line, other: Line) bool {
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
        const d = Tuple{ .first = det(.{ .first = self.p1.x, .second = self.p1.y }, .{ .first = self.p2.x, .second = self.p2.y }), .second = det(.{ .first = other.p1.x, .second = other.p1.y }, .{ .first = other.p2.x, .second = other.p2.y }) };
        const x = det(d, xdiff) / div;
        const y = det(d, ydiff) / div;

        var in_x_self: bool = false;
        if (self.p1.x <= self.p2.x) {
            in_x_self = x >= self.p1.x and x <= self.p2.x;
        } else {
            in_x_self = x >= self.p2.x and x <= self.p1.x;
        }
        var in_y_self: bool = false;
        if (self.p1.y <= self.p2.y) {
            in_y_self = y >= self.p1.y and y <= self.p2.y;
        } else {
            in_y_self = y >= self.p2.y and y <= self.p1.y;
        }
        const in_self: bool = in_x_self and in_y_self;

        var in_x_other: bool = false;
        if (other.p1.x <= other.p2.x) {
            in_x_other = x >= other.p1.x and x <= other.p2.x;
        } else {
            in_x_other = x >= other.p2.x and x <= other.p1.x;
        }
        var in_y_other: bool = false;
        if (other.p1.y <= other.p2.y) {
            //std.debug.print("{d} in between {d} and {d}\n", .{ y, other.p1.y, other.p2.y });
            in_y_other = y >= other.p1.y and y <= other.p2.y;
        } else {
            in_y_other = y >= other.p2.y and y <= other.p1.y;
        }
        const in_other: bool = in_x_other and in_y_other;
        //std.debug.print("{any} intersects {any} at ({d},{d}) {any}\n", .{ self, other, x, y, in_self and in_other });
        return in_self and in_other;
    }
};

pub fn update(self: anytype) !void {
    switch (state) {
        .init => {
            try init(self);
        },
        .part1 => {
            try day9_p1();
        },
        .part2 => {
            try day9_p2();
        },
        else => {},
    }
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

var world: []u8 = undefined;
var width: u32 = undefined;
var height: u32 = undefined;
var lines: std.ArrayList(Line) = undefined;
var points: std.ArrayList(Point) = undefined;
var x_coord: std.AutoHashMap(u64, std.ArrayList(i64)) = undefined;
var y_coord: std.AutoHashMap(u64, std.ArrayList(i64)) = undefined;
var state: RunningState = .init;
var part1: u64 = 0;
var part2: u64 = 0;

pub fn on_render(self: anytype) void {
    //TODO highlight rectangles as they are checked
    for (lines.items) |l| {
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
            //std.debug.print("start x,y ({d},{d})\n", .{ p_start.x, p_start.y });
            //std.debug.print("end x,y ({d},{d})\n", .{ p_end.x, p_end.y });
            while (x < p_end.x) : (x += 1) {
                const y = @divFloor((p_start.y * (p_end.x - x) + p_end.y * (x - p_start.x)), (p_end.x - p_start.x));
                //std.debug.print("Green x,y ({d},{d})\n", .{ x, y });
                self.e.renderer.ascii.draw_symbol(@intFromFloat(x), @intFromFloat(y), 'X', common.Colors.GREEN, self.window);
            }
        }
        self.e.renderer.ascii.draw_symbol(@intFromFloat(l.p1.x), @intFromFloat(l.p1.y), '#', common.Colors.RED, self.window);
        self.e.renderer.ascii.draw_symbol(@intFromFloat(l.p2.x), @intFromFloat(l.p2.y), '#', common.Colors.RED, self.window);
        //std.debug.print("{any}\n", .{self.window});
    }
}

pub fn deinit(self: anytype) void {
    if (part1) {
        points.deinit();
    }
    if (part2) {
        lines.deinit();
        self.allocator.free(world);
        var iter = x_coord.iterator();
        while (iter.next()) |item| {
            item.value_ptr.deinit();
        }
        iter = y_coord.iterator();
        while (iter.next()) |item| {
            item.value_ptr.deinit();
        }
        x_coord.deinit();
        y_coord.deinit();
    }
}

pub fn binary_search(pts: std.ArrayList(f64), val: f64) f64 {
    var low: f64 = 0;
    var high: f64 = @as(f64, @floatFromInt(pts.items.len)) - 1;
    while (low <= high) {
        const mid = low + (high - low) / 2;
        if (pts.items[@intFromFloat(mid)] == val) {
            return mid;
        } else if (pts.items[@intFromFloat(mid)] < val) {
            low = mid + 1;
        } else {
            high = mid - 1;
        }
    }
    return -1;
}

pub fn max_area2(allocator: std.mem.Allocator) !u64 {
    var areas = std.ArrayList(Rect).init(allocator);
    defer areas.deinit();
    for (0..lines.items.len) |i| {
        for (i + 1..lines.items.len) |j| {
            const min_x = @min(lines.items[i].p1.x, lines.items[j].p1.x);
            const min_y = @min(lines.items[i].p1.y, lines.items[j].p1.y);
            const max_x = @max(lines.items[i].p1.x, lines.items[j].p1.x);
            const max_y = @max(lines.items[i].p1.y, lines.items[j].p1.y);
            const top_left = Point{
                .x = min_x,
                .y = min_y,
            };
            const top_right = Point{
                .x = max_x,
                .y = min_y,
            };
            const bottom_left = Point{
                .x = min_x,
                .y = max_y,
            };
            const bottom_right = Point{
                .x = max_x,
                .y = max_y,
            };
            try areas.append(Rect{ .top_left = top_left, .top_right = top_right, .bottom_left = bottom_left, .bottom_right = bottom_right, .area = top_left.area(bottom_right) });
        }
    }
    std.mem.sort(Rect, areas.items, {}, struct {
        pub fn compare(_: void, lhs: Rect, rhs: Rect) bool {
            return lhs.area > rhs.area;
        }
    }.compare);
    outer: for (areas.items) |a| {
        std.debug.print("{d}\n", .{a.area});
        var viable: bool = true;
        var top_left_valid: bool = false;
        var bottom_right_valid: bool = false;
        for (lines.items) |l| {
            if (l.p1.eql(a.top_left)) {
                top_left_valid = true;
            } else if (l.p1.eql(a.bottom_right)) {
                bottom_right_valid = true;
            }
            if (l.intersects_rect(a.top_left, a.top_right, a.bottom_left, a.bottom_right) and !l.p1.eql(a.top_left) and !l.p1.eql(a.top_right) and !l.p1.eql(a.bottom_left) and !l.p1.eql(a.bottom_right) and !l.p2.eql(a.top_left) and !l.p2.eql(a.top_right) and !l.p2.eql(a.bottom_left) and !l.p2.eql(a.bottom_right)) {
                viable = false;
                break;
            }
        }
        if (viable and top_left_valid and bottom_right_valid) {
            std.debug.print("Viable {any}\n", .{a});
            for (@intFromFloat(a.top_left.y + 1)..@intFromFloat(a.bottom_left.y)) |y| {
                const x_entry_opt = x_coord.get(y);
                if (x_entry_opt) |x_entry| {
                    var in_poly: bool = false;
                    var prev_x: ?i64 = null;
                    for (x_entry.items) |x| {
                        if (prev_x != null and (prev_x.? + 1 == x or prev_x.? == x)) {
                            prev_x = x;
                            continue;
                        }
                        if (@as(i64, @intFromFloat(a.top_left.x)) < x and !in_poly) {
                            continue :outer;
                        } else if (@as(i64, @intFromFloat(a.top_right.x)) <= x) {
                            if (!in_poly) continue :outer;
                            break;
                        } else {
                            in_poly = !in_poly;
                        }
                        prev_x = x;
                    }
                } else {
                    continue;
                }
            }
            return a.area;
            // const min_x = a.top_left.x + 1;
            // const max_x = a.top_right.x - 1;
            // const min_y = a.top_left.y + 1;
            // const max_y = a.bottom_right.y - 1;
            // if (binary_search(y_coord.get(@intFromFloat(min_x)) orelse continue, min_y) != binary_search(y_coord.get(@intFromFloat(min_x)) orelse continue, max_y)) continue;
            // if (binary_search(y_coord.get(@intFromFloat(max_x)) orelse continue, min_y) != binary_search(y_coord.get(@intFromFloat(max_x)) orelse continue, max_y)) continue;
            // if (binary_search(x_coord.get(@intFromFloat(min_y)) orelse continue, min_x) != binary_search(x_coord.get(@intFromFloat(min_y)) orelse continue, max_x)) continue;
            // if (binary_search(x_coord.get(@intFromFloat(max_y)) orelse continue, min_x) != binary_search(x_coord.get(@intFromFloat(max_y)) orelse continue, max_x)) continue;
            // return a.area;
        }
    }
    return areas.items[0].area;
}

const Rect = struct {
    top_left: Point,
    top_right: Point,
    bottom_left: Point,
    bottom_right: Point,
    area: u64,
};

pub fn add_point_list(allocator: std.mem.Allocator, p1: Point, p2: Point) !void {
    const min_x: usize = @intFromFloat(@min(p1.x, p2.x));
    const max_x: usize = @intFromFloat(@max(p1.x, p2.x));
    const min_y: usize = @intFromFloat(@min(p1.y, p2.y));
    const max_y: usize = @intFromFloat(@max(p1.y, p2.y));
    if (min_x == max_x) {
        for (min_y..max_y) |y_usize| {
            const y: f64 = @floatFromInt(y_usize);
            const p = Point{ .x = p1.x, .y = y };
            const x_entry = try x_coord.getOrPut(@intFromFloat(p.y));
            if (x_entry.found_existing) {
                try x_entry.value_ptr.append(@intFromFloat(p.x));
            } else {
                x_entry.value_ptr.* = std.ArrayList(i64).init(allocator);
                try x_entry.value_ptr.append(@intFromFloat(p.x));
            }
            const y_entry = try y_coord.getOrPut(@intFromFloat(p.x));
            if (y_entry.found_existing) {
                try y_entry.value_ptr.append(@intFromFloat(p.y));
            } else {
                y_entry.value_ptr.* = std.ArrayList(i64).init(allocator);
                try y_entry.value_ptr.append(@intFromFloat(p.y));
            }
        }
    } else {
        for (min_x..max_x) |x_usize| {
            const x: f64 = @floatFromInt(x_usize);
            const p = Point{ .x = x, .y = p1.y };
            const x_entry = try x_coord.getOrPut(@intFromFloat(p.y));
            if (x_entry.found_existing) {
                try x_entry.value_ptr.append(@intFromFloat(p.x));
            } else {
                x_entry.value_ptr.* = std.ArrayList(i64).init(allocator);
                try x_entry.value_ptr.append(@intFromFloat(p.x));
            }
            const y_entry = try y_coord.getOrPut(@intFromFloat(p.x));
            if (y_entry.found_existing) {
                try y_entry.value_ptr.append(@intFromFloat(p.y));
            } else {
                y_entry.value_ptr.* = std.ArrayList(i64).init(allocator);
                try y_entry.value_ptr.append(@intFromFloat(p.y));
            }
        }
    }
}

pub fn day9_p2(self: anytype) !void {
    part2 = true;
    const f = try std.fs.cwd().openFile("inputs/day9/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    lines = std.ArrayList(Line).init(self.allocator);

    var first: ?Point = null;
    var prev: Point = undefined;
    var min_bound: Point = .{ .x = 0, .y = 0 };
    var max_bound: Point = .{ .x = 0, .y = 0 };
    y_coord = std.AutoHashMap(u64, std.ArrayList(i64)).init(self.allocator);
    x_coord = std.AutoHashMap(u64, std.ArrayList(i64)).init(self.allocator);
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
            try lines.append(.{
                .p1 = prev,
                .p2 = new_point,
            });
            try add_point_list(self.allocator, prev, new_point);
        }

        prev = new_point;
    }
    try lines.append(.{
        .p1 = prev,
        .p2 = first.?,
    });
    try add_point_list(self.allocator, prev, first.?);
    var iter = x_coord.iterator();
    while (iter.next()) |item| {
        std.mem.sort(i64, item.value_ptr.items, {}, comptime std.sort.asc(i64));
    }
    iter = y_coord.iterator();
    while (iter.next()) |item| {
        std.mem.sort(i64, item.value_ptr.items, {}, comptime std.sort.asc(i64));
    }
    std.debug.print("Max area of rectangle {d}\n", .{try max_area2(self.allocator)});
    if (max_bound.x > 1000) {
        max_bound.x = 1000;
        max_bound.y = 1000;
    }
    width = @intFromFloat(max_bound.x + 1);
    height = @intFromFloat(max_bound.y + 1);
    try self.window.rect(width, height, 0, 0, 0, 255);
    std.debug.print("Width {d}, {d}\n Height {d}, {d}\n", .{ width, self.window.width, height, self.window.height });
}

pub fn max_area() f64 {
    var area: f64 = 0;
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
