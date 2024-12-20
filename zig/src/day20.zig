const std = @import("std");
// https://adventofcode.com/2024/day/20
// --- Day 20: Race Condition ---
// The Historians are quite pixelated again. This time, a massive, black building looms over you - you're right outside the CPU!

// While The Historians get to work, a nearby program sees that you're idle and challenges you to a race. Apparently, you've arrived just in time for the frequently-held race condition festival!

// The race takes place on a particularly long and twisting code path; programs compete to see who can finish in the fewest picoseconds. The winner even gets their very own mutex!

// They hand you a map of the racetrack (your puzzle input). For example:

// ###############
// #...#...#.....#
// #.#.#.#.#.###.#
// #S#...#.#.#...#
// #######.#.#.###
// #######.#.#...#
// #######.#.###.#
// ###..E#...#...#
// ###.#######.###
// #...###...#...#
// #.#####.#.###.#
// #.#...#.#.#...#
// #.#.#.#.#.#.###
// #...#...#...###
// ###############
// The map consists of track (.) - including the start (S) and end (E) positions (both of which also count as track) - and walls (#).

// When a program runs through the racetrack, it starts at the start position. Then, it is allowed to move up, down, left, or right; each such move takes 1 picosecond. The goal is to reach the end position as quickly as possible. In this example racetrack, the fastest time is 84 picoseconds.

// Because there is only a single path from the start to the end and the programs all go the same speed, the races used to be pretty boring. To make things more interesting, they introduced a new rule to the races: programs are allowed to cheat.

// The rules for cheating are very strict. Exactly once during a race, a program may disable collision for up to 2 picoseconds. This allows the program to pass through walls as if they were regular track. At the end of the cheat, the program must be back on normal track again; otherwise, it will receive a segmentation fault and get disqualified.

// So, a program could complete the course in 72 picoseconds (saving 12 picoseconds) by cheating for the two moves marked 1 and 2:

// ###############
// #...#...12....#
// #.#.#.#.#.###.#
// #S#...#.#.#...#
// #######.#.#.###
// #######.#.#...#
// #######.#.###.#
// ###..E#...#...#
// ###.#######.###
// #...###...#...#
// #.#####.#.###.#
// #.#...#.#.#...#
// #.#.#.#.#.#.###
// #...#...#...###
// ###############
// Or, a program could complete the course in 64 picoseconds (saving 20 picoseconds) by cheating for the two moves marked 1 and 2:

// ###############
// #...#...#.....#
// #.#.#.#.#.###.#
// #S#...#.#.#...#
// #######.#.#.###
// #######.#.#...#
// #######.#.###.#
// ###..E#...12..#
// ###.#######.###
// #...###...#...#
// #.#####.#.###.#
// #.#...#.#.#...#
// #.#.#.#.#.#.###
// #...#...#...###
// ###############
// This cheat saves 38 picoseconds:

// ###############
// #...#...#.....#
// #.#.#.#.#.###.#
// #S#...#.#.#...#
// #######.#.#.###
// #######.#.#...#
// #######.#.###.#
// ###..E#...#...#
// ###.####1##.###
// #...###.2.#...#
// #.#####.#.###.#
// #.#...#.#.#...#
// #.#.#.#.#.#.###
// #...#...#...###
// ###############
// This cheat saves 64 picoseconds and takes the program directly to the end:

// ###############
// #...#...#.....#
// #.#.#.#.#.###.#
// #S#...#.#.#...#
// #######.#.#.###
// #######.#.#...#
// #######.#.###.#
// ###..21...#...#
// ###.#######.###
// #...###...#...#
// #.#####.#.###.#
// #.#...#.#.#...#
// #.#.#.#.#.#.###
// #...#...#...###
// ###############
// Each cheat has a distinct start position (the position where the cheat is activated, just before the first move that is allowed to go through walls) and end position; cheats are uniquely identified by their start position and end position.

// In this example, the total number of cheats (grouped by the amount of time they save) are as follows:

// There are 14 cheats that save 2 picoseconds.
// There are 14 cheats that save 4 picoseconds.
// There are 2 cheats that save 6 picoseconds.
// There are 4 cheats that save 8 picoseconds.
// There are 2 cheats that save 10 picoseconds.
// There are 3 cheats that save 12 picoseconds.
// There is one cheat that saves 20 picoseconds.
// There is one cheat that saves 36 picoseconds.
// There is one cheat that saves 38 picoseconds.
// There is one cheat that saves 40 picoseconds.
// There is one cheat that saves 64 picoseconds.
// You aren't sure what the conditions of the racetrack will be like, so to give yourself as many options as possible, you'll need a list of the best cheats. How many cheats would save you at least 100 picoseconds?

