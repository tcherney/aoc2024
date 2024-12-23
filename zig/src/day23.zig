const std = @import("std");
// https://adventofcode.com/2024/day/23
// --- Day 23: LAN Party ---
// As The Historians wander around a secure area at Easter Bunny HQ, you come across posters for a LAN party scheduled for today! Maybe you can find it; you connect to a nearby datalink port and download a map of the local network (your puzzle input).

// The network map provides a list of every connection between two computers. For example:

// kh-tc
// qp-kh
// de-cg
// ka-co
// yn-aq
// qp-ub
// cg-tb
// vc-aq
// tb-ka
// wh-tc
// yn-cg
// kh-ub
// ta-co
// de-co
// tc-td
// tb-wq
// wh-td
// ta-ka
// td-qp
// aq-cg
// wq-ub
// ub-vc
// de-ta
// wq-aq
// wq-vc
// wh-yn
// ka-de
// kh-ta
// co-tc
// wh-qp
// tb-vc
// td-yn
// Each line of text in the network map represents a single connection; the line kh-tc represents a connection between the computer named kh and the computer named tc. Connections aren't directional; tc-kh would mean exactly the same thing.

// LAN parties typically involve multiplayer games, so maybe you can locate it by finding groups of connected computers. Start by looking for sets of three computers where each computer in the set is connected to the other two computers.

// In this example, there are 12 such sets of three inter-connected computers:

// aq,cg,yn
// aq,vc,wq
// co,de,ka
// co,de,ta
// co,ka,ta
// de,ka,ta
// kh,qp,ub
// qp,td,wh
// tb,vc,wq
// tc,td,wh
// td,wh,yn
// ub,vc,wq
// If the Chief Historian is here, and he's at the LAN party, it would be best to know that right away. You're pretty sure his computer's name starts with t, so consider only sets of three computers where at least one computer's name starts with t. That narrows the list down to 7 sets of three inter-connected computers:

// co,de,ta
// co,ka,ta
// de,ka,ta
// qp,td,wh
// tb,vc,wq
// tc,td,wh
// td,wh,yn
// Find all the sets of three inter-connected computers. How many contain at least one computer with a name that starts with t?

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

