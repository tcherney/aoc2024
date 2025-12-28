const std = @import("std");
// https://adventofcode.com/2024/day/16
// --- Day 16: Reindeer Maze ---
// It's time again for the Reindeer Olympics! This year, the big event is the Reindeer Maze, where the Reindeer compete for the lowest score.

// You and The Historians arrive to search for the Chief right as the event is about to start. It wouldn't hurt to watch a little, right?

// The Reindeer start on the Start Tile (marked S) facing East and need to reach the End Tile (marked E). They can move forward one tile at a time (increasing their score by 1 point), but never into a wall (#). They can also rotate clockwise or counterclockwise 90 degrees at a time (increasing their score by 1000 points).

// To figure out the best place to sit, you start by grabbing a map (your puzzle input) from a nearby kiosk. For example:

// ###############
// #.......#....E#
// #.#.###.#.###.#
// #.....#.#...#.#
// #.###.#####.#.#
// #.#.#.......#.#
// #.#.#####.###.#
// #...........#.#
// ###.#.#####.#.#
// #...#.....#.#.#
// #.#.#.###.#.#.#
// #.....#...#.#.#
// #.###.#.#.#.#.#
// #S..#.....#...#
// ###############
// There are many paths through this maze, but taking any of the best paths would incur a score of only 7036. This can be achieved by taking a total of 36 steps forward and turning 90 degrees a total of 7 times:

// ###############
// #.......#....E#
// #.#.###.#.###^#
// #.....#.#...#^#
// #.###.#####.#^#
// #.#.#.......#^#
// #.#.#####.###^#
// #..>>>>>>>>v#^#
// ###^#.#####v#^#
// #>>^#.....#v#^#
// #^#.#.###.#v#^#
// #^....#...#v#^#
// #^###.#.#.#v#^#
// #S..#.....#>>^#
// ###############
// Here's a second example:

// #################
// #...#...#...#..E#
// #.#.#.#.#.#.#.#.#
// #.#.#.#...#...#.#
// #.#.#.#.###.#.#.#
// #...#.#.#.....#.#
// #.#.#.#.#.#####.#
// #.#...#.#.#.....#
// #.#.#####.#.###.#
// #.#.#.......#...#
// #.#.###.#####.###
// #.#.#...#.....#.#
// #.#.#.#####.###.#
// #.#.#.........#.#
// #.#.#.#########.#
// #S#.............#
// #################
// In this maze, the best paths cost 11048 points; following one such path would look like this:

// #################
// #...#...#...#..E#
// #.#.#.#.#.#.#.#^#
// #.#.#.#...#...#^#
// #.#.#.#.###.#.#^#
// #>>v#.#.#.....#^#
// #^#v#.#.#.#####^#
// #^#v..#.#.#>>>>^#
// #^#v#####.#^###.#
// #^#v#..>>>>^#...#
// #^#v###^#####.###
// #^#v#>>^#.....#.#
// #^#v#^#####.###.#
// #^#v#^........#.#
// #^#v#^#########.#
// #S#>>^..........#
// #################
// Note that the path shown above includes one 90 degree turn as the very first move, rotating the Reindeer from facing East to facing North.

// Analyze your map carefully. What is the lowest score a Reindeer could possibly get?

const colors: [13][]const u8 = .{
    "\x1B[91m",
    "\x1B[92m",
    "\x1B[93m",
    "\x1B[94m",
    "\x1B[95m",
    "\x1B[96m",
    "\x1B[31m",
    "\x1B[32m",
    "\x1B[33m",
    "\x1B[34m",
    "\x1B[35m",
    "\x1B[36m",
    "\x1B[37m",
};

const color_end = "\x1B[0m";
//ansi escape codes
const esc = "\x1B";
const csi = esc ++ "[";

const cursor_show = csi ++ "?25h"; //h=high
const cursor_hide = csi ++ "?25l"; //l=low
const cursor_home = csi ++ "1;1H"; //1,1

const color_fg = "38;5;";
const color_bg = "48;5;";
const color_fg_def = csi ++ color_fg ++ "15m"; // white
const color_bg_def = csi ++ color_bg ++ "0m"; // black
const color_def = color_bg_def ++ color_fg_def;

