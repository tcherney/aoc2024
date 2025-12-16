// --- Day 11: Reactor ---
// You hear some loud beeping coming from a hatch in the floor of the factory, so you decide to check it out. Inside, you find several large electrical conduits and a ladder.

// Climbing down the ladder, you discover the source of the beeping: a large, toroidal reactor which powers the factory above. Some Elves here are hurriedly running between the reactor and a nearby server rack, apparently trying to fix something.

// One of the Elves notices you and rushes over. "It's a good thing you're here! We just installed a new server rack, but we aren't having any luck getting the reactor to communicate with it!" You glance around the room and see a tangle of cables and devices running from the server rack to the reactor. She rushes off, returning a moment later with a list of the devices and their outputs (your puzzle input).

// For example:

// aaa: you hhh
// you: bbb ccc
// bbb: ddd eee
// ccc: ddd eee fff
// ddd: ggg
// eee: out
// fff: out
// ggg: out
// hhh: ccc fff iii
// iii: out
// Each line gives the name of a device followed by a list of the devices to which its outputs are attached. So, bbb: ddd eee means that device bbb has two outputs, one leading to device ddd and the other leading to device eee.

// The Elves are pretty sure that the issue isn't due to any specific device, but rather that the issue is triggered by data following some specific path through the devices. Data only ever flows from a device through its outputs; it can't flow backwards.

// After dividing up the work, the Elves would like you to focus on the devices starting with the one next to you (an Elf hastily attaches a label which just says you) and ending with the main output to the reactor (which is the device with the label out).

// To help the Elves figure out which path is causing the issue, they need you to find every path from you to out.

// In this example, these are all of the paths from you to out:

// Data could take the connection from you to bbb, then from bbb to ddd, then from ddd to ggg, then from ggg to out.
// Data could take the connection to bbb, then to eee, then to out.
// Data could go to ccc, then ddd, then ggg, then out.
// Data could go to ccc, then eee, then out.
// Data could go to ccc, then fff, then out.
// In total, there are 5 different paths leading from you to out.

// How many different paths lead from you to out?

// --- Part Two ---
// Thanks in part to your analysis, the Elves have figured out a little bit about the issue. They now know that the problematic data path passes through both dac (a digital-to-analog converter) and fft (a device which performs a fast Fourier transform).

// They're still not sure which specific path is the problem, and so they now need you to find every path from svr (the server rack) to out. However, the paths you find must all also visit both dac and fft (in any order).

// For example:

// svr: aaa bbb
// aaa: fft
// fft: ccc
// bbb: tty
// tty: ccc
// ccc: ddd eee
// ddd: hub
// hub: fff
// eee: dac
// dac: fff
// fff: ggg hhh
// ggg: out
// hhh: out
// This new list of devices contains many paths from svr to out:

// svr,aaa,fft,ccc,ddd,hub,fff,ggg,out
// svr,aaa,fft,ccc,ddd,hub,fff,hhh,out
// svr,aaa,fft,ccc,eee,dac,fff,ggg,out
// svr,aaa,fft,ccc,eee,dac,fff,hhh,out
// svr,bbb,tty,ccc,ddd,hub,fff,ggg,out
// svr,bbb,tty,ccc,ddd,hub,fff,hhh,out
// svr,bbb,tty,ccc,eee,dac,fff,ggg,out
// svr,bbb,tty,ccc,eee,dac,fff,hhh,out
// However, only 2 paths from svr to out visit both dac and fft.

// Find all of the paths that lead from svr to out. How many of those paths visit both dac and fft?

const std = @import("std");
const common = @import("common");

pub const Node = struct {
    name: []u8,
    indx: usize,
    edges: std.ArrayList(Edge),
};

pub const Edge = struct {
    start: usize,
    end: usize,
};

pub const DPKey = struct {
    node: *Node,
    fft: bool,
    dac: bool,
};

