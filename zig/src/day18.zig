const std = @import("std");
// https://adventofcode.com/2024/day/18
// --- Day 18: RAM Run ---
// You and The Historians look a lot more pixelated than you remember. You're inside a computer at the North Pole!

// Just as you're about to check out your surroundings, a program runs up to you. "This region of memory isn't safe! The User misunderstood what a pushdown automaton is and their algorithm is pushing whole bytes down on top of us! Run!"

// The algorithm is fast - it's going to cause a byte to fall into your memory space once every nanosecond! Fortunately, you're faster, and by quickly scanning the algorithm, you create a list of which bytes will fall (your puzzle input) in the order they'll land in your memory space.

// Your memory space is a two-dimensional grid with coordinates that range from 0 to 70 both horizontally and vertically. However, for the sake of example, suppose you're on a smaller grid with coordinates that range from 0 to 6 and the following list of incoming byte positions:

// 5,4
// 4,2
// 4,5
// 3,0
// 2,1
// 6,3
// 2,4
// 1,5
// 0,6
// 3,3
// 2,6
// 5,1
// 1,2
// 5,5
// 2,5
// 6,5
// 1,4
// 0,4
// 6,4
// 1,1
// 6,1
// 1,0
// 0,5
// 1,6
// 2,0
// Each byte position is given as an X,Y coordinate, where X is the distance from the left edge of your memory space and Y is the distance from the top edge of your memory space.

// You and The Historians are currently in the top left corner of the memory space (at 0,0) and need to reach the exit in the bottom right corner (at 70,70 in your memory space, but at 6,6 in this example). You'll need to simulate the falling bytes to plan out where it will be safe to run; for now, simulate just the first few bytes falling into your memory space.

// As bytes fall into your memory space, they make that coordinate corrupted. Corrupted memory coordinates cannot be entered by you or The Historians, so you'll need to plan your route carefully. You also cannot leave the boundaries of the memory space; your only hope is to reach the exit.

// In the above example, if you were to draw the memory space after the first 12 bytes have fallen (using . for safe and # for corrupted), it would look like this:

// ...#...
// ..#..#.
// ....#..
// ...#..#
// ..#..#.
// .#..#..
// #.#....
// You can take steps up, down, left, or right. After just 12 bytes have corrupted locations in your memory space, the shortest path from the top left corner to the exit would take 22 steps. Here (marked with O) is one such path:

// OO.#OOO
// .O#OO#O
// .OOO#OO
// ...#OO#
// ..#OO#.
// .#.O#..
// #.#OOOO
// Simulate the first kilobyte (1024 bytes) falling onto your memory space. Afterward, what is the minimum number of steps needed to reach the exit?

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
var num_buf: [1024]u8 = undefined;
var scratch_str: std.ArrayList(u8) = undefined;
const DEBUG = false;

const map_width: usize = 71;
const map_height: usize = 71;
var NUM_BYTES: usize = 1024;

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

