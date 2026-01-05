// --- Day 8: Playground ---
// Equipped with a new understanding of teleporter maintenance, you confidently step onto the repaired teleporter pad.

// You rematerialize on an unfamiliar teleporter pad and find yourself in a vast underground space which contains a giant playground!

// Across the playground, a group of Elves are working on setting up an ambitious Christmas decoration project. Through careful rigging, they have suspended a large number of small electrical junction boxes.

// Their plan is to connect the junction boxes with long strings of lights. Most of the junction boxes don't provide electricity; however, when two junction boxes are connected by a string of lights, electricity can pass between those two junction boxes.

// The Elves are trying to figure out which junction boxes to connect so that electricity can reach every junction box. They even have a list of all of the junction boxes' positions in 3D space (your puzzle input).

// For example:

// 162,817,812
// 57,618,57
// 906,360,560
// 592,479,940
// 352,342,300
// 466,668,158
// 542,29,236
// 431,825,988
// 739,650,466
// 52,470,668
// 216,146,977
// 819,987,18
// 117,168,530
// 805,96,715
// 346,949,466
// 970,615,88
// 941,993,340
// 862,61,35
// 984,92,344
// 425,690,689
// This list describes the position of 20 junction boxes, one per line. Each position is given as X,Y,Z coordinates. So, the first junction box in the list is at X=162, Y=817, Z=812.

// To save on string lights, the Elves would like to focus on connecting pairs of junction boxes that are as close together as possible according to straight-line distance. In this example, the two junction boxes which are closest together are 162,817,812 and 425,690,689.

// By connecting these two junction boxes together, because electricity can flow between them, they become part of the same circuit. After connecting them, there is a single circuit which contains two junction boxes, and the remaining 18 junction boxes remain in their own individual circuits.

// Now, the two junction boxes which are closest together but aren't already directly connected are 162,817,812 and 431,825,988. After connecting them, since 162,817,812 is already connected to another junction box, there is now a single circuit which contains three junction boxes and an additional 17 circuits which contain one junction box each.

// The next two junction boxes to connect are 906,360,560 and 805,96,715. After connecting them, there is a circuit containing 3 junction boxes, a circuit containing 2 junction boxes, and 15 circuits which contain one junction box each.

// The next two junction boxes are 431,825,988 and 425,690,689. Because these two junction boxes were already in the same circuit, nothing happens!

// This process continues for a while, and the Elves are concerned that they don't have enough extension cables for all these circuits. They would like to know how big the circuits will be.

// After making the ten shortest connections, there are 11 circuits: one circuit which contains 5 junction boxes, one circuit which contains 4 junction boxes, two circuits which contain 2 junction boxes each, and seven circuits which each contain a single junction box. Multiplying together the sizes of the three largest circuits (5, 4, and one of the circuits of size 2) produces 40.

// Your list contains many junction boxes; connect together the 1000 pairs of junction boxes which are closest together. Afterward, what do you get if you multiply together the sizes of the three largest circuits?

const std = @import("std");
const common = @import("common");

var scratch_buffer: [1024]u8 = undefined;
pub fn on_render(self: anytype) !void {
    //TODO as boxes are connected show consolidated ids
    const str = try std.fmt.bufPrint(&scratch_buffer, "Day 8\nPart 1: {d}\nPart 2: {d}", .{ part1, part2 });
    self.e.renderer.ascii.draw_text(str, 5, 0, common.Colors.GREEN, self.window);
}

pub fn deinit(_: anytype) void {
    if (state != .init) {
        points.deinit();
        distances.deinit();
        circuits.deinit();
    }
}

pub fn update(self: anytype) !void {
    switch (state) {
        .init => {
            try init(self);
        },
        .part1 => {
            try day8_p1();
        },
        .part2 => {
            try day8_p2();
        },
        else => {},
    }
}

pub fn init(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day8/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    points = std.ArrayList(JunctionPoint).init(self.allocator);
    var circuit_id: usize = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var iter = std.mem.splitScalar(u8, line, ',');
        try points.append(JunctionPoint{
            .x = try std.fmt.parseFloat(f64, iter.next().?),
            .y = try std.fmt.parseFloat(f64, iter.next().?),
            .z = try std.fmt.parseFloat(f64, iter.next().?),
            .circuit = circuit_id,
        });
        circuit_id += 1;
    }
    distances = std.ArrayList(Distance).init(self.allocator);

    circuits = Circuits.init(self.allocator);
    for (0..points.items.len) |i| {
        var c = std.ArrayList(*JunctionPoint).init(self.allocator);
        try c.append(&points.items[i]);
        try circuits.put(points.items[i].circuit, c);
    }
    try min_dist();
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

var state: RunningState = .init;
var part1: u64 = 0;
var part2: u64 = 0;
var points: std.ArrayList(JunctionPoint) = undefined;
var distances: std.ArrayList(Distance) = undefined;
var circuits: Circuits = undefined;