const screen_clear = csi ++ "2J";
const screen_buf_on = csi ++ "?1049h"; //h=high
const screen_buf_off = csi ++ "?1049l"; //l=low

const nl = "\n";

const term_on = screen_buf_on ++ cursor_hide ++ cursor_home ++ screen_clear ++ color_def;
const term_off = screen_buf_off ++ cursor_show ++ nl;
var map_width: usize = undefined;
var map_height: usize = undefined;

pub const Location = struct {
    x: i64,
    y: i64,
    pub fn init(indx: usize) Location {
        const x = @as(i64, @bitCast(indx % map_width));
        return .{
            .x = x,
            .y = @as(i64, @bitCast(@divFloor(@as(i64, @bitCast(indx)) - @as(i64, @bitCast(x)), @as(i64, @bitCast(map_width))))),
        };
    }
    pub fn to_indx(loc: *const Location) usize {
        return @as(usize, @bitCast(loc.y)) * map_width + @as(usize, @bitCast(loc.x));
    }
    pub fn eql(self: *const Location, other: Location) bool {
        return self.x == other.x and self.y == other.y;
    }
};

pub const Reindeer = struct {
    loc: Location = undefined,
    dir: Direction = Direction.East,
    pub const Direction = enum { North, South, West, East };
    pub fn navigate(self: *Reindeer, map: std.ArrayList(u8), allocator: std.mem.Allocator, end: Location) !u64 {
        return try self.dijkstra(map, allocator, end);
    }
    pub fn compute_cost(starting_dir: Direction, movement_dir: Direction) u64 {
        switch (starting_dir) {
            .North => {
                switch (movement_dir) {
                    .North => {
                        return 1;
                    },
                    .South => {
                        return 2001;
                    },
                    .East => {
                        return 1001;
                    },
                    .West => {
                        return 1001;
                    },
                }
            },
            .South => {
                switch (movement_dir) {
                    .North => {
                        return 2001;
                    },
                    .South => {
                        return 1;
                    },
                    .East => {
                        return 1001;
                    },
                    .West => {
                        return 1001;
                    },
                }
            },
            .East => {
                switch (movement_dir) {
                    .North => {
                        return 1001;
                    },
                    .South => {
                        return 1001;
                    },
                    .East => {
                        return 1;
                    },
                    .West => {
                        return 2001;
                    },
                }
            },
            .West => {
                switch (movement_dir) {
                    .North => {
                        return 1001;
                    },
                    .South => {
                        return 1001;
                    },
                    .East => {
                        return 2001;
                    },
                    .West => {
                        return 1;
                    },
                }
            },
        }
    }
    pub fn trace_index(map: std.ArrayList(u8), dist: []Reindeer.DistanceNode, current_loc: Location, src_indx: u64, curr_cost: u64, curr_dir: Reindeer.Direction) void {
        const MAX_INT = std.math.maxInt(u64);
        if (current_loc.to_indx() == src_indx) return;
        map.items[current_loc.to_indx()] = 'O';
        const north = Location{
            .x = current_loc.x,
            .y = current_loc.y - 1,
        };
        const south = Location{
            .x = current_loc.x,
            .y = current_loc.y + 1,
        };
        const west = Location{
            .x = current_loc.x - 1,
            .y = current_loc.y,
        };
        const east = Location{
            .x = current_loc.x + 1,
            .y = current_loc.y,
        };
        //std.debug.print("Comparing ({any}) ({any}) to ({any}) ({any})\n", .{ north, dist[north.to_indx()], current_loc, dist[current_loc.to_indx()] });
        if (map.items[north.to_indx()] != '#') {
            const result = dist[north.to_indx()].path_exists(curr_cost, curr_dir);
            if (result.cost != MAX_INT) {
                //std.debug.print("Taking path {any} with {any} cost\n", .{ dist[north.to_indx()], result });
                trace_index(map, dist, north, src_indx, result.cost, result.dir);
            }
        }
        //std.debug.print("Comparing ({any}) ({any}) to ({any}) ({any})\n", .{ south, dist[south.to_indx()], current_loc, dist[current_loc.to_indx()] });
        if (map.items[south.to_indx()] != '#') {
            const result = dist[south.to_indx()].path_exists(curr_cost, curr_dir);
            if (result.cost != MAX_INT) {
                //std.debug.print("Taking path {any} with {any} cost\n", .{ dist[south.to_indx()], result });
                trace_index(map, dist, south, src_indx, result.cost, result.dir);
            }
        }
        //std.debug.print("Comparing ({any}) ({any}) to ({any}) ({any})\n", .{ west, dist[west.to_indx()], current_loc, dist[current_loc.to_indx()] });
        if (map.items[west.to_indx()] != '#') {
            const result = dist[west.to_indx()].path_exists(curr_cost, curr_dir);
            if (result.cost != MAX_INT) {
                //std.debug.print("Taking path {any} with {any} cost\n", .{ dist[west.to_indx()], result });
                trace_index(map, dist, west, src_indx, result.cost, result.dir);
            }
        }
        //std.debug.print("Comparing ({any}) ({any}) to ({any}) ({any})\n", .{ east, dist[east.to_indx()], current_loc, dist[current_loc.to_indx()] });
        if (map.items[east.to_indx()] != '#') {
            const result = dist[east.to_indx()].path_exists(curr_cost, curr_dir);
            if (result.cost != MAX_INT) {
                //std.debug.print("Taking path {any} with {any} cost\n", .{ dist[east.to_indx()], result });
                trace_index(map, dist, east, src_indx, result.cost, result.dir);
            }
        }
    }

    pub const VisitedNode = struct {
        visited_north: bool = false,
        visited_south: bool = false,
        visited_west: bool = false,
        visited_east: bool = false,
        pub fn has_visited(self: *VisitedNode, dir: Reindeer.Direction) bool {
            switch (dir) {
                .North => return self.visited_north,
                .South => return self.visited_south,
                .West => return self.visited_west,
                .East => return self.visited_east,
            }
        }
        pub fn visit(self: *VisitedNode, dir: Reindeer.Direction) void {
            switch (dir) {
                .North => self.visited_north = true,
                .South => self.visited_south = true,
                .West => self.visited_west = true,
                .East => self.visited_east = true,
            }
        }
        pub fn clear_visit(self: *VisitedNode, dir: Reindeer.Direction) void {
            switch (dir) {
                .North => self.visited_north = false,
                .South => self.visited_south = false,
                .West => self.visited_west = false,
                .East => self.visited_east = false,
            }
        }
    };

    pub const DistanceNode = struct {
        distance_north: u64 = std.math.maxInt(u64),
        distance_south: u64 = std.math.maxInt(u64),
        distance_west: u64 = std.math.maxInt(u64),
        distance_east: u64 = std.math.maxInt(u64),
        pub fn get_cost(self: *DistanceNode, dir: Reindeer.Direction) u64 {
            switch (dir) {
                .North => return self.distance_north,
                .South => return self.distance_south,
                .West => return self.distance_west,
                .East => return self.distance_east,
            }
        }
        pub fn set_cost(self: *DistanceNode, cost: u64, dir: Reindeer.Direction) void {
            switch (dir) {
                .North => self.distance_north = cost,
                .South => self.distance_south = cost,
                .West => self.distance_west = cost,
                .East => self.distance_east = cost,
            }
        }
        pub fn min_cost(self: *DistanceNode) u64 {
            return @min(self.distance_north, self.distance_south, self.distance_east, self.distance_west);
        }
        pub fn min_dir(self: *DistanceNode) Reindeer.Direction {
            const min = self.min_cost();
            if (self.distance_north == min) return Reindeer.Direction.North;
            if (self.distance_south == min) return Reindeer.Direction.South;
            if (self.distance_east == min) return Reindeer.Direction.East;
            return Reindeer.Direction.West;
        }
        pub fn path_exists(self: *DistanceNode, cost: u64, dir: Reindeer.Direction) struct { cost: u64, dir: Reindeer.Direction } {
            const MAX_INT = std.math.maxInt(u64);
            switch (dir) {
                .North => {
                    if (cost > self.distance_north) {
                        if (cost - self.distance_north == 1) return .{ .cost = self.distance_north, .dir = .North };
                    }
                    if (cost > self.distance_east) {
                        if (cost - self.distance_east == 1001) return .{ .cost = self.distance_east, .dir = .East };
                    }
                    if (cost > self.distance_west) {
                        if (cost - self.distance_west == 1001) return .{ .cost = self.distance_west, .dir = .West };
                    }
                },
                .South => {
                    if (cost > self.distance_south) {
                        if (cost - self.distance_south == 1) return .{ .cost = self.distance_south, .dir = .South };
                    }
                    if (cost > self.distance_east) {
                        if (cost - self.distance_east == 1001) return .{ .cost = self.distance_east, .dir = .East };
                    }
                    if (cost > self.distance_west) {
                        if (cost - self.distance_west == 1001) return .{ .cost = self.distance_west, .dir = .West };
                    }
                },
                .East => {
                    if (cost > self.distance_east) {
                        if (cost - self.distance_east == 1) return .{ .cost = self.distance_east, .dir = .East };
                    }
                    if (cost > self.distance_north) {
                        if (cost - self.distance_north == 1001) return .{ .cost = self.distance_north, .dir = .North };
                    }
                    if (cost > self.distance_south) {
                        if (cost - self.distance_south == 1001) return .{ .cost = self.distance_south, .dir = .South };
                    }
                },
                .West => {
                    if (cost > self.distance_west) {
                        if (cost - self.distance_west == 1) return .{ .cost = self.distance_west, .dir = .West };
                    }
                    if (cost > self.distance_north) {
                        if (cost - self.distance_north == 1001) return .{ .cost = self.distance_north, .dir = .North };
                    }
                    if (cost > self.distance_south) {
                        if (cost - self.distance_south == 1001) return .{ .cost = self.distance_south, .dir = .South };
                    }
                },
            }
            return .{ .cost = MAX_INT, .dir = .North };
        }
    };

    pub fn dijkstra(self: *Reindeer, map: std.ArrayList(u8), allocator: std.mem.Allocator, end: Location) !u64 {
        var dist: []DistanceNode = try allocator.alloc(DistanceNode, map.items.len);
        defer allocator.free(dist);
        for (0..dist.len) |i| {
            dist[i] = DistanceNode{};
        }
        var prev: []std.ArrayList(u64) = try allocator.alloc(std.ArrayList(u64), map.items.len);
        for (0..prev.len) |i| {
            prev[i] = std.ArrayList(u64).init(allocator);
        }
        defer allocator.free(prev);
        var visited: []VisitedNode = try allocator.alloc(VisitedNode, map.items.len);
        for (0..visited.len) |i| {
            visited[i] = VisitedNode{};
        }
        defer allocator.free(visited);
        var prio_q = std.PriorityQueue(Node, void, Node.less_than).init(allocator, {});
        defer prio_q.deinit();
        const src_indx = self.loc.to_indx();
        dist[src_indx].set_cost(0, self.dir);
        try prio_q.add(Node{
            .loc = Location.init(src_indx),
            .cost = 0,
            .direction = self.dir,
        });
        while (prio_q.items.len > 0) {
            const u = prio_q.remove();
            //std.debug.print("Pulled {any} {any}{d} with cost {d}\n", .{ u, u.loc, u.loc.to_indx(), u.cost });
            if (visited[u.loc.to_indx()].has_visited(u.direction) and u.cost >= dist[u.loc.to_indx()].get_cost(u.direction)) continue;
            visited[u.loc.to_indx()].visit(u.direction);
            if (u.cost <= dist[u.loc.to_indx()].min_cost()) {
                switch (u.direction) {
                    .North => map.items[u.loc.to_indx()] = '^',
                    .South => map.items[u.loc.to_indx()] = 'v',
                    .East => map.items[u.loc.to_indx()] = '>',
                    .West => map.items[u.loc.to_indx()] = '<',
                }
            }
            //print_map(map, true);
            const north = Location{
                .x = u.loc.x,
                .y = u.loc.y - 1,
            };
            const south = Location{
                .x = u.loc.x,
                .y = u.loc.y + 1,
            };
            const west = Location{
                .x = u.loc.x - 1,
                .y = u.loc.y,
            };
            const east = Location{
                .x = u.loc.x + 1,
                .y = u.loc.y,
            };
            if (map.items[north.to_indx()] != '#' and (u.direction != .South)) {
                const alt = u.cost + compute_cost(u.direction, Direction.North);
                if (!visited[north.to_indx()].has_visited(Direction.North) or alt <= dist[north.to_indx()].get_cost(.North)) {
                    //std.debug.print("appending {d} to {d}\n", .{ u.loc.to_indx(), north.to_indx() });
                    if (alt <= dist[north.to_indx()].get_cost(.North)) dist[north.to_indx()].set_cost(alt, .North);
                    try prio_q.add(Node{
                        .loc = north,
                        .cost = alt,
                        .direction = Direction.North,
                    });
                }
            }
            if (map.items[south.to_indx()] != '#' and (u.direction != .North)) {
                const alt = u.cost + compute_cost(u.direction, Direction.South);
                if (!visited[south.to_indx()].has_visited(Direction.South) or alt <= dist[south.to_indx()].get_cost(.South)) {
                    //std.debug.print("appending {d} to {d}\n", .{ u.loc.to_indx(), south.to_indx() });
                    if (alt <= dist[south.to_indx()].get_cost(.South)) dist[south.to_indx()].set_cost(alt, .South);
                    try prio_q.add(Node{
                        .loc = south,
                        .cost = alt,
                        .direction = Direction.South,
                    });
                }
            }
            if (map.items[west.to_indx()] != '#' and (u.direction != .East)) {
                const alt = u.cost + compute_cost(u.direction, Direction.West);
                if (!visited[west.to_indx()].has_visited(Direction.West) or alt <= dist[west.to_indx()].get_cost(.West)) {
                    //std.debug.print("appending {d} to {d}\n", .{ u.loc.to_indx(), west.to_indx() });
                    if (alt <= dist[west.to_indx()].get_cost(.West)) dist[west.to_indx()].set_cost(alt, .West);
                    try prio_q.add(Node{
                        .loc = west,
                        .cost = alt,
                        .direction = Direction.West,
                    });
                }
            }
            if (map.items[east.to_indx()] != '#' and (u.direction != .West)) {
                const alt = u.cost + compute_cost(u.direction, Direction.East);
                if (!visited[east.to_indx()].has_visited(Direction.East) or alt <= dist[east.to_indx()].get_cost(.East)) {
                    //std.debug.print("appending {d} to {d}\n", .{ u.loc.to_indx(), east.to_indx() });
                    if (alt <= dist[east.to_indx()].get_cost(.East)) dist[east.to_indx()].set_cost(alt, .East);
                    try prio_q.add(Node{
                        .loc = east,
                        .cost = alt,
                        .direction = Direction.East,
                    });
                }
            }
        }

        map.items[src_indx] = 'S';
        //trace path
        const current_loc: Location = end;
        trace_index(map, dist, current_loc, src_indx, dist[end.to_indx()].min_cost(), dist[end.to_indx()].min_dir());
        //print_costs(map, dist, true);
        for (0..prev.len) |i| {
            prev[i].deinit();
        }
        map.items[end.to_indx()] = 'E';
        return dist[end.to_indx()].min_cost();
    }
};