pub const Graph = struct {
    nodes: std.ArrayList(Node),
    allocator: std.mem.Allocator,
    const INF = std.math.maxInt(u64);
    pub const Edge = struct {
        u: *Node,
        v: *Node,
        cost: u64,
    };
    pub const Node = struct {
        loc: Location = undefined,
        edges: *std.ArrayList(Edge),
        cost: u64 = undefined,
        pub fn init(loc: Location, allocator: std.mem.Allocator) !Node {
            const edges = try allocator.create(std.ArrayList(Edge));
            edges.* = std.ArrayList(Edge).init(allocator);
            return .{
                .loc = loc,
                .edges = edges,
            };
        }
        pub fn add_edge(self: *Node, other: *Node, cost: u64) !void {
            try self.edges.append(Edge{
                .u = self,
                .v = other,
                .cost = cost,
            });
        }
        pub fn print(self: *Node) void {
            std.debug.print("Node:\n\tLocation: {any}\n\tEdges:", .{self.loc});
            for (0..self.edges.items.len) |i| {
                std.debug.print("\n\t\tLocation: {any} {d}", .{ self.edges.items[i].v.loc, self.edges.items[i].cost });
            }
            std.debug.print("\n", .{});
        }
        pub fn deinit(self: *Node, allocator: std.mem.Allocator) void {
            self.edges.deinit();
            allocator.destroy(self.edges);
        }
        pub fn less_than(context: void, self: Node, other: Node) std.math.Order {
            _ = context;
            return std.math.order(self.cost, other.cost);
        }
    };
    pub fn init(allocator: std.mem.Allocator, map: std.ArrayList(u8)) !Graph {
        var ret = Graph{
            .nodes = try std.ArrayList(Node).initCapacity(allocator, map_width * map_height),
            .allocator = allocator,
        };
        for (0..map_height) |i| {
            for (0..map_width) |j| {
                try ret.nodes.append(try Node.init(Location.init(i * map_width + j), allocator));
            }
        }
        for (0..map_height) |i| {
            for (0..map_width) |j| {
                if (map.items[i * map_width + j] == '.') {
                    var curr_node = ret.nodes.items[i * map_width + j];
                    if (j >= 1 and map.items[i * map_width + j - 1] == '.') {
                        try curr_node.add_edge(&ret.nodes.items[i * map_width + j - 1], 1);
                    }
                    if (j < (map_width - 1) and map.items[i * map_width + j + 1] == '.') {
                        try curr_node.add_edge(&ret.nodes.items[i * map_width + j + 1], 1);
                    }
                    if (i >= 1 and map.items[(i - 1) * map_width + j] == '.') {
                        try curr_node.add_edge(&ret.nodes.items[(i - 1) * map_width + j], 1);
                    }
                    if (i < (map_height - 1) and map.items[(i + 1) * map_width + j] == '.') {
                        try curr_node.add_edge(&ret.nodes.items[(i + 1) * map_width + j], 1);
                    }
                }
            }
        }
        return ret;
    }

    pub fn deinit(self: *Graph) void {
        for (0..self.nodes.items.len) |i| {
            self.nodes.items[i].deinit(self.allocator);
        }
        self.nodes.deinit();
    }

    pub fn trace_path(map: std.ArrayList(u8), prev: []std.ArrayList(Node), curr: u64) void {
        map.items[curr] = 'O';
        for (0..prev[curr].items.len) |i| {
            trace_path(map, prev, prev[curr].items[i].loc.to_indx());
        }
    }

    pub fn dijkstra(self: *Graph, allocator: std.mem.Allocator, map: std.ArrayList(u8), src: *Node, dest: *Node) !u64 {
        _ = map;
        var dist: []u64 = try allocator.alloc(u64, self.nodes.items.len);
        defer allocator.free(dist);
        for (0..dist.len) |i| {
            dist[i] = INF;
        }
        var prev: []std.ArrayList(Node) = try allocator.alloc(std.ArrayList(Node), self.nodes.items.len);
        for (0..prev.len) |i| {
            prev[i] = std.ArrayList(Node).init(allocator);
        }
        defer allocator.free(prev);

        var prio_q = std.PriorityQueue(Node, void, Node.less_than).init(allocator, {});
        defer prio_q.deinit();
        const src_indx = src.loc.to_indx();
        dist[src_indx] = 0;
        try prio_q.add(Node{
            .loc = Location.init(src_indx),
            .edges = self.nodes.items[src_indx].edges,
            .cost = 0,
        });
        while (prio_q.items.len > 0) {
            const u = prio_q.remove();
            for (u.edges.items) |edge| {
                const new_cost = u.cost + edge.cost;
                if (new_cost < dist[edge.v.loc.to_indx()]) {
                    dist[edge.v.loc.to_indx()] = new_cost;
                    prev[edge.v.loc.to_indx()].clearRetainingCapacity();
                    try prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                    try prio_q.add(Node{
                        .loc = Location.init(edge.v.loc.to_indx()),
                        .edges = self.nodes.items[edge.v.loc.to_indx()].edges,
                        .cost = new_cost,
                    });
                } else if (new_cost == dist[edge.v.loc.to_indx()]) {
                    try prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                }
            }
        }
        // add path trace
        //trace_path(map, prev, dest.loc.to_indx());
        for (0..prev.len) |i| {
            prev[i].deinit();
        }

        return dist[dest.loc.to_indx()];
    }
};

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
                '.' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[1], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                //'^', 'v', '<', '>' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[5], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                'O' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[4], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                else => unreachable,
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn build_map(map: *std.ArrayList(u8), bytes: std.ArrayList(Location)) !void {
    for (0..map_height) |_| {
        for (0..map_width) |_| {
            try map.append('.');
        }
    }
    for (0..NUM_BYTES) |i| {
        map.items[bytes.items[i].to_indx()] = '#';
    }
}

