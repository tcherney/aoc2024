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
var num_buf: [4096]u8 = undefined;
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
    path: std.ArrayList(u8),
    keymap: std.AutoHashMap(KeypadKey, std.ArrayList(u8)),
    pub const KeypadKey = struct {
        a: u8,
        b: u8,
    };
    pub fn init(allocator: std.mem.Allocator) !KeypadRobot {
        var ret = KeypadRobot{ .allocator = allocator, .path = std.ArrayList(u8).init(allocator), .keymap = std.AutoHashMap(KeypadKey, std.ArrayList(u8)).init(allocator) };
        try ret.cache_key_paths();
        return ret;
    }
    pub fn deinit(self: *KeypadRobot) void {
        var it = self.keymap.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        self.keymap.deinit();
        self.path.deinit();
    }

    pub fn cache_key_paths(self: *KeypadRobot) !void {
        //0 -> all
        var entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^^<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '0',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //1 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^>>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '1',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //2 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '2',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //3 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '3',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //4 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '4',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //5 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '5',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vv>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //6 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '6',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //7 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">vvvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vv>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vv>>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '7',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>vvvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //8 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vv>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '8',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvv>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //9 -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvv<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = '9',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vvvA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //A -> all
        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '0',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '1',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '2',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '3',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '4',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '5',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '6',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '7',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^^<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '8',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = '9',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^^^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(KeypadKey{
            .a = 'A',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });
    }

    pub fn run(self: *KeypadRobot, keypad_input: std.ArrayList(u8)) !void {
        self.path.clearRetainingCapacity();
        var curr_key: u8 = 'A';
        for (0..keypad_input.items.len) |i| {
            const next_key = keypad_input.items[i];
            _ = try self.path.writer().write(self.keymap.get(.{ .a = curr_key, .b = next_key }).?.items);
            curr_key = next_key;
        }
    }
};