pub const Graph = struct {
    nodes: std.ArrayList(Node),
    allocator: std.mem.Allocator,
    dp: std.AutoHashMap(DPKey, usize),

    pub fn init(allocator: std.mem.Allocator) Graph {
        return .{
            .nodes = std.ArrayList(Node).init(allocator),
            .allocator = allocator,
            .dp = std.AutoHashMap(DPKey, usize).init(allocator),
        };
    }

    pub fn deinit(self: *Graph) void {
        for (0..self.nodes.items.len) |i| {
            self.allocator.free(self.nodes.items[i].name);
            self.nodes.items[i].edges.deinit();
        }
        self.nodes.deinit();
        self.dp.deinit();
    }

    pub fn find_node(self: *Graph, name: []const u8) ?*Node {
        for (0..self.nodes.items.len) |i| {
            if (std.mem.eql(u8, name, self.nodes.items[i].name)) {
                return &self.nodes.items[i];
            }
        }
        return null;
    }

    pub fn print(self: *Graph) void {
        for (self.nodes.items) |node| {
            std.debug.print("{s}:", .{node.name});
            for (node.edges.items) |e| {
                if (node.indx == e.start) {
                    std.debug.print(" {s}", .{self.nodes.items[e.end].name});
                }
            }
            std.debug.print("\n", .{});
        }
    }
    pub fn compute_pathsv2(self: *Graph, node: *Node, end: *Node) !usize {
        return try self.compute_paths_visited(node, end, false, false);
    }

    pub fn compute_paths_visited(self: *Graph, node: *Node, end: *Node, fft: bool, dac: bool) !usize {
        if (node.indx == end.indx) {
            if (fft and dac) {
                return 1;
            } else {
                return 0;
            }
        } else {
            const key = DPKey{
                .node = node,
                .fft = fft,
                .dac = dac,
            };
            const e = self.dp.get(key);
            if (e) |val| {
                return val;
            }
            var num_paths: usize = 0;
            for (0..node.edges.items.len) |i| {
                //std.debug.print("Node {s} {s} {s}\n", .{ node.name, self.nodes.items[node.edges.items[i].start].name, self.nodes.items[node.edges.items[i].end].name });
                if (node.indx == node.edges.items[i].start) {
                    //std.debug.print("Path from {s} to {s}\n", .{ node.name, node.edges.items[i].end.name });
                    //std.debug.print("Leaving {s}\n", .{node.name});
                    var new_fft = fft;
                    var new_dac = dac;
                    if (std.mem.eql(u8, node.name, "fft")) {
                        new_fft = true;
                    } else if (std.mem.eql(u8, node.name, "dac")) {
                        new_dac = true;
                    }
                    num_paths += try self.compute_paths_visited(&self.nodes.items[node.edges.items[i].end], end, new_fft, new_dac);
                }
            }
            //std.debug.print("Num path {d}\n", .{num_paths});
            try self.dp.put(key, num_paths);
            return num_paths;
        }
    }

    pub fn compute_paths(self: *Graph, node: *Node, end: *Node) !usize {
        if (node.indx == end.indx) {
            return 1;
        } else {
            const key = DPKey{
                .node = node,
                .dac = false,
                .fft = false,
            };
            const e = self.dp.get(key);
            if (e) |val| {
                return val;
            }
            var num_paths: usize = 0;
            for (0..node.edges.items.len) |i| {
                //std.debug.print("Node {s} {any}\n", .{ node.name, node.edges.items[i] });
                if (node.indx == node.edges.items[i].start) {
                    //std.debug.print("Path from {s} to {s}\n", .{ node.name, node.edges.items[i].end.name });
                    num_paths += try self.compute_paths(&self.nodes.items[node.edges.items[i].end], end);
                }
            }
            //std.debug.print("Num path {d}\n", .{num_paths});
            try self.dp.put(key, num_paths);
            return num_paths;
        }
    }

    pub fn add_edge(self: *Graph, start: []const u8, end: []const u8) !void {
        //std.debug.print("Pre {s}, {s}\n", .{ start, end });
        const start_node = blk: {
            for (0..self.nodes.items.len) |i| {
                if (std.mem.eql(u8, self.nodes.items[i].name, start)) {
                    //std.debug.print("Found {s}\n{any}\n", .{ start, self.nodes.items[i] });
                    break :blk i;
                }
            } else {
                try self.nodes.append(.{
                    .name = try self.allocator.dupe(u8, start),
                    .edges = std.ArrayList(Edge).init(self.allocator),
                    .indx = self.nodes.items.len,
                });
                break :blk (self.nodes.items.len - 1);
            }
        };
        //std.debug.print("Post 1\n", .{});
        const end_node = blk: {
            for (0..self.nodes.items.len) |i| {
                if (std.mem.eql(u8, self.nodes.items[i].name, end)) {
                    break :blk i;
                }
            } else {
                try self.nodes.append(.{
                    .name = try self.allocator.dupe(u8, end),
                    .edges = std.ArrayList(Edge).init(self.allocator),
                    .indx = self.nodes.items.len,
                });
                break :blk (self.nodes.items.len - 1);
            }
        };
        //std.debug.print("Post 2\n {d}, {d}\n", .{ start_node, end_node });
        //std.debug.print("{s} {any}\n{s} {any}\n", .{ start_entry.key_ptr.*, start_entry.value_ptr.*.edges.items, end_entry.key_ptr.*, end_entry.value_ptr.*.edges.items });
        try self.nodes.items[start_node].edges.append(Edge{
            .start = start_node,
            .end = end_node,
        });
        try self.nodes.items[end_node].edges.append(Edge{
            .start = start_node,
            .end = end_node,
        });
    }
};

pub fn day11_p2(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day11/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var graph = Graph.init(self.allocator);
    defer graph.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;

        const start_node = line[0..std.mem.indexOfScalar(u8, line, ':').?];
        var iter = std.mem.splitScalar(u8, line, ' ');
        _ = iter.next();
        //std.debug.print("start: {s}\n", .{start_node});
        while (iter.next()) |end_node| {
            //std.debug.print("end: {s}\n", .{end_node});
            try graph.add_edge(start_node, end_node);
        }
    }
    graph.print();
    try common.timer_start();
    std.debug.print("{d} paths in {d} seconds.\n", .{ try graph.compute_pathsv2(graph.find_node("svr").?, graph.find_node("out").?), common.timer_end() });
}

pub fn day11_p1(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day11/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var graph = Graph.init(self.allocator);
    defer graph.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;

        const start_node = line[0..std.mem.indexOfScalar(u8, line, ':').?];
        var iter = std.mem.splitScalar(u8, line, ' ');
        _ = iter.next();
        //std.debug.print("start: {s}\n", .{start_node});
        while (iter.next()) |end_node| {
            //std.debug.print("end: {s}\n", .{end_node});
            try graph.add_edge(start_node, end_node);
        }
    }
    //graph.print();
    try common.timer_start();
    std.debug.print("{d} paths in {d} seconds.\n", .{ try graph.compute_paths(graph.find_node("you").?, graph.find_node("out").?), common.timer_end() });
}