pub fn update_map(map: *std.ArrayList(u8), bytes: std.ArrayList(Location), start: usize) void {
    for (start..NUM_BYTES) |i| {
        map.items[bytes.items[i].to_indx()] = '#';
    }
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var bytes = std.ArrayList(Location).init(allocator);
    defer bytes.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var it = std.mem.splitScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i64, it.next().?, 10);
        const y = try std.fmt.parseInt(i64, it.next().?, 10);
        try bytes.append(Location{
            .x = x,
            .y = y,
        });
    }
    try build_map(&map, bytes);
    var graph = try Graph.init(allocator, map);
    defer graph.deinit();
    //std.debug.print("Graph {any}\n", .{graph});
    print_map(map, true);
    // std.debug.print("Start\n", .{});
    // graph.nodes.items[0].print();
    // graph.nodes.items[map_height * map_width - 1].print();
    const score = try graph.dijkstra(allocator, map, &graph.nodes.items[0], &graph.nodes.items[map_height * map_width - 1]);
    print_map(map, true);
    return score;
}

// --- Part Two ---
// The Historians aren't as used to moving around in this pixelated universe as you are. You're afraid they're not going to be fast enough to make it to the exit before the path is completely blocked.

// To determine how fast everyone needs to go, you need to determine the first byte that will cut off the path to the exit.

// In the above example, after the byte at 1,1 falls, there is still a path to the exit:

// O..#OOO
// O##OO#O
// O#OO#OO
// OOO#OO#
// ###OO##
// .##O###
// #.#OOOO
// However, after adding the very next byte (at 6,1), there is no longer a path to the exit:

// ...#...
// .##..##
// .#..#..
// ...#..#
// ###..##
// .##.###
// #.#....
// So, in this example, the coordinates of the first byte that prevents the exit from being reachable are 6,1.

// Simulate more of the bytes that are about to corrupt your memory space. What are the coordinates of the first byte that will prevent the exit from being reachable from your starting position? (Provide the answer as two integers separated by a comma with no other characters.)

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var bytes = std.ArrayList(Location).init(allocator);
    defer bytes.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var it = std.mem.splitScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i64, it.next().?, 10);
        const y = try std.fmt.parseInt(i64, it.next().?, 10);
        try bytes.append(Location{
            .x = x,
            .y = y,
        });
    }
    try build_map(&map, bytes);
    var graph = try Graph.init(allocator, map);
    defer graph.deinit();
    //std.debug.print("Graph {any}\n", .{graph});
    //print_map(map, true);
    // std.debug.print("Start\n", .{});
    // graph.nodes.items[0].print();
    // graph.nodes.items[map_height * map_width - 1].print();
    var score = try graph.dijkstra(allocator, map, &graph.nodes.items[0], &graph.nodes.items[map_height * map_width - 1]);
    while (score != Graph.INF) {
        const prev = NUM_BYTES;
        NUM_BYTES += 1;
        update_map(&map, bytes, prev);
        graph.deinit();
        graph = try Graph.init(allocator, map);
        score = try graph.dijkstra(allocator, map, &graph.nodes.items[0], &graph.nodes.items[map_height * map_width - 1]);
    }
    print_map(map, true);
    return std.fmt.bufPrint(&num_buf, "({d},{d})", .{ bytes.items[NUM_BYTES - 1].x, bytes.items[NUM_BYTES - 1].y });
}

test "day18" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Minimum number of steps needed to reach the exit {d} in {d}ms\n", .{ try part1("../inputs/day18/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("First byte {s} in {d}ms\n", .{ try part2("../inputs/day18/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
