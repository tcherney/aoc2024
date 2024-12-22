const std = @import("std");
// https://adventofcode.com/2024/day/21
// --- Day 21: Keypad Conundrum ---
// As you teleport onto Santa's Reindeer-class starship, The Historians begin to panic: someone from their search party is missing. A quick life-form scan by the ship's computer reveals that when the missing Historian teleported, he arrived in another part of the ship.

// The door to that area is locked, but the computer can't open it; it can only be opened by physically typing the door codes (your puzzle input) on the numeric keypad on the door.

// The numeric keypad has four rows of buttons: 789, 456, 123, and finally an empty gap followed by 0A. Visually, they are arranged like this:

// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//     | 0 | A |
//     +---+---+
// Unfortunately, the area outside the door is currently depressurized and nobody can go near the door. A robot needs to be sent instead.

// The robot has no problem navigating the ship and finding the numeric keypad, but it's not designed for button pushing: it can't be told to push a specific button directly. Instead, it has a robotic arm that can be controlled remotely via a directional keypad.

// The directional keypad has two rows of buttons: a gap / ^ (up) / A (activate) on the first row and < (left) / v (down) / > (right) on the second row. Visually, they are arranged like this:

//     +---+---+
//     | ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+
// When the robot arrives at the numeric keypad, its robotic arm is pointed at the A button in the bottom right corner. After that, this directional keypad remote control must be used to maneuver the robotic arm: the up / down / left / right buttons cause it to move its arm one button in that direction, and the A button causes the robot to briefly move forward, pressing the button being aimed at by the robotic arm.

// For example, to make the robot type 029A on the numeric keypad, one sequence of inputs on the directional keypad you could use is:

// < to move the arm from A (its initial position) to 0.
// A to push the 0 button.
// ^A to move the arm to the 2 button and push it.
// >^^A to move the arm to the 9 button and push it.
// vvvA to move the arm to the A button and push it.
// In total, there are three shortest possible sequences of button presses on this directional keypad that would cause the robot to type 029A: <A^A>^^AvvvA, <A^A^>^AvvvA, and <A^A^^>AvvvA.

// Unfortunately, the area containing this directional keypad remote control is currently experiencing high levels of radiation and nobody can go near it. A robot needs to be sent instead.

// When the robot arrives at the directional keypad, its robot arm is pointed at the A button in the upper right corner. After that, a second, different directional keypad remote control is used to control this robot (in the same way as the first robot, except that this one is typing on a directional keypad instead of a numeric keypad).

// There are multiple shortest possible sequences of directional keypad button presses that would cause this robot to tell the first robot to type 029A on the door. One such sequence is v<<A>>^A<A>AvA<^AA>A<vAAA>^A.

// Unfortunately, the area containing this second directional keypad remote control is currently -40 degrees! Another robot will need to be sent to type on that directional keypad, too.

// There are many shortest possible sequences of directional keypad button presses that would cause this robot to tell the second robot to tell the first robot to eventually type 029A on the door. One such sequence is <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A.

// Unfortunately, the area containing this third directional keypad remote control is currently full of Historians, so no robots can find a clear path there. Instead, you will have to type this sequence yourself.

// Were you to choose this sequence of button presses, here are all of the buttons that would be pressed on your directional keypad, the two robots' directional keypads, and the numeric keypad:

// <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
// v<<A>>^A<A>AvA<^AA>A<vAAA>^A
// <A^A>^^AvvvA
// 029A
// In summary, there are the following keypads:

// One directional keypad that you are using.
// Two directional keypads that robots are using.
// One numeric keypad (on a door) that a robot is using.
// It is important to remember that these robots are not designed for button pushing. In particular, if a robot arm is ever aimed at a gap where no button is present on the keypad, even for an instant, the robot will panic unrecoverably. So, don't do that. All robots will initially aim at the keypad's A key, wherever it is.

// To unlock the door, five codes will need to be typed on its numeric keypad. For example:

// 029A
// 980A
// 179A
// 456A
// 379A
// For each of these, here is a shortest sequence of button presses you could type to cause the desired code to be typed on the numeric keypad:

// 029A: <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
// 980A: <v<A>>^AAAvA^A<vA<AA>>^AvAA<^A>A<v<A>A>^AAAvA<^A>A<vA>^A<A>A
// 179A: <v<A>>^A<vA<A>>^AAvAA<^A>A<v<A>>^AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A
// 456A: <v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A
// 379A: <v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A
// The Historians are getting nervous; the ship computer doesn't remember whether the missing Historian is trapped in the area containing a giant electromagnet or molten lava. You'll need to make sure that for each of the five codes, you find the shortest sequence of button presses necessary.