const colors = .{
    .red = "\x1B[91m",
    .green = "\x1B[92m",
    .yellow = "\x1B[93m",
    .blue = "\x1B[94m",
    .magenta = "\x1B[95m",
    .cyan = "\x1B[96m",
    .dark_red = "\x1B[31m",
    .dark_green = "\x1B[32m",
    .dark_yellow = "\x1B[33m",
    .dark_blue = "\x1B[34m",
    .dark_magenta = "\x1B[35m",
    .dark_cyan = "\x1B[36m",
    .white = "\x1B[37m",
    .end = "\x1B[0m",
};

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
var map_width: usize = 0;
var map_height: usize = 0;

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
    pub fn manhattan(self: *const Location, other: Location) u64 {
        return @abs(self.x - other.x) + @abs(self.y - other.y);
    }
};

pub const Graph = struct {
    nodes: std.ArrayList(Node),
    allocator: std.mem.Allocator,
    dist: []u64,
    prev: []std.ArrayList(Node),
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
            .dist = try allocator.alloc(u64, map.items.len),
            .prev = try allocator.alloc(std.ArrayList(Node), map.items.len),
        };
        for (0..ret.prev.len) |i| {
            ret.prev[i] = std.ArrayList(Node).init(allocator);
        }
        for (0..map_height) |i| {
            for (0..map_width) |j| {
                try ret.nodes.append(try Node.init(Location.init(i * map_width + j), allocator));
            }
        }
        for (0..map_height) |i| {
            for (0..map_width) |j| {
                if (map.items[i * map_width + j] != '#') {
                    var curr_node = ret.nodes.items[i * map_width + j];
                    if (j >= 1 and map.items[i * map_width + j - 1] != '#') {
                        try curr_node.add_edge(&ret.nodes.items[i * map_width + j - 1], 1);
                    }
                    if (j < (map_width - 1) and map.items[i * map_width + j + 1] != '#') {
                        try curr_node.add_edge(&ret.nodes.items[i * map_width + j + 1], 1);
                    }
                    if (i >= 1 and map.items[(i - 1) * map_width + j] != '#') {
                        try curr_node.add_edge(&ret.nodes.items[(i - 1) * map_width + j], 1);
                    }
                    if (i < (map_height - 1) and map.items[(i + 1) * map_width + j] != '#') {
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
        self.allocator.free(self.dist);
        for (0..self.prev.len) |i| {
            self.prev[i].deinit();
        }
        self.allocator.free(self.prev);
    }

    pub fn dijkstra(self: *Graph, src: *Node, dest: *Node) !u64 {
        for (0..self.dist.len) |i| {
            self.dist[i] = INF;
        }
        for (0..self.prev.len) |i| {
            self.prev[i].clearRetainingCapacity();
        }

        var prio_q = std.PriorityQueue(Node, void, Node.less_than).init(self.allocator, {});
        defer prio_q.deinit();
        const src_indx = src.loc.to_indx();
        self.dist[src_indx] = 0;
        try prio_q.add(Node{
            .loc = Location.init(src_indx),
            .edges = self.nodes.items[src_indx].edges,
            .cost = 0,
        });
        while (prio_q.items.len > 0) {
            const u = prio_q.remove();
            if (u.loc.eql(dest.loc)) break;
            for (u.edges.items) |edge| {
                const new_cost = u.cost + edge.cost;
                if (new_cost < self.dist[edge.v.loc.to_indx()]) {
                    self.dist[edge.v.loc.to_indx()] = new_cost;
                    self.prev[edge.v.loc.to_indx()].clearRetainingCapacity();
                    try self.prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                    try prio_q.add(Node{
                        .loc = Location.init(edge.v.loc.to_indx()),
                        .edges = self.nodes.items[edge.v.loc.to_indx()].edges,
                        .cost = new_cost,
                    });
                } else if (new_cost == self.dist[edge.v.loc.to_indx()]) {
                    try self.prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                }
            }
        }

        return self.dist[dest.loc.to_indx()];
    }

    pub fn dijkstra_all_paths(self: *Graph, src: *Node, dest: *Node) !u64 {
        for (0..self.dist.len) |i| {
            self.dist[i] = INF;
        }
        for (0..self.prev.len) |i| {
            self.prev[i].clearRetainingCapacity();
        }

        var prio_q = std.PriorityQueue(Node, void, Node.less_than).init(self.allocator, {});
        defer prio_q.deinit();
        const src_indx = src.loc.to_indx();
        self.dist[src_indx] = 0;
        try prio_q.add(Node{
            .loc = Location.init(src_indx),
            .edges = self.nodes.items[src_indx].edges,
            .cost = 0,
        });
        while (prio_q.items.len > 0) {
            const u = prio_q.remove();
            for (u.edges.items) |edge| {
                const new_cost = u.cost + edge.cost;
                if (new_cost < self.dist[edge.v.loc.to_indx()]) {
                    self.dist[edge.v.loc.to_indx()] = new_cost;
                    self.prev[edge.v.loc.to_indx()].clearRetainingCapacity();
                    try self.prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                    try prio_q.add(Node{
                        .loc = Location.init(edge.v.loc.to_indx()),
                        .edges = self.nodes.items[edge.v.loc.to_indx()].edges,
                        .cost = new_cost,
                    });
                } else if (new_cost == self.dist[edge.v.loc.to_indx()]) {
                    try self.prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                }
            }
        }

        return self.dist[dest.loc.to_indx()];
    }

    pub fn trace_path(self: *const Graph, map: std.ArrayList(u8), curr: u64) void {
        if (map.items[curr] == 'O') return;
        if (map.items[curr] == '.') map.items[curr] = 'O';
        for (0..self.prev[curr].items.len) |i| {
            self.trace_path(map, self.prev[curr].items[i].loc.to_indx());
        }
    }
    pub fn trace_path_nodes_exist_helper(self: *const Graph, visited: []bool, curr: u64, node1: u64, node2: u64, node1_exists: *bool, node2_exists: *bool) bool {
        if (node1_exists.* and node2_exists.*) return true;
        if (visited[curr]) return false;
        visited[curr] = true;
        if (curr == node1) node1_exists.* = true;
        if (curr == node2) node2_exists.* = true;
        for (0..self.prev[curr].items.len) |i| {
            const result = self.trace_path_nodes_exist_helper(visited, self.prev[curr].items[i].loc.to_indx(), node1, node2, node1_exists, node2_exists);
            if (result) return true;
        }
        return false;
    }
    pub fn trace_path_nodes_exist(self: *const Graph, curr: u64, node1: u64, node2: u64) !bool {
        var node1_exists = false;
        var node2_exists = false;
        var visited: []bool = try self.allocator.alloc(bool, self.prev.len);
        for (0..visited.len) |i| {
            visited[i] = false;
        }
        defer self.allocator.free(visited);
        return self.trace_path_nodes_exist_helper(visited, curr, node1, node2, &node1_exists, &node2_exists);
    }

    pub fn heuristic(node: *const Node, goal: *const Node) u64 {
        return node.loc.manhattan(goal.loc);
    }

    pub fn a_star(self: *Graph, src: *Node, dest: *Node) !u64 {
        for (0..self.dist.len) |i| {
            self.dist[i] = INF;
        }

        for (0..self.prev.len) |i| {
            self.prev[i].clearRetainingCapacity();
        }

        var prio_q = std.PriorityQueue(Node, void, Node.less_than).init(self.allocator, {});
        defer prio_q.deinit();
        const src_indx = src.loc.to_indx();
        self.dist[src_indx] = 0;
        try prio_q.add(Node{
            .loc = Location.init(src_indx),
            .edges = self.nodes.items[src_indx].edges,
            .cost = heuristic(src, dest),
        });
        while (prio_q.items.len > 0) {
            const u = prio_q.remove();
            if (u.loc.eql(dest.loc)) break;
            for (u.edges.items) |edge| {
                const new_cost = self.dist[u.loc.to_indx()] + edge.cost;
                const estimated_cost = new_cost + heuristic(edge.v, dest);
                if (new_cost < self.dist[edge.v.loc.to_indx()]) {
                    self.dist[edge.v.loc.to_indx()] = new_cost;
                    self.prev[edge.v.loc.to_indx()].clearRetainingCapacity();
                    try self.prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                    try prio_q.add(Node{
                        .loc = Location.init(edge.v.loc.to_indx()),
                        .edges = self.nodes.items[edge.v.loc.to_indx()].edges,
                        .cost = estimated_cost,
                    });
                } else if (new_cost == self.dist[edge.v.loc.to_indx()]) {
                    try self.prev[edge.v.loc.to_indx()].append(self.nodes.items[u.loc.to_indx()]);
                }
            }
        }

        return self.dist[dest.loc.to_indx()];
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
                '#' => if (with_color) std.debug.print("{s}{c}" ++ colors.end, .{ colors.red, map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                '.' => if (with_color) std.debug.print("{s}{c}" ++ colors.end, .{ colors.green, map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                'S', 'E', '1', '2' => if (with_color) std.debug.print("{s}{c}" ++ colors.end, .{ colors.yellow, map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                'O' => if (with_color) std.debug.print("{s}{c}" ++ colors.end, .{ colors.magenta, map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                else => unreachable,
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn print_costs(map: std.ArrayList(u8), dist: []u64, with_color: bool) void {
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
                '#' => if (with_color) std.debug.print("{s}{c:5}" ++ colors.end, .{ colors.red, map.items[i * map_width + j] }) else std.debug.print("{c:5}", .{map.items[i * map_width + j]}),
                else => if (with_color) std.debug.print("{s}{d:5}" ++ colors.end, .{ colors.magenta, dist[i * map_width + j] }) else std.debug.print("{d:5}", .{dist[i * map_width + j]}),
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn try_cheating(map: std.ArrayList(u8), dist_to_end: []u64) u64 {
    var num_cheats: u64 = 0;
    const CHEAT_THRESHOLD = 100;
    for (0..map_height) |i| {
        for (0..map_width) |j| {
            if (i == 0 or j == 0 or i == map_height - 1 or j == map_width - 1) continue;
            //std.debug.print("{c} {d},{d}\n", .{ map.items[i * map_width + j], j, i });
            if (map.items[i * map_width + j] == '#') {
                const up = dist_to_end[(i - 1) * map_width + j];
                const down = dist_to_end[(i + 1) * map_width + j];
                const right = dist_to_end[i * map_width + j + 1];
                const left = dist_to_end[i * map_width + j - 1];
                if (map.items[i * map_width + j - 1] != '#' and left != Graph.INF) {
                    //std.debug.print("considering {d},{d} => {d},{d}\n", .{ j, i, j - 1, i });
                    //std.debug.print("up {d}, down {d}, left {d}, right {d}\n", .{ up, down, left, right });
                    if (left < up and left < right and left < down) {
                        var max_saving: u64 = 0;
                        if (up != Graph.INF) {
                            max_saving = @max(up - left - 2, max_saving);
                        }
                        if (down != Graph.INF) {
                            max_saving = @max(down - left - 2, max_saving);
                        }
                        if (right != Graph.INF) {
                            max_saving = @max(right - left - 2, max_saving);
                        }
                        if (max_saving >= CHEAT_THRESHOLD) num_cheats += 1;
                        //std.debug.print("Savings of {d}\n", .{max_saving});
                    }
                }
                if (map.items[i * map_width + j + 1] != '#' and right != Graph.INF) {
                    //std.debug.print("considering {d},{d} => {d},{d}\n", .{ j, i, j + 1, i });
                    //std.debug.print("up {d}, down {d}, left {d}, right {d}\n", .{ up, down, left, right });
                    if (right < up and right < left and right < down) {
                        var max_saving: u64 = 0;
                        if (up != Graph.INF) {
                            max_saving = @max(up - right - 2, max_saving);
                        }
                        if (down != Graph.INF) {
                            max_saving = @max(down - right - 2, max_saving);
                        }
                        if (left != Graph.INF) {
                            max_saving = @max(left - right - 2, max_saving);
                        }
                        if (max_saving >= CHEAT_THRESHOLD) num_cheats += 1;
                        //std.debug.print("Savings of {d}\n", .{max_saving});
                    }
                }
                if (map.items[(i - 1) * map_width + j] != '#' and up != Graph.INF) {
                    //std.debug.print("considering {d},{d} => {d},{d}\n", .{ j, i, j, i - 1 });
                    //std.debug.print("up {d}, down {d}, left {d}, right {d}\n", .{ up, down, left, right });
                    if (up < right and up < left and up < down) {
                        var max_saving: u64 = 0;
                        if (right != Graph.INF) {
                            max_saving = @max(right - up - 2, max_saving);
                        }
                        if (down != Graph.INF) {
                            max_saving = @max(down - up - 2, max_saving);
                        }
                        if (left != Graph.INF) {
                            max_saving = @max(left - up - 2, max_saving);
                        }
                        if (max_saving >= CHEAT_THRESHOLD) num_cheats += 1;
                        //std.debug.print("Savings of {d}\n", .{max_saving});
                    }
                }
                if (map.items[(i + 1) * map_width + j] != '#' and down != Graph.INF) {
                    //std.debug.print("considering {d},{d} => {d},{d}\n", .{ j, i, j, i + 1 });
                    //std.debug.print("up {d}, down {d}, left {d}, right {d}\n", .{ up, down, left, right });
                    if (down < right and down < left and down < up) {
                        var max_saving: u64 = 0;
                        if (right != Graph.INF) {
                            max_saving = @max(right - down - 2, max_saving);
                        }
                        if (up != Graph.INF) {
                            max_saving = @max(up - down - 2, max_saving);
                        }
                        if (left != Graph.INF) {
                            max_saving = @max(left - down - 2, max_saving);
                        }
                        if (max_saving >= CHEAT_THRESHOLD) num_cheats += 1;
                        //std.debug.print("Savings of {d}\n", .{max_saving});
                    }
                }
            }
        }
    }
    return num_cheats;
}

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
        if (line.len == 0) continue;
        _ = try map.writer().write(line);
        map_width = line.len;
    }
    map_height = map.items.len / map_width;
    print_map(map, true);
    var dist_to_end: []u64 = try allocator.alloc(u64, map.items.len);
    defer allocator.free(dist_to_end);
    //const start = std.mem.indexOfScalar(u8, map.items, 'S').?;
    const end = std.mem.indexOfScalar(u8, map.items, 'E').?;
    var graph = try Graph.init(allocator, map);
    for (0..dist_to_end.len) |i| {
        dist_to_end[i] = std.math.maxInt(u64);
        if (map.items[i] == '#') continue;
        dist_to_end[i] = try graph.dijkstra(&graph.nodes.items[i], &graph.nodes.items[end]);
    }
    //std.debug.print("{any}\n", .{dist_to_end});
    print_costs(map, dist_to_end, true);
    graph.deinit();
    return try_cheating(map, dist_to_end);
}

// --- Part Two ---
// The programs seem perplexed by your list of cheats. Apparently, the two-picosecond cheating rule was deprecated several milliseconds ago! The latest version of the cheating rule permits a single cheat that instead lasts at most 20 picoseconds.

// Now, in addition to all the cheats that were possible in just two picoseconds, many more cheats are possible. This six-picosecond cheat saves 76 picoseconds:

// ###############
// #...#...#.....#
// #.#.#.#.#.###.#
// #S#...#.#.#...#
// #1#####.#.#.###
// #2#####.#.#...#
// #3#####.#.###.#
// #456.E#...#...#
// ###.#######.###
// #...###...#...#
// #.#####.#.###.#
// #.#...#.#.#...#
// #.#.#.#.#.#.###
// #...#...#...###
// ###############
// Because this cheat has the same start and end positions as the one above, it's the same cheat, even though the path taken during the cheat is different:

// ###############
// #...#...#.....#
// #.#.#.#.#.###.#
// #S12..#.#.#...#
// ###3###.#.#.###
// ###4###.#.#...#
// ###5###.#.###.#
// ###6.E#...#...#
// ###.#######.###
// #...###...#...#
// #.#####.#.###.#
// #.#...#.#.#...#
// #.#.#.#.#.#.###
// #...#...#...###
// ###############
// Cheats don't need to use all 20 picoseconds; cheats can last any amount of time up to and including 20 picoseconds (but can still only end when the program is on normal track). Any cheat time not used is lost; it can't be saved for another cheat later.

// You'll still need a list of the best cheats, but now there are even more to choose between. Here are the quantities of cheats in this example that save 50 picoseconds or more:

// There are 32 cheats that save 50 picoseconds.
// There are 31 cheats that save 52 picoseconds.
// There are 29 cheats that save 54 picoseconds.
// There are 39 cheats that save 56 picoseconds.
// There are 25 cheats that save 58 picoseconds.
// There are 23 cheats that save 60 picoseconds.
// There are 20 cheats that save 62 picoseconds.
// There are 19 cheats that save 64 picoseconds.
// There are 12 cheats that save 66 picoseconds.
// There are 14 cheats that save 68 picoseconds.
// There are 12 cheats that save 70 picoseconds.
// There are 22 cheats that save 72 picoseconds.
// There are 4 cheats that save 74 picoseconds.
// There are 3 cheats that save 76 picoseconds.
// Find the best cheats using the updated cheating rules. How many cheats would save you at least 100 picoseconds?

//TODO instead of just looking at the immediate neighbors look at all neighbors within 20 manhattan distance
pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = file_name;
    _ = allocator;
    return 0;
}

test "day20" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Cheats possible {d} in {d}ms\n", .{ try part1("../inputs/day20/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Cheats possible {d} in {d}ms\n", .{ try part2("../inputs/day20/test.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