pub const Node = struct {
    loc: Location = undefined,
    cost: u64 = std.math.maxInt(u64),
    direction: Reindeer.Direction = undefined,
    pub fn less_than(context: void, self: Node, other: Node) std.math.Order {
        _ = context;
        return std.math.order(self.cost, other.cost);
    }
};

pub fn print_costs(map: std.ArrayList(u8), dist: []Reindeer.DistanceNode, with_color: bool) void {
    std.debug.print("width {d} height {d}\n", .{ map_width, map_height });
    std.debug.print(" ", .{});
    for (0..map_width) |j| {
        std.debug.print("{d:5}", .{j % 10});
    }
    std.debug.print("\n", .{});
    for (0..map_height) |i| {
        for (0..map_width) |j| {
            if (j == 0) {
                std.debug.print("{d:5}", .{i % 10});
            }
            switch (map.items[i * map_width + j]) {
                '#' => if (with_color) std.debug.print("{s}{c:5}" ++ color_end, .{ colors[0], map.items[i * map_width + j] }) else std.debug.print("{c:5}", .{map.items[i * map_width + j]}),
                else => if (with_color) std.debug.print("{s}{d:5}" ++ color_end, .{ colors[4], dist[i * map_width + j].min_cost() }) else std.debug.print("{d:5}", .{dist[i * map_width + j].min_cost()}),
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn print_map(map: std.ArrayList(u8), with_color: bool) void {
    std.debug.print("width {d} height {d}\n", .{ map_width, map_height });
    std.debug.print(" ", .{});
    for (0..map_width) |j| {
        std.debug.print("{d}", .{j % 10});
    }
    std.debug.print("\n", .{});
    for (0..map_height) |i| {
        for (0..map_width) |j| {
            if (j == 0) {
                std.debug.print("{d}", .{i % 10});
            }
            switch (map.items[i * map_width + j]) {
                '#' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[0], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                'S', 'E' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[2], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                '.' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[1], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                '^', 'v', '<', '>' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[5], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                'O' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[4], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                else => unreachable,
            }
        }
        std.debug.print("\n", .{});
    }
}

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
        _ = try map.writer().write(line);
        map_width = line.len;
    }
    map_height = map.items.len / map_width;
    print_map(map, true);
    var rudolph = Reindeer{
        .loc = Location.init(std.mem.indexOfScalar(u8, map.items, 'S').?),
    };
    std.debug.print("Rudolph {any}\n", .{rudolph});
    const end = Location.init(std.mem.indexOfScalar(u8, map.items, 'E').?);
    std.debug.print("End {any}\n", .{end});
    const result = try rudolph.navigate(map, allocator, end);
    print_map(map, true);
    return result;
}

// --- Part Two ---
// Now that you know what the best paths look like, you can figure out the best spot to sit.

// Every non-wall tile (S, ., or E) is equipped with places to sit along the edges of the tile. While determining which of these tiles would be the best spot to sit depends on a whole bunch of factors (how comfortable the seats are, how far away the bathrooms are, whether there's a pillar blocking your view, etc.), the most important factor is whether the tile is on one of the best paths through the maze. If you sit somewhere else, you'd miss all the action!

// So, you'll need to determine which tiles are part of any best path through the maze, including the S and E tiles.

// In the first example, there are 45 tiles (marked O) that are part of at least one of the various best paths through the maze:

// ###############
// #.......#....O#
// #.#.###.#.###O#
// #.....#.#...#O#
// #.###.#####.#O#
// #.#.#.......#O#
// #.#.#####.###O#
// #..OOOOOOOOO#O#
// ###O#O#####O#O#
// #OOO#O....#O#O#
// #O#O#O###.#O#O#
// #OOOOO#...#O#O#
// #O###.#.#.#O#O#
// #O..#.....#OOO#
// ###############
// In the second example, there are 64 tiles that are part of at least one of the best paths:

// #################
// #...#...#...#..O#
// #.#.#.#.#.#.#.#O#
// #.#.#.#...#...#O#
// #.#.#.#.###.#.#O#
// #OOO#.#.#.....#O#
// #O#O#.#.#.#####O#
// #O#O..#.#.#OOOOO#
// #O#O#####.#O###O#
// #O#O#..OOOOO#OOO#
// #O#O###O#####O###
// #O#O#OOO#..OOO#.#
// #O#O#O#####O###.#
// #O#O#OOOOOOO..#.#
// #O#O#O#########.#
// #O#OOO..........#
// #################
// Analyze your map further. How many tiles are part of at least one of the best paths through the maze?

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
        _ = try map.writer().write(line);
        map_width = line.len;
    }
    map_height = map.items.len / map_width;
    print_map(map, true);
    var rudolph = Reindeer{
        .loc = Location.init(std.mem.indexOfScalar(u8, map.items, 'S').?),
    };
    std.debug.print("Rudolph {any}\n", .{rudolph});
    const end = Location.init(std.mem.indexOfScalar(u8, map.items, 'E').?);
    std.debug.print("End {any}\n", .{end});
    _ = try rudolph.dijkstra(map, allocator, end);
    print_map(map, true);
    return std.mem.count(u8, map.items, "O") + 2;
}

test "day16" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Lowest score {d} in {d}ms\n", .{ try part1("inputs/day16/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Tiles in shortest paths {d} in {d}ms\n", .{ try part2("inputs/day16/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