// The complexity of a single code (like 029A) is equal to the result of multiplying these two values:

// The length of the shortest sequence of button presses you need to type on your directional keypad in order to cause the code to be typed on the numeric keypad; for 029A, this would be 68.
// The numeric part of the code (ignoring leading zeroes); for 029A, this would be 29.
// In the above example, complexity of the five codes can be found by calculating 68 * 29, 60 * 980, 68 * 179, 64 * 456, and 64 * 379. Adding these together produces 126384.

// Find the fewest number of button presses you'll need to perform in order to cause the robot in front of the door to type each code. What is the sum of the complexities of the five codes on your list?

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

pub fn Location(comptime T: @Type(.EnumLiteral)) type {
    switch (T) {
        .Grid => {
            return struct {
                x: i64,
                y: i64,
                pub const Self = @This();
                pub fn init(indx: usize) Self {
                    const x = @as(i64, @bitCast(indx % map_width));
                    const y = @as(i64, @bitCast(@divFloor(@as(i64, @bitCast(indx)) - @as(i64, @bitCast(x)), @as(i64, @bitCast(map_width)))));
                    return .{
                        .x = x,
                        .y = y,
                    };
                }
                pub fn to_indx(loc: *const Self) usize {
                    return @as(usize, @bitCast(loc.y)) * map_width + @as(usize, @bitCast(loc.x));
                }
                pub fn eql(self: *const Self, other: Self) bool {
                    return self.x == other.x and self.y == other.y;
                }
                pub fn manhattan(self: *const Self, other: Self) u64 {
                    return @abs(self.x - other.x) + @abs(self.y - other.y);
                }
            };
        },
        .Index => {
            return struct {
                indx: u64,
                pub const Self = @This();
                pub fn init(indx: usize) Self {
                    return .{
                        .indx = indx,
                    };
                }
                pub fn to_indx(loc: *const Self) usize {
                    return loc.indx;
                }
                pub fn eql(self: *const Self, other: Self) bool {
                    return self.indx == other.indx;
                }
            };
        },
        else => unreachable,
    }
}