pub const Graph = struct {
    nodes: std.AutoHashMap(ID, *Node),
    allocator: std.mem.Allocator,
    const INF = std.math.maxInt(u64);
    pub const Edge = struct {
        u: *Node,
        v: *Node,
        cost: u64,
        label: u8 = ' ',
    };
    pub const Node = struct {
        id: ID,
        edges: *std.ArrayList(Edge),
        cost: u64 = undefined,
        pub fn init(id: ID, allocator: std.mem.Allocator) !Node {
            const edges = try allocator.create(std.ArrayList(Edge));
            edges.* = std.ArrayList(Edge).init(allocator);
            return .{
                .id = id,
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
        pub fn connected(self: *Node, other: *Node) bool {
            for (0..self.edges.items.len) |i| {
                if (self.edges.items[i].v.id.id == other.id.id) {
                    return true;
                }
            }
            return false;
        }
        pub fn add_edge_label(self: *Node, other: *Node, cost: u64, label: u8) !void {
            try self.edges.append(Edge{
                .u = self,
                .v = other,
                .cost = cost,
                .label = label,
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
    pub fn init(allocator: std.mem.Allocator) Graph {
        return Graph{
            .nodes = std.AutoHashMap(ID, *Node).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Graph) void {
        var it = self.nodes.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.*.deinit(self.allocator);
            self.allocator.destroy(entry.value_ptr.*);
        }
        self.nodes.deinit();
    }

    // pub const DijkstraOptions = enum {
    //     All,
    //     Any,
    // };
    // pub fn dijkstra(self: *Graph, src: *Node, dest: *Node, comptime options: DijkstraOptions) !u64 {
    //     for (0..self.dist.len) |i| {
    //         self.dist[i] = INF;
    //     }
    //     for (0..self.prev.len) |i| {
    //         self.prev[i].clearRetainingCapacity();
    //     }

    //     var prio_q = std.PriorityQueue(Node, void, Node.less_than).init(self.allocator, {});
    //     defer prio_q.deinit();
    //     const src_indx = src.loc.to_indx();
    //     self.dist[src_indx] = 0;
    //     try prio_q.add(Node{
    //         .loc = Location(T).init(src_indx),
    //         .edges = self.nodes.items[src_indx].edges,
    //         .cost = 0,
    //     });
    //     while (prio_q.items.len > 0) {
    //         const u = prio_q.remove();
    //         if (options == .Any) {
    //             if (u.loc.eql(dest.loc)) break;
    //         }
    //         for (u.edges.items) |edge| {
    //             const new_cost = u.cost + edge.cost;
    //             if (new_cost < self.dist[edge.v.loc.to_indx()]) {
    //                 self.dist[edge.v.loc.to_indx()] = new_cost;
    //                 self.prev[edge.v.loc.to_indx()].clearRetainingCapacity();
    //                 try self.prev[edge.v.loc.to_indx()].append(PrevNode{ .node = self.nodes.items[u.loc.to_indx()], .label = edge.label });
    //                 try prio_q.add(NodeType{
    //                     .loc = Location(T).init(edge.v.loc.to_indx()),
    //                     .edges = self.nodes.items[edge.v.loc.to_indx()].edges,
    //                     .cost = new_cost,
    //                 });
    //             } else if (new_cost == self.dist[edge.v.loc.to_indx()]) {
    //                 if (options == .All) {
    //                     try self.prev[edge.v.loc.to_indx()].append(PrevNode{ .node = self.nodes.items[u.loc.to_indx()], .label = edge.label });
    //                 }
    //             }
    //         }
    //     }
    //     return self.dist[dest.loc.to_indx()];
    // }

    pub fn trace_path(self: *Graph, curr: u64) !void {
        for (0..self.paths.items.len) |i| {
            self.paths.items[i].clearAndFree();
        }
        self.paths.clearRetainingCapacity();
        try self.paths.append(std.ArrayList(u8).init(self.allocator));
        try self.trace_path_helper(&self.paths.items[self.paths.items.len - 1], curr);
    }

    pub fn trace_path_helper(self: *Graph, path: *std.ArrayList(u8), curr: u64) !void {
        if (self.prev[curr].items.len == 0) return;
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
};

pub const ID = struct {
    id: u64,
    has_t: bool,
};

pub const ThreeSet = struct {
    c1: ID,
    c2: ID,
    c3: ID,
    pub fn init(c1: ID, c2: ID, c3: ID) !ThreeSet {
        return ThreeSet{
            .c1 = c1,
            .c2 = c2,
            .c3 = c3,
        };
    }
    pub fn eql(self: *ThreeSet, other: ThreeSet) bool {
        const contains_c1 = self.c1.id == other.c1.id or self.c1.id == other.c2.id or self.c1.id == other.c3.id;
        const contains_c2 = self.c2.id == other.c1.id or self.c2.id == other.c2.id or self.c2.id == other.c3.id;
        const contains_c3 = self.c3.id == other.c1.id or self.c3.id == other.c2.id or self.c3.id == other.c3.id;
        return contains_c1 and contains_c2 and contains_c3;
    }
    pub fn has_t(self: *ThreeSet) bool {
        return self.c1.has_t or self.c2.has_t or self.c3.has_t;
    }
};

pub fn add_set(three_sets: *std.ArrayList(ThreeSet), new_set: ThreeSet) !void {
    var exists = false;
    for (0..three_sets.items.len) |i| {
        if (three_sets.items[i].eql(new_set)) {
            exists = true;
        }
        if (exists) return;
    }
    try three_sets.append(new_set);
}
pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var graph = Graph.init(allocator);
    defer graph.deinit();
    var key_map = std.StringHashMap(ID).init(allocator);
    defer key_map.deinit();
    var keys = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer keys.deinit();
    var curr_id: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var it = std.mem.splitScalar(u8, line, '-');
        const name1_str = it.next().?;
        const name2_str = it.next().?;
        var name1: *std.ArrayList(u8) = undefined;
        var name2: *std.ArrayList(u8) = undefined;
        var id1: ID = undefined;
        var id2: ID = undefined;
        if (key_map.contains(name1_str)) {
            id1 = key_map.get(name1_str).?;
        } else {
            try keys.append((std.ArrayList(u8).init(allocator)));
            name1 = &keys.items[keys.items.len - 1];
            _ = try name1.writer().write(name1_str);
            var has_t = false;
            if (std.mem.indexOfScalar(u8, name1.items, 't')) |indx| {
                has_t = indx == 0;
            }
            id1 = .{
                .id = curr_id,
                .has_t = has_t,
            };
            try key_map.put(name1.items, id1);
            curr_id += 1;
        }
        if (key_map.contains(name2_str)) {
            id2 = key_map.get(name2_str).?;
        } else {
            try keys.append((std.ArrayList(u8).init(allocator)));
            name2 = &keys.items[keys.items.len - 1];
            _ = try name2.writer().write(name2_str);
            var has_t = false;
            if (std.mem.indexOfScalar(u8, name2.items, 't')) |indx| {
                has_t = indx == 0;
            }
            id2 = .{
                .id = curr_id,
                .has_t = has_t,
            };
            try key_map.put(name2.items, id2);
            curr_id += 1;
        }
        //std.debug.print("node1 {s}, node2 {s}\n", .{ name1, name2 });
        var node1: *Graph.Node = undefined;
        var node2: *Graph.Node = undefined;
        if (!graph.nodes.contains(id1)) {
            node1 = try allocator.create(Graph.Node);
            node1.* = try Graph.Node.init(id1, allocator);
            try graph.nodes.put(node1.id, node1);
        } else {
            node1 = graph.nodes.get(id1).?;
        }
        if (!graph.nodes.contains(id2)) {
            node2 = try allocator.create(Graph.Node);
            node2.* = try Graph.Node.init(id2, allocator);
            try graph.nodes.put(node2.id, node2);
        } else {
            node2 = graph.nodes.get(id2).?;
        }

        try node1.add_edge(node2, 1);
        try node2.add_edge(node1, 1);
    }
    var three_sets = std.ArrayList(ThreeSet).init(allocator);
    defer three_sets.deinit();
    var it = graph.nodes.iterator();
    while (it.next()) |entry| {
        const node = entry.value_ptr.*;
        for (0..node.edges.items.len) |i| {
            for (i + 1..node.edges.items.len) |j| {
                if (node.edges.items[i].v.connected(node.edges.items[j].v)) {
                    const new_set = try ThreeSet.init(
                        node.id,
                        node.edges.items[i].v.id,
                        node.edges.items[j].v.id,
                    );
                    try add_set(&three_sets, new_set);
                }
            }
        }
    }
    var count_t: u64 = 0;
    for (0..three_sets.items.len) |i| {
        if (three_sets.items[i].has_t()) {
            std.debug.print("{s}-{s}-{s}\n", .{ keys.items[three_sets.items[i].c1.id].items, keys.items[three_sets.items[i].c2.id].items, keys.items[three_sets.items[i].c3.id].items });
            count_t += 1;
        }
    }
    for (0..keys.items.len) |i| {
        keys.items[i].deinit();
    }
    return count_t;
}

// --- Part Two ---
// There are still way too many results to go through them all. You'll have to find the LAN party another way and go there yourself.

// Since it doesn't seem like any employees are around, you figure they must all be at the LAN party. If that's true, the LAN party will be the largest set of computers that are all connected to each other. That is, for each computer at the LAN party, that computer will have a connection to every other computer at the LAN party.

// In the above example, the largest set of computers that are all connected to each other is made up of co, de, ka, and ta. Each computer in this set has a connection to every other computer in the set:

// ka-co
// ta-co
// de-co
// ta-ka
// de-ta
// ka-de
// The LAN party posters say that the password to get into the LAN party is the name of every computer at the LAN party, sorted alphabetically, then joined together with commas. (The people running the LAN party are clearly a bunch of nerds.) In this example, the password would be co,de,ka,ta.

// What is the password to get into the LAN party?

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !i64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var graph = Graph.init(allocator);
    defer graph.deinit();
    var key_map = std.StringHashMap(ID).init(allocator);
    defer key_map.deinit();
    var keys = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer keys.deinit();
    var curr_id: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var it = std.mem.splitScalar(u8, line, '-');
        const name1_str = it.next().?;
        const name2_str = it.next().?;
        var name1: *std.ArrayList(u8) = undefined;
        var name2: *std.ArrayList(u8) = undefined;
        var id1: ID = undefined;
        var id2: ID = undefined;
        if (key_map.contains(name1_str)) {
            id1 = key_map.get(name1_str).?;
        } else {
            try keys.append((std.ArrayList(u8).init(allocator)));
            name1 = &keys.items[keys.items.len - 1];
            _ = try name1.writer().write(name1_str);
            var has_t = false;
            if (std.mem.indexOfScalar(u8, name1.items, 't')) |indx| {
                has_t = indx == 0;
            }
            id1 = .{
                .id = curr_id,
                .has_t = has_t,
            };
            try key_map.put(name1.items, id1);
            curr_id += 1;
        }
        if (key_map.contains(name2_str)) {
            id2 = key_map.get(name2_str).?;
        } else {
            try keys.append((std.ArrayList(u8).init(allocator)));
            name2 = &keys.items[keys.items.len - 1];
            _ = try name2.writer().write(name2_str);
            var has_t = false;
            if (std.mem.indexOfScalar(u8, name2.items, 't')) |indx| {
                has_t = indx == 0;
            }
            id2 = .{
                .id = curr_id,
                .has_t = has_t,
            };
            try key_map.put(name2.items, id2);
            curr_id += 1;
        }
        //std.debug.print("node1 {s}, node2 {s}\n", .{ name1, name2 });
        var node1: *Graph.Node = undefined;
        var node2: *Graph.Node = undefined;
        if (!graph.nodes.contains(id1)) {
            node1 = try allocator.create(Graph.Node);
            node1.* = try Graph.Node.init(id1, allocator);
            try graph.nodes.put(node1.id, node1);
        } else {
            node1 = graph.nodes.get(id1).?;
        }
        if (!graph.nodes.contains(id2)) {
            node2 = try allocator.create(Graph.Node);
            node2.* = try Graph.Node.init(id2, allocator);
            try graph.nodes.put(node2.id, node2);
        } else {
            node2 = graph.nodes.get(id2).?;
        }

        try node1.add_edge(node2, 1);
        try node2.add_edge(node1, 1);
    }
    var have_seen = std.AutoHashMap(ID, bool).init(allocator);
    defer have_seen.deinit();
    var clique_size: u64 = graph.nodes.count();
    std.debug.print("Num nodes {d}\n", .{clique_size});
    while (clique_size > 0) {
        var num_with_enough: u64 = 0;
        var it = graph.nodes.iterator();
        while (it.next()) |entry| {
            const node = entry.value_ptr.*;
            if (node.edges.items.len >= clique_size - 1) {
                num_with_enough += 1;
            }
        }
        if (num_with_enough >= clique_size) {
            std.debug.print("Could have a clique of size {d}\n", .{clique_size});
            it = graph.nodes.iterator();
            while (it.next()) |entry| {
                const node1 = entry.value_ptr.*;
                var it2 = graph.nodes.iterator();
                have_seen.clearRetainingCapacity();
                try have_seen.put(node1.id, true);
                std.debug.print("Start node {s}\n", .{keys.items[node1.id.id].items});
                //TODO recursive through all nodes each time we could add a node create a copy hash set add to list of hash sets and recurse down till we try all nodes can return nothing then compute max hash set after
                while (it2.next()) |entry2| {
                    const node2 = entry2.value_ptr.*;
                    if (node2.id.id == node1.id.id) continue;
                    var connected = true;
                    var key_it = have_seen.keyIterator();
                    while (key_it.next()) |node_id| {
                        if (!node2.connected(graph.nodes.get(node_id.*).?)) {
                            std.debug.print("{s} not connected to {s}\n", .{ keys.items[node2.id.id].items, keys.items[node_id.id].items });
                            connected = false;
                            break;
                        }
                    }
                    if (connected) {
                        try have_seen.put(node2.id, true);
                        std.debug.print("added {s} to set\n", .{keys.items[node2.id.id].items});
                    }
                }
            }
            if (have_seen.count() >= clique_size) {
                var key_it = have_seen.keyIterator();
                while (key_it.next()) |node_id| {
                    std.debug.print("{s} ", .{keys.items[node_id.id].items});
                }
                std.debug.print("\n", .{});
                break;
            }
        }
        clique_size -= 1;
    }

    for (0..keys.items.len) |i| {
        keys.items[i].deinit();
    }
    return 0;
}

test "day23" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Interconnected sets with computer starting with t {d} in {d}ms\n", .{ try part1("../inputs/day23/test.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Interconnected sets with computer starting with t {d} in {d}ms\n", .{ try part2("../inputs/day23/test.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