pub const DirectionalRobot = struct {
    allocator: std.mem.Allocator,
    keymap: std.AutoHashMap(DirKey, std.ArrayList(u8)),
    score_cache: std.BufMap,
    score_key: std.ArrayList(u8),
    pub const DirKey = struct {
        a: u8,
        b: u8,
    };
    pub const GraphType = Graph(.Index);
    pub fn init(allocator: std.mem.Allocator) !DirectionalRobot {
        var ret = DirectionalRobot{
            .allocator = allocator,
            .keymap = std.AutoHashMap(DirKey, std.ArrayList(u8)).init(allocator),
            .score_cache = std.BufMap.init(allocator),
            .score_key = std.ArrayList(u8).init(allocator),
        };
        try ret.cache_dir_paths();

        return ret;
    }
    pub fn deinit(self: *DirectionalRobot) void {
        var it = self.keymap.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        self.keymap.deinit();
        self.score_key.deinit();
        self.score_cache.deinit();
    }

    pub fn cache_dir_paths(self: *DirectionalRobot) !void {
        //^ -> all
        var entry = try self.keymap.getOrPut(DirKey{
            .a = '^',
            .b = '^',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '^',
            .b = 'v',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '^',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '^',
            .b = '<',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '^',
            .b = '>',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        //< -> all
        entry = try self.keymap.getOrPut(DirKey{
            .a = '<',
            .b = '^',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '<',
            .b = 'v',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '<',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '<',
            .b = '<',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '<',
            .b = '>',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });
        //v -> all
        entry = try self.keymap.getOrPut(DirKey{
            .a = 'v',
            .b = '^',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'v',
            .b = 'v',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'v',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^>A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'v',
            .b = '<',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'v',
            .b = '>',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write(">A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });
        //> -> all
        entry = try self.keymap.getOrPut(DirKey{
            .a = '>',
            .b = '^',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '>',
            .b = 'v',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '>',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("^A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '>',
            .b = '<',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = '>',
            .b = '>',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });
        //A -> all
        entry = try self.keymap.getOrPut(DirKey{
            .a = 'A',
            .b = '^',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'A',
            .b = 'v',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("<vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'A',
            .b = 'A',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'A',
            .b = '<',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("v<<A");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });

        entry = try self.keymap.getOrPut(DirKey{
            .a = 'A',
            .b = '>',
        });
        entry.value_ptr.* = std.ArrayList(u8).init(self.allocator);
        _ = try entry.value_ptr.writer().write("vA");
        //std.debug.print("({c},{c}) {s}\n", .{ entry.key_ptr.a, entry.key_ptr.b, entry.value_ptr.items });
    }

    pub fn score(self: *DirectionalRobot, a: u8, b: u8, level: u128) !u128 {
        //std.debug.print("a: {c}, b: {c}, level {d}\n", .{ a, b, level });
        const next = self.keymap.get(.{ .a = a, .b = b }).?;
        //std.debug.print("{s}", .{next.items});
        if (level == 1) {
            return next.items.len;
        }
        self.score_key.clearRetainingCapacity();
        _ = try self.score_key.writer().print("{s}{d}", .{ next.items, level });
        if (self.score_cache.get(self.score_key.items) != null) {
            //std.debug.print("Found value at {s} with value {s} as num {d}\n", .{ self.score_key.items, self.score_cache.get(self.score_key.items).?, try std.fmt.parseInt(u128, self.score_cache.get(self.score_key.items).?, 10) });
            return try std.fmt.parseInt(u128, self.score_cache.get(self.score_key.items).?, 10);
        }
        var total: u128 = 0;
        var curr_key: u8 = 'A';
        for (0..next.items.len) |i| {
            const next_key = next.items[i];
            total += try self.score(curr_key, next_key, level - 1);
            curr_key = next_key;
        }
        self.score_key.clearRetainingCapacity();
        _ = try self.score_key.writer().print("{s}{d}", .{ next.items, level });
        //std.debug.print("Second Level Total: {d} Storing {s} in cache at {s}\n", .{ total, try std.fmt.bufPrint(&num_buf, "{d}", .{total}), self.score_key.items });
        try self.score_cache.put(self.score_key.items, try std.fmt.bufPrint(&num_buf, "{d}", .{total}));
        return total;
    }

    pub fn run(self: *DirectionalRobot, keypad_input: std.ArrayList(u8), keypad_cost: u128, levels: u128) !u128 {
        var path = std.ArrayList(u8).init(self.allocator);
        defer path.deinit();

        try path.append('A');
        var curr_key: u8 = 'A';
        for (0..keypad_input.items.len) |i| {
            const next_key = keypad_input.items[i];
            _ = try path.writer().write(self.keymap.get(.{ .a = curr_key, .b = next_key }).?.items);
            curr_key = next_key;
        }
        //std.debug.print("Second level: ", .{});
        var total: u128 = 0;
        for (0..path.items.len - 1) |i| {
            total += try self.score(path.items[i], path.items[i + 1], levels);
        }
        //std.debug.print("\n", .{});
        //std.debug.print("Input: {s}, First level: {s}\n", .{ keypad_input.items, path.items });
        //std.debug.print("Total: {d} Keypad: {d} = {d}\n", .{ total, keypad_cost, total * keypad_cost });
        return total * keypad_cost;
    }
};

pub fn calc_keypad_cost(keypad_input: std.ArrayList(u8)) !u128 {
    return try std.fmt.parseInt(u128, keypad_input.items[0 .. keypad_input.items.len - 1], 10);
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u128 {
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
    defer directional_robot.deinit();
    var total: u128 = 0;
    for (0..keypad_input.items.len) |i| {
        try keypad_robot.run(keypad_input.items[i]);
        // for all viable paths
        total += try directional_robot.run(keypad_robot.path, try calc_keypad_cost(keypad_input.items[i]), 1);
    }

    for (0..keypad_input.items.len) |i| {
        keypad_input.items[i].deinit();
    }
    return total;
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u128 {
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
    defer directional_robot.deinit();
    var total: u128 = 0;
    for (0..keypad_input.items.len) |i| {
        try keypad_robot.run(keypad_input.items[i]);
        // for all viable paths
        total += try directional_robot.run(keypad_robot.path, try calc_keypad_cost(keypad_input.items[i]), 24);
    }

    for (0..keypad_input.items.len) |i| {
        keypad_input.items[i].deinit();
    }
    return total;
}

test "day21" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Sum of complexities {d} in {d}ms\n", .{ try part1("../inputs/day21/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Sum of complexities {d} in {d}ms\n", .{ try part2("../inputs/day21/test.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