pub const JunctionPoint = struct {
    x: f64,
    y: f64,
    z: f64,
    circuit: usize,

    pub fn dist(left: *const JunctionPoint, right: JunctionPoint) f64 {
        return @sqrt(std.math.pow(f64, left.x - right.x, 2) + std.math.pow(f64, left.y - right.y, 2) + std.math.pow(f64, left.z - right.z, 2));
    }
};

pub const Distance = struct {
    p1: *JunctionPoint,
    p2: *JunctionPoint,
    magnitude: f64,
};

pub const Circuits = std.AutoHashMap(usize, std.ArrayList(*JunctionPoint));

pub fn min_dist() !void {
    for (0..points.items.len) |i| {
        for (i + 1..points.items.len) |j| {
            const dist = points.items[i].dist(points.items[j]);
            try distances.append(.{
                .magnitude = dist,
                .p1 = &points.items[i],
                .p2 = &points.items[j],
            });
        }
    }
    std.mem.sort(Distance, distances.items, {}, struct {
        pub fn compare(_: void, lhs: Distance, rhs: Distance) bool {
            return lhs.magnitude < rhs.magnitude;
        }
    }.compare);
}

pub fn ordered_count_insert(counts: []usize, val: usize) void {
    for (0..counts.len) |i| {
        if (val > counts[i]) {
            var temp = counts[i];
            counts[i] = val;
            for (i + 1..counts.len) |j| {
                const temp2 = counts[j];
                counts[j] = temp;
                temp = temp2;
            }
            break;
        }
    }
}

pub fn connect_points_p1(num_connections: usize) !usize {
    var connections_made: usize = 0;
    var counts: [3]usize = [_]usize{0} ** 3;
    for (distances.items) |d| {
        //std.debug.print("Distance {any}\n", .{d});
        if (d.p1.circuit != d.p2.circuit) {
            const p2_circuit = circuits.getEntry(d.p2.circuit).?;
            const p1_circuit = circuits.getEntry(d.p1.circuit).?;
            //std.debug.print("Size before {d}, {d}\n", .{ p1_circuit.value_ptr.items.len, p2_circuit.value_ptr.items.len });
            for (p2_circuit.value_ptr.items) |p| {
                p.circuit = d.p1.circuit;
                try p1_circuit.value_ptr.append(p);
            }
            p2_circuit.value_ptr.clearRetainingCapacity();
            //std.debug.print("Size after {d}, {d}\n", .{ p1_circuit.value_ptr.items.len, p2_circuit.value_ptr.items.len });
            //ordered_count_insert(&counts, p1_circuit.value_ptr.items.len);
        }
        connections_made += 1;
        if (connections_made == num_connections) {
            break;
        }
    }
    var iter = circuits.valueIterator();
    while (iter.next()) |c| {
        //std.debug.print("{d} Counts {any}\n", .{ c.items.len, counts });
        ordered_count_insert(&counts, c.items.len);
    }
    std.debug.print("{d}, {d}, {d}\n", .{ counts[0], counts[1], counts[2] });
    return counts[0] * counts[1] * counts[2];
}

pub fn connect_points_p2(num_points: usize) !usize {
    for (distances.items) |d| {
        //std.debug.print("Distance {any}\n", .{d});
        if (d.p1.circuit != d.p2.circuit) {
            const p2_circuit = circuits.getEntry(d.p2.circuit).?;
            const p1_circuit = circuits.getEntry(d.p1.circuit).?;
            //std.debug.print("Size before {d}, {d}\n", .{ p1_circuit.value_ptr.items.len, p2_circuit.value_ptr.items.len });
            for (p2_circuit.value_ptr.items) |p| {
                p.circuit = d.p1.circuit;
                try p1_circuit.value_ptr.append(p);
            }
            p2_circuit.value_ptr.clearRetainingCapacity();
            //std.debug.print("Size after {d}, {d}\n", .{ p1_circuit.value_ptr.items.len, p2_circuit.value_ptr.items.len });
            //ordered_count_insert(&counts, p1_circuit.value_ptr.items.len);
            if (p1_circuit.value_ptr.items.len == num_points) {
                return @as(usize, @intFromFloat(d.p1.x)) * @as(usize, @intFromFloat(d.p2.x));
            }
        }
    }
    return 0;
}

pub fn day8_p2() !void {
    part2 = try connect_points_p2(points.items.len);
    std.debug.print("Need extension cable of {d}\n", .{part2});
    var iter = circuits.iterator();
    while (iter.next()) |i| {
        i.value_ptr.deinit();
    }
}

pub fn day8_p1() !void {
    const num_connections = 1000;
    part1 = try connect_points_p1(num_connections);
    std.debug.print("Three largest multiplied together {d}\n", .{part1});
    var iter = circuits.iterator();
    while (iter.next()) |i| {
        i.value_ptr.deinit();
    }
}