pub fn Graph(comptime T: @Type(.EnumLiteral)) type {
    return struct {
        nodes: std.ArrayList(NodeType),
        allocator: std.mem.Allocator,
        dist: []u64,
        prev: []std.ArrayList(PrevNode),
        paths: std.ArrayList(std.ArrayList(u8)),
        const INF = std.math.maxInt(u64);
        pub const Edge = struct {
            u: *NodeType,
            v: *NodeType,
            cost: u64,
            label: u8 = ' ',
        };
        pub const Self = @This();
        pub const NodeType = if (T == .Grid) Node(.Grid) else Node(.Index);
        pub const PrevNode = struct {
            node: NodeType = undefined,
            label: u8 = ' ',
        };
        pub fn Node(comptime S: @Type(.EnumLiteral)) type {
            return struct {
                loc: Location(S) = undefined,
                edges: *std.ArrayList(Edge),
                cost: u64 = undefined,
                pub const SelfNode = @This();
                pub fn init(loc: Location(S), allocator: std.mem.Allocator) !SelfNode {
                    const edges = try allocator.create(std.ArrayList(Edge));
                    edges.* = std.ArrayList(Edge).init(allocator);
                    return .{
                        .loc = loc,
                        .edges = edges,
                    };
                }
                pub fn add_edge(self: *SelfNode, other: *SelfNode, cost: u64) !void {
                    try self.edges.append(Edge{
                        .u = self,
                        .v = other,
                        .cost = cost,
                    });
                }
                pub fn add_edge_label(self: *SelfNode, other: *SelfNode, cost: u64, label: u8) !void {
                    try self.edges.append(Edge{
                        .u = self,
                        .v = other,
                        .cost = cost,
                        .label = label,
                    });
                }
                pub fn print(self: *SelfNode) void {
                    std.debug.print("Node:\n\tLocation: {any}\n\tEdges:", .{self.loc});
                    for (0..self.edges.items.len) |i| {
                        std.debug.print("\n\t\tLocation: {any} {d}", .{ self.edges.items[i].v.loc, self.edges.items[i].cost });
                    }
                    std.debug.print("\n", .{});
                }
                pub fn deinit(self: *SelfNode, allocator: std.mem.Allocator) void {
                    self.edges.deinit();
                    allocator.destroy(self.edges);
                }
                pub fn less_than(context: void, self: SelfNode, other: SelfNode) std.math.Order {
                    _ = context;
                    return std.math.order(self.cost, other.cost);
                }
            };
        }
        pub fn init(allocator: std.mem.Allocator, map: std.ArrayList(u8)) !Self {
            var ret = Self{
                .nodes = try std.ArrayList(NodeType).initCapacity(allocator, map_width * map_height),
                .allocator = allocator,
                .dist = try allocator.alloc(u64, map.items.len),
                .prev = try allocator.alloc(std.ArrayList(PrevNode), map.items.len),
                .paths = std.ArrayList(std.ArrayList(u8)).init(allocator),
            };
            for (0..ret.prev.len) |i| {
                ret.prev[i] = std.ArrayList(PrevNode).init(allocator);
            }
            for (0..map_height) |i| {
                for (0..map_width) |j| {
                    try ret.nodes.append(try NodeType.init(Location(T).init(i * map_width + j), allocator));
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

        pub fn deinit(self: *Self) void {
            for (0..self.nodes.items.len) |i| {
                self.nodes.items[i].deinit(self.allocator);
            }
            self.nodes.deinit();
            self.allocator.free(self.dist);
            for (0..self.prev.len) |i| {
                self.prev[i].deinit();
            }
            self.allocator.free(self.prev);
            for (0..self.paths.items.len) |i| {
                self.paths.items[i].deinit();
            }
            self.paths.deinit();
        }
        pub const DijkstraOptions = enum {
            All,
            Any,
        };
        pub fn dijkstra(self: *Self, src: *NodeType, dest: *NodeType, comptime options: DijkstraOptions) !u64 {
            for (0..self.dist.len) |i| {
                self.dist[i] = INF;
            }
            for (0..self.prev.len) |i| {
                self.prev[i].clearRetainingCapacity();
            }

            var prio_q = std.PriorityQueue(NodeType, void, NodeType.less_than).init(self.allocator, {});
            defer prio_q.deinit();
            const src_indx = src.loc.to_indx();
            self.dist[src_indx] = 0;
            try prio_q.add(NodeType{
                .loc = Location(T).init(src_indx),
                .edges = self.nodes.items[src_indx].edges,
                .cost = 0,
            });
            while (prio_q.items.len > 0) {
                const u = prio_q.remove();
                if (options == .Any) {
                    if (u.loc.eql(dest.loc)) break;
                }
                for (u.edges.items) |edge| {
                    const new_cost = u.cost + edge.cost;
                    if (new_cost < self.dist[edge.v.loc.to_indx()]) {
                        self.dist[edge.v.loc.to_indx()] = new_cost;
                        self.prev[edge.v.loc.to_indx()].clearRetainingCapacity();
                        try self.prev[edge.v.loc.to_indx()].append(PrevNode{ .node = self.nodes.items[u.loc.to_indx()], .label = edge.label });
                        try prio_q.add(NodeType{
                            .loc = Location(T).init(edge.v.loc.to_indx()),
                            .edges = self.nodes.items[edge.v.loc.to_indx()].edges,
                            .cost = new_cost,
                        });
                    } else if (new_cost == self.dist[edge.v.loc.to_indx()]) {
                        if (options == .All) {
                            try self.prev[edge.v.loc.to_indx()].append(PrevNode{ .node = self.nodes.items[u.loc.to_indx()], .label = edge.label });
                        }
                    }
                }
            }

            return self.dist[dest.loc.to_indx()];
        }

        pub fn trace_path(self: *Self, curr: u64) !void {
            for (0..self.paths.items.len) |i| {
                self.paths.items[i].clearAndFree();
            }
            self.paths.clearRetainingCapacity();
            try self.paths.append(std.ArrayList(u8).init(self.allocator));
            try self.trace_path_helper(&self.paths.items[self.paths.items.len - 1], curr);
        }

        pub fn trace_path_helper(self: *Self, path: *std.ArrayList(u8), curr: u64) !void {
            if (self.prev[curr].items.len == 0) return;
            // var node: u8 = undefined;
            // switch (curr) {
            //     0 => {
            //         node = '7';
            //     },
            //     1 => {
            //         node = '8';
            //     },
            //     2 => {
            //         node = '9';
            //     },
            //     3 => {
            //         node = '4';
            //     },
            //     4 => {
            //         node = '5';
            //     },
            //     5 => {
            //         node = '6';
            //     },
            //     6 => {
            //         node = '1';
            //     },
            //     7 => {
            //         node = '2';
            //     },
            //     8 => {
            //         node = '3';
            //     },
            //     9 => {
            //         node = '0';
            //     },
            //     10 => {
            //         node = 'A';
            //     },
            //     else => unreachable,
            // }
            // std.debug.print("Prev for node {c}:\n", .{node});
            // for (0..self.prev[curr].items.len) |j| {
            //     switch (self.prev[curr].items[j].node.loc.to_indx()) {
            //         0 => {
            //             node = '7';
            //         },
            //         1 => {
            //             node = '8';
            //         },
            //         2 => {
            //             node = '9';
            //         },
            //         3 => {
            //             node = '4';
            //         },
            //         4 => {
            //             node = '5';
            //         },
            //         5 => {
            //             node = '6';
            //         },
            //         6 => {
            //             node = '1';
            //         },
            //         7 => {
            //             node = '2';
            //         },
            //         8 => {
            //             node = '3';
            //         },
            //         9 => {
            //             node = '0';
            //         },
            //         10 => {
            //             node = 'A';
            //         },
            //         else => unreachable,
            //     }
            //     std.debug.print("node {c}: {c}\n", .{ node, self.prev[curr].items[j].label });
            // }
            const start_len = path.items.len;
            for (0..self.prev[curr].items.len) |i| {
                //try path.insert(0, self.prev[curr].items[i].label);
                if (i != 0) {
                    try self.paths.append(std.ArrayList(u8).init(self.allocator));
                    var dupe = &self.paths.items[self.paths.items.len - 1];
                    if (start_len > 0) {
                        _ = try dupe.writer().write(path.items[0..start_len]);
                    }
                    //std.debug.print("dupe path {s} adding {c}\n", .{ dupe.items, self.prev[curr].items[i].label });
                    try dupe.insert(0, self.prev[curr].items[i].label);
                    try self.trace_path_helper(&self.paths.items[self.paths.items.len - 1], self.prev[curr].items[i].node.loc.to_indx());
                } else {
                    //std.debug.print("current path {s} adding {c}\n", .{ path.items, self.prev[curr].items[i].label });
                    try path.insert(0, self.prev[curr].items[i].label);
                    try self.trace_path_helper(path, self.prev[curr].items[i].node.loc.to_indx());
                }
            }
        }

        pub fn trace_path_nodes_exist_helper(self: *const Self, visited: []bool, curr: u64, node1: u64, node2: u64, node1_exists: *bool, node2_exists: *bool) bool {
            if (node1_exists.* and node2_exists.*) return true;
            if (visited[curr]) return false;
            visited[curr] = true;
            if (curr == node1) node1_exists.* = true;
            if (curr == node2) node2_exists.* = true;
            for (0..self.prev[curr].items.len) |i| {
                const result = self.trace_path_nodes_exist_helper(visited, self.prev[curr].items[i].node.loc.to_indx(), node1, node2, node1_exists, node2_exists);
                if (result) return true;
            }
            return false;
        }
        pub fn trace_path_nodes_exist(self: *const Self, curr: u64, node1: u64, node2: u64) !bool {
            var node1_exists = false;
            var node2_exists = false;
            var visited: []bool = try self.allocator.alloc(bool, self.prev.len);
            for (0..visited.len) |i| {
                visited[i] = false;
            }
            defer self.allocator.free(visited);
            return self.trace_path_nodes_exist_helper(visited, curr, node1, node2, &node1_exists, &node2_exists);
        }

        pub fn heuristic(node: *const NodeType, goal: *const NodeType) u64 {
            return node.loc.manhattan(goal.loc);
        }

        pub fn a_star(self: *Self, src: *NodeType, dest: *NodeType) !u64 {
            for (0..self.dist.len) |i| {
                self.dist[i] = INF;
            }

            for (0..self.prev.len) |i| {
                self.prev[i].clearRetainingCapacity();
            }

            var prio_q = std.PriorityQueue(NodeType, void, NodeType.less_than).init(self.allocator, {});
            defer prio_q.deinit();
            const src_indx = src.loc.to_indx();
            self.dist[src_indx] = 0;
            try prio_q.add(NodeType{
                .loc = Location(T).init(src_indx),
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
                        try self.prev[edge.v.loc.to_indx()].append(PrevNode{ .node = self.nodes.items[u.loc.to_indx()], .label = edge.label });
                        try prio_q.add(NodeType{
                            .loc = Location(T).init(edge.v.loc.to_indx()),
                            .edges = self.nodes.items[edge.v.loc.to_indx()].edges,
                            .cost = estimated_cost,
                        });
                    } else if (new_cost == self.dist[edge.v.loc.to_indx()]) {
                        try self.prev[edge.v.loc.to_indx()].append(PrevNode{ .node = self.nodes.items[u.loc.to_indx()], .label = edge.label });
                    }
                }
            }

            return self.dist[dest.loc.to_indx()];
        }
    };
}

pub const KeypadRobot = struct {
    allocator: std.mem.Allocator,
    seven: *GraphType.NodeType,
    eight: *GraphType.NodeType,
    nine: *GraphType.NodeType,
    four: *GraphType.NodeType,
    five: *GraphType.NodeType,
    six: *GraphType.NodeType,
    one: *GraphType.NodeType,
    two: *GraphType.NodeType,
    three: *GraphType.NodeType,
    zero: *GraphType.NodeType,
    activate: *GraphType.NodeType,
    graph: GraphType,
    paths: std.ArrayList(std.ArrayList(u8)),
    pub const GraphType = Graph(.Index);
    pub fn init(allocator: std.mem.Allocator) !KeypadRobot {
        var graph = GraphType{
            .nodes = try std.ArrayList(GraphType.NodeType).initCapacity(allocator, 11),
            .allocator = allocator,
            .dist = try allocator.alloc(u64, 11),
            .prev = try allocator.alloc(std.ArrayList(GraphType.PrevNode), 11),
            .paths = std.ArrayList(std.ArrayList(u8)).init(allocator),
        };
        for (0..graph.prev.len) |i| {
            graph.prev[i] = std.ArrayList(GraphType.PrevNode).init(allocator);
        }
        for (0..11) |i| {
            try graph.nodes.append(try GraphType.NodeType.init(Location(.Index).init(i), allocator));
        }
        const ret = KeypadRobot{ .allocator = allocator, .seven = &graph.nodes.items[0], .eight = &graph.nodes.items[1], .nine = &graph.nodes.items[2], .four = &graph.nodes.items[3], .five = &graph.nodes.items[4], .six = &graph.nodes.items[5], .one = &graph.nodes.items[6], .two = &graph.nodes.items[7], .three = &graph.nodes.items[8], .zero = &graph.nodes.items[9], .activate = &graph.nodes.items[10], .graph = graph, .paths = std.ArrayList(std.ArrayList(u8)).init(allocator) };
        try ret.seven.add_edge_label(ret.eight, 1, '>');
        try ret.seven.add_edge_label(ret.four, 1, 'v');

        try ret.eight.add_edge_label(ret.seven, 1, '<');
        try ret.eight.add_edge_label(ret.nine, 1, '>');
        try ret.eight.add_edge_label(ret.five, 1, 'v');

        try ret.nine.add_edge_label(ret.eight, 1, '<');
        try ret.nine.add_edge_label(ret.six, 1, 'v');

        try ret.four.add_edge_label(ret.seven, 1, '^');
        try ret.four.add_edge_label(ret.five, 1, '>');
        try ret.four.add_edge_label(ret.one, 1, 'v');

        try ret.five.add_edge_label(ret.eight, 1, '^');
        try ret.five.add_edge_label(ret.six, 1, '>');
        try ret.five.add_edge_label(ret.two, 1, 'v');
        try ret.five.add_edge_label(ret.four, 1, '<');

        try ret.six.add_edge_label(ret.nine, 1, '^');
        try ret.six.add_edge_label(ret.five, 1, '<');
        try ret.six.add_edge_label(ret.three, 1, 'v');

        try ret.one.add_edge_label(ret.four, 1, '^');
        try ret.one.add_edge_label(ret.two, 1, '>');

        try ret.two.add_edge_label(ret.one, 1, '<');
        try ret.two.add_edge_label(ret.five, 1, '^');
        try ret.two.add_edge_label(ret.three, 1, '>');

        try ret.three.add_edge_label(ret.six, 1, '^');
        try ret.three.add_edge_label(ret.two, 1, '<');
        try ret.three.add_edge_label(ret.activate, 1, 'v');

        try ret.zero.add_edge_label(ret.two, 1, '^');
        try ret.zero.add_edge_label(ret.activate, 1, '>');

        try ret.activate.add_edge_label(ret.three, 1, '^');
        try ret.activate.add_edge_label(ret.zero, 1, '<');

        return ret;
    }
    pub fn deinit(self: *KeypadRobot) void {
        self.graph.deinit();
        for (0..self.paths.items.len) |i| {
            self.paths.items[i].deinit();
        }
        self.paths.deinit();
    }

    pub fn run(self: *KeypadRobot, keypad_input: std.ArrayList(u8)) !void {
        var start_node = self.activate;
        var end_node: *KeypadRobot.GraphType.NodeType = undefined;
        for (0..self.paths.items.len) |i| {
            self.paths.items[i].clearAndFree();
        }
        self.paths.clearAndFree();
        for (0..keypad_input.items.len) |i| {
            switch (keypad_input.items[i]) {
                '0' => {
                    end_node = self.zero;
                },
                '1' => {
                    end_node = self.one;
                },
                '2' => {
                    end_node = self.two;
                },
                '3' => {
                    end_node = self.three;
                },
                '4' => {
                    end_node = self.four;
                },
                '5' => {
                    end_node = self.five;
                },
                '6' => {
                    end_node = self.six;
                },
                '7' => {
                    end_node = self.seven;
                },
                '8' => {
                    end_node = self.eight;
                },
                '9' => {
                    end_node = self.nine;
                },
                'A' => {
                    end_node = self.activate;
                },
                else => unreachable,
            }
            _ = try self.graph.dijkstra(start_node, end_node, .All);
            try self.graph.trace_path(end_node.loc.to_indx());
            if (self.paths.items.len == 0) {
                for (0..self.graph.paths.items.len) |j| {
                    //std.debug.print("Path: {d}: {s}\n", .{ j, self.graph.paths.items[j].items });
                    try self.paths.append(std.ArrayList(u8).init(self.allocator));
                    _ = try self.paths.items[self.paths.items.len - 1].writer().write(self.graph.paths.items[j].items);
                    try self.paths.items[self.paths.items.len - 1].append('A');
                }
                // for (0..self.paths.items.len) |j| {
                //     std.debug.print("So far: {s}\n", .{self.paths.items[j].items});
                // }
            } else {
                const NUM_PATH_START = self.paths.items.len;
                const num_to_clone = self.graph.paths.items.len - 1;
                var clone_count: usize = 0;
                while (clone_count < num_to_clone) : (clone_count += 1) {
                    for (0..NUM_PATH_START) |j| {
                        try self.paths.append(try self.paths.items[j].clone());
                    }
                }

                for (0..self.graph.paths.items.len) |k| {
                    //std.debug.print("Path: {d}: {s}\n", .{ k, self.graph.paths.items[k].items });
                    for (0..NUM_PATH_START) |j| {
                        _ = try self.paths.items[j + (k * NUM_PATH_START)].writer().write(self.graph.paths.items[k].items);
                        try self.paths.items[j + (k * NUM_PATH_START)].append('A');
                    }
                }

                // for (0..self.paths.items.len) |j| {
                //     std.debug.print("So far: {s}\n", .{self.paths.items[j].items});
                // }
            }
            start_node = end_node;
        }
        for (0..self.paths.items.len) |i| {
            std.debug.print("{s}\n", .{self.paths.items[i].items});
        }
    }
};

pub const DirectionalRobot = struct {
    allocator: std.mem.Allocator,
    up: *GraphType.NodeType,
    activate: *GraphType.NodeType,
    left: *GraphType.NodeType,
    down: *GraphType.NodeType,
    right: *GraphType.NodeType,
    graph: GraphType,
    path: std.ArrayList(u8),
    path_cache: std.StringHashMap(std.ArrayList(u8)),
    pub const GraphType = Graph(.Index);
    pub fn init(allocator: std.mem.Allocator) !DirectionalRobot {
        var graph = GraphType{
            .nodes = try std.ArrayList(GraphType.NodeType).initCapacity(allocator, 5),
            .allocator = allocator,
            .dist = try allocator.alloc(u64, 5),
            .prev = try allocator.alloc(std.ArrayList(GraphType.PrevNode), 5),
            .paths = std.ArrayList(std.ArrayList(u8)).init(allocator),
        };
        for (0..graph.prev.len) |i| {
            graph.prev[i] = std.ArrayList(GraphType.PrevNode).init(allocator);
        }
        for (0..11) |i| {
            try graph.nodes.append(try GraphType.NodeType.init(Location(.Index).init(i), allocator));
        }
        const ret = DirectionalRobot{
            .allocator = allocator,
            .up = &graph.nodes.items[0],
            .activate = &graph.nodes.items[1],
            .left = &graph.nodes.items[2],
            .down = &graph.nodes.items[3],
            .right = &graph.nodes.items[4],
            .graph = graph,
            .path = std.ArrayList(u8).init(allocator),
            .path_cache = std.StringHashMap(std.ArrayList(u8)).init(allocator),
        };
        try ret.up.add_edge_label(ret.activate, 1, '>');
        try ret.up.add_edge_label(ret.down, 1, 'v');

        try ret.activate.add_edge_label(ret.up, 1, '<');
        try ret.activate.add_edge_label(ret.right, 1, 'v');

        try ret.left.add_edge_label(ret.down, 1, '>');

        try ret.down.add_edge_label(ret.up, 1, '^');
        try ret.down.add_edge_label(ret.left, 1, '<');
        try ret.down.add_edge_label(ret.right, 1, '>');

        try ret.right.add_edge_label(ret.activate, 1, '^');
        try ret.right.add_edge_label(ret.down, 1, '<');

        return ret;
    }
    pub fn deinit(self: *DirectionalRobot) void {
        self.graph.deinit();
        self.path.deinit();
        var it = self.path_cache.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        self.path_cache.deinit();
    }

    pub fn cache_dir_paths(self: *DirectionalRobot) !void {
        _ = try self.graph.dijkstra(self.activate, self.up, .All);
        try self.graph.trace_path(self.up.loc.to_indx());
        var entry = try self.path_cache.getOrPut("^");
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(self.graph.paths.items[0].items);
        try entry.value_ptr.append('A');
        std.debug.print("^ {s}\n", .{entry.value_ptr.items});

        _ = try self.graph.dijkstra(self.activate, self.right, .All);
        try self.graph.trace_path(self.right.loc.to_indx());
        entry = try self.path_cache.getOrPut(">");
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(self.graph.paths.items[0].items);
        try entry.value_ptr.append('A');
        std.debug.print("> {s}\n", .{entry.value_ptr.items});

        _ = try self.graph.dijkstra(self.activate, self.down, .All);
        try self.graph.trace_path(self.down.loc.to_indx());
        entry = try self.path_cache.getOrPut("v");
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(self.graph.paths.items[0].items);
        try entry.value_ptr.append('A');
        std.debug.print("v {s}\n", .{entry.value_ptr.items});

        _ = try self.graph.dijkstra(self.activate, self.left, .All);
        try self.graph.trace_path(self.left.loc.to_indx());
        entry = try self.path_cache.getOrPut("<");
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(self.graph.paths.items[0].items);
        try entry.value_ptr.append('A');
        std.debug.print("< {s}\n", .{entry.value_ptr.items});

        entry = try self.path_cache.getOrPut("A");
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        try entry.value_ptr.append('A');
        std.debug.print("A {s}\n", .{entry.value_ptr.items});
    }

    pub fn run(self: *DirectionalRobot, keypad_input: std.ArrayList(u8)) !u64 {
        self.path.clearRetainingCapacity();
        var curr_start: u64 = 0;
        var curr_end: u64 = std.mem.indexOfScalar(u8, keypad_input.items, 'A') orelse keypad_input.items.len;
        //var sub_str_start = curr_start;
        //var sub_str_end = curr_end;
        while (curr_start < keypad_input.items.len) {
            std.debug.print("Substr {s}\n", .{keypad_input.items[curr_start..curr_end]});
            if (!self.path_cache.contains(keypad_input.items[curr_start..curr_end])) {
                const curr_path_end: usize = self.path.items.len;
                const substr_start = curr_start;
                while (curr_start < curr_end) {
                    std.debug.print("key {s}\n", .{keypad_input.items[curr_start .. curr_start + 1]});
                    _ = try self.path.writer().write(self.path_cache.get(keypad_input.items[curr_start .. curr_start + 1]).?.items);
                    curr_start += 1;
                }
                _ = try self.path.writer().write(self.path_cache.get("A").?.items);
                var entry = try self.path_cache.getOrPut(keypad_input.items[substr_start..curr_end]);
                entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
                _ = try entry.value_ptr.writer().write(self.path.items[curr_path_end .. self.path.items.len - 1]);
            } else {
                _ = try self.path.writer().write(self.path_cache.get(keypad_input.items[curr_start..curr_end]).?.items);
            }
            std.debug.print("Path partial: {s}\n", .{self.path.items});
            curr_start = curr_end + 1;
            curr_end = std.mem.indexOfScalarPos(u8, keypad_input.items, curr_start, 'A') orelse keypad_input.items.len;
        }
        // for (0..keypad_input.items.len) |i| {
        //     switch (keypad_input.items[i]) {
        //         '<' => {
        //             end_node = self.left;
        //         },
        //         '^' => {
        //             end_node = self.up;
        //         },
        //         '>' => {
        //             end_node = self.right;
        //         },
        //         'v' => {
        //             end_node = self.down;
        //         },
        //         'A' => {
        //             end_node = self.activate;
        //         },
        //         else => unreachable,
        //     }
        //     total_cost += try self.graph.dijkstra(start_node, end_node, .All);
        //     try self.graph.trace_path(end_node.loc.to_indx());
        //     if (self.paths.items.len == 0) {
        //         for (0..self.graph.paths.items.len) |j| {
        //             //std.debug.print("Path: {d}: {s}\n", .{ j, self.graph.paths.items[j].items });
        //             try self.paths.append(Path{
        //                 .path = std.ArrayList(u8).init(self.allocator),
        //                 .cost = total_cost,
        //             });
        //             _ = try self.paths.items[self.paths.items.len - 1].path.writer().write(self.graph.paths.items[j].items);
        //             try self.paths.items[self.paths.items.len - 1].path.append('A');
        //         }
        //         // for (0..self.paths.items.len) |j| {
        //         //     std.debug.print("So far: {s}\n", .{self.paths.items[j].items});
        //         // }
        //     } else {
        //         const NUM_PATH_START = self.paths.items.len;
        //         const num_to_clone = self.graph.paths.items.len - 1;
        //         var clone_count: usize = 0;
        //         while (clone_count < num_to_clone) : (clone_count += 1) {
        //             for (0..NUM_PATH_START) |j| {
        //                 try self.paths.append(Path{
        //                     .path = try self.paths.items[j].path.clone(),
        //                     .cost = 0,
        //                 });
        //             }
        //         }

        //         for (0..self.graph.paths.items.len) |k| {
        //             //std.debug.print("Path: {d}: {s}\n", .{ k, self.graph.paths.items[k].items });
        //             for (0..NUM_PATH_START) |j| {
        //                 _ = try self.paths.items[j + (k * NUM_PATH_START)].path.writer().write(self.graph.paths.items[k].items);
        //                 try self.paths.items[j + (k * NUM_PATH_START)].path.append('A');
        //                 self.paths.items[j + (k * NUM_PATH_START)].cost = total_cost;
        //             }
        //         }
        //     }
        //     start_node = end_node;
        // }
        // for (0..self.paths.items.len) |j| {
        //     std.debug.print("So far: {d} {d}\n", .{ self.paths.items[j].cost, j });
        // }
        std.debug.print("Path: {s} {d}\n", .{ self.path.items, self.path.items.len });
        return self.path.items.len;
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

pub fn run_robots(directional_robots: std.ArrayList(DirectionalRobot), curr_bot: usize, MAX_BOTS: usize) !void {
    if (curr_bot < MAX_BOTS) {
        for (0..directional_robots.items[curr_bot - 1].paths.items.len) |j| {
            _ = try directional_robots.items[curr_bot].run(directional_robots.items[curr_bot - 1].paths.items[j].path);
        }
        for (0..directional_robots.items[curr_bot].paths.items.len) |k| {
            std.debug.print("{s} {d}\n", .{ directional_robots.items[curr_bot].paths.items[k].path.items, directional_robots.items[curr_bot].paths.items[k].path.items.len });
        }
        try run_robots(directional_robots, curr_bot + 1, MAX_BOTS);
    }
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var keypad_input = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer keypad_input.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        try keypad_input.append(std.ArrayList(u8).init(allocator));
        _ = try keypad_input.items[keypad_input.items.len - 1].writer().write(line);
    }
    //const MAX_BOTS = 2;
    var keypad_robot = try KeypadRobot.init(allocator);
    defer keypad_robot.deinit();

    var directional_robot = try DirectionalRobot.init(allocator);
    try directional_robot.cache_dir_paths();
    defer directional_robot.deinit();
    try keypad_robot.run(keypad_input.items[0]);
    _ = try directional_robot.run(keypad_robot.paths.items[0]);
    // var directional_robots = std.ArrayList(DirectionalRobot).init(allocator);
    // defer directional_robots.deinit();
    // for (0..MAX_BOTS) |_| {
    //     try directional_robots.append(try DirectionalRobot.init(allocator));
    // }

    // for (0..keypad_input.items.len) |i| {
    //     if (i > 0) break;
    //     std.debug.print("Key Input: {s}\n", .{keypad_input.items[i].items});
    //     try keypad_robot.run(keypad_input.items[i]);
    //     for (0..keypad_robot.paths.items.len) |j| {
    //         if (j > 0) break;
    //         _ = try directional_robots.items[0].run(keypad_robot.paths.items[j]);
    //     }
    //     for (0..directional_robots.items[0].paths.items.len) |k| {
    //         std.debug.print("{s} {d}\n", .{ directional_robots.items[0].paths.items[k].path.items, directional_robots.items[0].paths.items[k].path.items.len });
    //     }
    //     //try run_robots(directional_robots, 1, MAX_BOTS);
    // }

    // for (0..directional_robots.items.len) |i| {
    //     directional_robots.items[i].deinit();
    // }

    for (0..keypad_input.items.len) |i| {
        keypad_input.items[i].deinit();
    }
    return 0;
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = file_name;
    _ = allocator;
    return 0;
}

test "day21" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Cheats possible {d} in {d}ms\n", .{ try part1("../inputs/day21/test.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Cheats possible {d} in {d}ms\n", .{ try part2("../inputs/day21/test.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
