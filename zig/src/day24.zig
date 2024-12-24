const std = @import("std");
// https://adventofcode.com/2024/day/24

// --- Day 24: Crossed Wires ---
// You and The Historians arrive at the edge of a large grove somewhere in the jungle. After the last incident, the Elves installed a small device that monitors the fruit. While The Historians search the grove, one of them asks if you can take a look at the monitoring device; apparently, it's been malfunctioning recently.

// The device seems to be trying to produce a number through some boolean logic gates. Each gate has two inputs and one output. The gates all operate on values that are either true (1) or false (0).

// AND gates output 1 if both inputs are 1; if either input is 0, these gates output 0.
// OR gates output 1 if one or both inputs is 1; if both inputs are 0, these gates output 0.
// XOR gates output 1 if the inputs are different; if the inputs are the same, these gates output 0.
// Gates wait until both inputs are received before producing output; wires can carry 0, 1 or no value at all. There are no loops; once a gate has determined its output, the output will not change until the whole system is reset. Each wire is connected to at most one gate output, but can be connected to many gate inputs.

// Rather than risk getting shocked while tinkering with the live system, you write down all of the gate connections and initial wire values (your puzzle input) so you can consider them in relative safety. For example:

// x00: 1
// x01: 1
// x02: 1
// y00: 0
// y01: 1
// y02: 0

// x00 AND y00 -> z00
// x01 XOR y01 -> z01
// x02 OR y02 -> z02
// Because gates wait for input, some wires need to start with a value (as inputs to the entire system). The first section specifies these values. For example, x00: 1 means that the wire named x00 starts with the value 1 (as if a gate is already outputting that value onto that wire).

// The second section lists all of the gates and the wires connected to them. For example, x00 AND y00 -> z00 describes an instance of an AND gate which has wires x00 and y00 connected to its inputs and which will write its output to wire z00.

// In this example, simulating these gates eventually causes 0 to appear on wire z00, 0 to appear on wire z01, and 1 to appear on wire z02.

// Ultimately, the system is trying to produce a number by combining the bits on all wires starting with z. z00 is the least significant bit, then z01, then z02, and so on.

// In this example, the three output bits form the binary number 100 which is equal to the decimal number 4.

// Here's a larger example:

// x00: 1
// x01: 0
// x02: 1
// x03: 1
// x04: 0
// y00: 1
// y01: 1
// y02: 1
// y03: 1
// y04: 1

// ntg XOR fgs -> mjb
// y02 OR x01 -> tnw
// kwq OR kpj -> z05
// x00 OR x03 -> fst
// tgd XOR rvg -> z01
// vdt OR tnw -> bfw
// bfw AND frj -> z10
// ffh OR nrd -> bqk
// y00 AND y03 -> djm
// y03 OR y00 -> psh
// bqk OR frj -> z08
// tnw OR fst -> frj
// gnj AND tgd -> z11
// bfw XOR mjb -> z00
// x03 OR x00 -> vdt
// gnj AND wpb -> z02
// x04 AND y00 -> kjc
// djm OR pbm -> qhw
// nrd AND vdt -> hwm
// kjc AND fst -> rvg
// y04 OR y02 -> fgs
// y01 AND x02 -> pbm
// ntg OR kjc -> kwq
// psh XOR fgs -> tgd
// qhw XOR tgd -> z09
// pbm OR djm -> kpj
// x03 XOR y03 -> ffh
// x00 XOR y04 -> ntg
// bfw OR bqk -> z06
// nrd XOR fgs -> wpb
// frj XOR qhw -> z04
// bqk OR frj -> z07
// y03 OR x01 -> nrd
// hwm AND bqk -> z03
// tgd XOR rvg -> z12
// tnw OR pbm -> gnj
// After waiting for values on all wires starting with z, the wires in this system have the following values:

// bfw: 1
// bqk: 1
// djm: 1
// ffh: 0
// fgs: 1
// frj: 1
// fst: 1
// gnj: 1
// hwm: 1
// kjc: 0
// kpj: 1
// kwq: 0
// mjb: 1
// nrd: 1
// ntg: 0
// pbm: 1
// psh: 1
// qhw: 1
// rvg: 0
// tgd: 0
// tnw: 1
// vdt: 1
// wpb: 0
// z00: 0
// z01: 0
// z02: 0
// z03: 1
// z04: 0
// z05: 1
// z06: 1
// z07: 1
// z08: 1
// z09: 1
// z10: 1
// z11: 0
// z12: 0
// Combining the bits from all wires starting with z produces the binary number 0011111101000. Converting this number to decimal produces 2024.

// Simulate the system of gates and wires. What decimal number does it output on the wires starting with z?

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

pub const LogicSystem = struct {
    operations: std.ArrayList(Operation),
    keys: std.ArrayList(std.ArrayList(u8)),
    data: std.ArrayList(i8),
    z: std.ArrayList(usize),
    x: std.ArrayList(usize),
    y: std.ArrayList(usize),
    allocator: std.mem.Allocator,
    pub const Operation = struct {
        data_indx1: usize,
        data_indx2: usize,
        res_indx: usize,
        op_type: OperationType,
        pub const OperationType = enum { AND, XOR, OR };
        pub fn init(data_indx1: usize, data_indx2: usize, res_indx: usize, op_type: OperationType) Operation {
            return .{
                .data_indx1 = data_indx1,
                .data_indx2 = data_indx2,
                .res_indx = res_indx,
                .op_type = op_type,
            };
        }
        pub fn execute(self: *Operation, data: std.ArrayList(i8)) void {
            if (data.items[self.data_indx1] == -1 or data.items[self.data_indx2] == -1) return;
            switch (self.op_type) {
                .AND => {
                    data.items[self.res_indx] = data.items[self.data_indx1] & data.items[self.data_indx2];
                },
                .XOR => {
                    data.items[self.res_indx] = data.items[self.data_indx1] ^ data.items[self.data_indx2];
                },
                .OR => {
                    data.items[self.res_indx] = data.items[self.data_indx1] | data.items[self.data_indx2];
                },
            }
        }
    };
    pub fn init(allocator: std.mem.Allocator) LogicSystem {
        return LogicSystem{
            .operations = std.ArrayList(Operation).init(allocator),
            .keys = std.ArrayList(std.ArrayList(u8)).init(allocator),
            .data = std.ArrayList(i8).init(allocator),
            .allocator = allocator,
            .z = std.ArrayList(usize).init(allocator),
            .x = std.ArrayList(usize).init(allocator),
            .y = std.ArrayList(usize).init(allocator),
        };
    }
    pub fn deinit(self: *LogicSystem) void {
        for (0..self.keys.items.len) |i| {
            self.keys.items[i].deinit();
        }
        self.keys.deinit();
        self.data.deinit();
        self.operations.deinit();
        self.z.deinit();
        self.x.deinit();
        self.y.deinit();
    }

    pub fn add_data(self: *LogicSystem, name: []const u8, val: []const u8) !void {
        const name_indx = try add_key(&self.keys, name, self.allocator);
        if (name_indx >= self.data.items.len) {
            try self.data.append(try std.fmt.parseInt(i8, val, 10));
        } else {
            self.data.items[name_indx] = try std.fmt.parseInt(i8, val, 10);
        }
        if (name[0] == 'x') {
            const parsed_indx = try std.fmt.parseInt(usize, name[1..], 10);
            while (parsed_indx >= self.x.items.len) try self.x.append(0);
            self.x.items[parsed_indx] = name_indx;
        } else if (name[0] == 'y') {
            const parsed_indx = try std.fmt.parseInt(usize, name[1..], 10);
            while (parsed_indx >= self.y.items.len) try self.y.append(0);
            self.y.items[parsed_indx] = name_indx;
        }
    }

    pub fn add_operation(self: *LogicSystem, data1: []const u8, op: []const u8, data2: []const u8, res: []const u8) !void {
        const data_indx1 = try add_key(&self.keys, data1, self.allocator);
        const data_indx2 = try add_key(&self.keys, data2, self.allocator);
        const res_indx = try add_key(&self.keys, res, self.allocator);
        if (data_indx1 >= self.data.items.len) {
            try self.data.append(-1);
        }
        if (data_indx2 >= self.data.items.len) {
            try self.data.append(-1);
        }
        if (res_indx >= self.data.items.len) {
            try self.data.append(-1);
        }
        if (std.mem.eql(u8, "AND", op)) {
            try self.operations.append(Operation.init(data_indx1, data_indx2, res_indx, .AND));
        } else if (std.mem.eql(u8, "OR", op)) {
            try self.operations.append(Operation.init(data_indx1, data_indx2, res_indx, .OR));
        } else {
            try self.operations.append(Operation.init(data_indx1, data_indx2, res_indx, .XOR));
        }
        if (res[0] == 'z') {
            const parsed_indx = try std.fmt.parseInt(usize, res[1..], 10);
            while (parsed_indx >= self.z.items.len) try self.z.append(0);
            self.z.items[parsed_indx] = res_indx;
        }
    }

    pub fn print_data(self: *LogicSystem) void {
        for (0..self.data.items.len) |i| {
            std.debug.print("{s}: {d}\n", .{ self.keys.items[i].items, self.data.items[i] });
        }
    }

    pub fn answer_addition(self: *LogicSystem) void {
        var x: u64 = 0;
        for (0..self.x.items.len) |i| {
            const x_bit = self.data.items[self.x.items[i]];
            //std.debug.print("{d}", .{z_bit});
            if (x_bit > 0) {
                x |= @as(u64, 1) << @as(u6, @intCast(i));
            }
        }

        var y: u64 = 0;
        for (0..self.y.items.len) |i| {
            const y_bit = self.data.items[self.y.items[i]];
            //std.debug.print("{d}", .{z_bit});
            if (y_bit > 0) {
                y |= @as(u64, 1) << @as(u6, @intCast(i));
            }
        }
        std.debug.print("{d}+{d}={d}\n", .{ x, y, x + y });
    }

    pub fn compute_z(self: *LogicSystem) u64 {
        var res: u64 = 0;
        for (0..self.z.items.len) |i| {
            const z_bit = self.data.items[self.z.items[i]];
            //std.debug.print("{d}", .{z_bit});
            if (z_bit > 0) {
                res |= @as(u64, 1) << @as(u6, @intCast(i));
            }
        }
        //std.debug.print("\n", .{});
        return res;
    }

    pub fn report_problem(self: *LogicSystem, in1: usize, in2: usize, op_type: Operation.OperationType) void {
        const data1 = self.keys.items[in1].items;
        const data2 = self.keys.items[in2].items;
        const op_str = switch (op_type) {
            .AND => "AND",
            .XOR => "XOR",
            .OR => "OR",
        };
        std.debug.print("\nProblem: Missing operation {s} for {s} {s}\n", .{ op_str, data1, data2 });
    }

    pub inline fn to_str(self: *LogicSystem, indx: usize) []u8 {
        return self.keys.items[indx].items;
    }

    pub fn swap_op(self: *LogicSystem, res_indx1: usize, res_indx2: usize) void {
        for (0..self.operations.items.len) |i| {
            if (self.operations.items[i].res_indx == res_indx1) {
                self.operations.items[i].res_indx = res_indx2;
            } else if (self.operations.items[i].res_indx == res_indx2) {
                self.operations.items[i].res_indx = res_indx1;
            }
        }
    }

    pub fn build_adder(self: *LogicSystem, errors: *std.ArrayList([]const u8)) !void {
        var x_in: usize = self.x.items[0];
        var y_in: usize = self.y.items[0];
        var cout: usize = self.find_op(x_in, y_in, .AND) orelse {
            self.report_problem(x_in, y_in, .AND);
            return;
        };
        var sum: usize = self.find_op(x_in, y_in, .XOR) orelse {
            self.report_problem(x_in, y_in, .XOR);
            return;
        };
        std.debug.print("cout(0): {s}, sum(0): {s}\n", .{ self.to_str(cout), self.to_str(sum) });
        for (1..self.x.items.len) |i| {
            x_in = self.x.items[i];
            y_in = self.y.items[i];
            var cin = cout;

            var sum_i: usize = undefined;
            if (self.find_op(x_in, y_in, .XOR)) |res| {
                sum_i = res;
            } else {
                self.report_problem(x_in, y_in, .XOR);
            }

            var cout_i: usize = undefined;
            if (self.find_op(x_in, y_in, .AND)) |res| {
                cout_i = res;
            } else {
                self.report_problem(x_in, y_in, .AND);
            }

            var carry_i: usize = undefined;
            if (self.find_op(cin, sum_i, .AND)) |res| {
                carry_i = res;
            } else {
                self.swap_op(cout_i, sum_i);
                std.debug.print("swapped {s},{s}\n", .{ self.keys.items[cout_i].items, self.keys.items[sum_i].items });
                try errors.append(self.keys.items[cout_i].items);
                try errors.append(self.keys.items[sum_i].items);
                const tmp = cout_i;
                cout_i = sum_i;
                sum_i = tmp;
                if (self.find_op(cin, sum_i, .AND)) |res| {
                    carry_i = res;
                } else {
                    self.report_problem(cin, sum_i, .AND);
                }
            }

            if (self.find_op(cin, sum_i, .XOR)) |res| {
                sum = res;
            } else {
                self.report_problem(cin, sum_i, .XOR);
            }
            if (sum != self.z.items[i]) {
                if (cin == self.z.items[i]) {
                    self.swap_op(cin, sum);
                    std.debug.print("swapped {s},{s}\n", .{ self.keys.items[cin].items, self.keys.items[sum].items });
                    try errors.append(self.keys.items[cin].items);
                    try errors.append(self.keys.items[sum].items);
                    const tmp = sum;
                    sum = cin;
                    cin = tmp;
                } else if (sum_i == self.z.items[i]) {
                    self.swap_op(sum_i, sum);
                    std.debug.print("swapped {s},{s}\n", .{ self.keys.items[sum_i].items, self.keys.items[sum].items });
                    try errors.append(self.keys.items[sum_i].items);
                    try errors.append(self.keys.items[sum].items);
                    const tmp = sum;
                    sum = sum_i;
                    sum_i = tmp;
                } else if (cout_i == self.z.items[i]) {
                    self.swap_op(cout_i, sum);
                    std.debug.print("swapped {s},{s}\n", .{ self.keys.items[cout_i].items, self.keys.items[sum].items });
                    try errors.append(self.keys.items[cout_i].items);
                    try errors.append(self.keys.items[sum].items);
                    const tmp = sum;
                    sum = cout_i;
                    cout_i = tmp;
                } else if (carry_i == self.z.items[i]) {
                    self.swap_op(carry_i, sum);
                    std.debug.print("swapped {s},{s}\n", .{ self.keys.items[carry_i].items, self.keys.items[sum].items });
                    try errors.append(self.keys.items[carry_i].items);
                    try errors.append(self.keys.items[sum].items);
                    const tmp = sum;
                    sum = carry_i;
                    carry_i = tmp;
                }
            }

            if (self.find_op(cout_i, carry_i, .OR)) |res| {
                cout = res;
            } else {
                self.report_problem(cout_i, carry_i, .OR);
            }

            if (cout == self.z.items[i] and i != self.x.items.len - 1) {
                self.swap_op(cout, sum);
                std.debug.print("swapped {s},{s}\n", .{ self.keys.items[cout].items, self.keys.items[sum].items });
                try errors.append(self.keys.items[cout].items);
                try errors.append(self.keys.items[sum].items);
                const tmp = sum;
                sum = cout;
                cout = tmp;
            }
            std.debug.print("cin({d}): {s}, ", .{ i, self.to_str(cin) });
            std.debug.print("sum_i({d}): {s}, ", .{ i, self.to_str(sum_i) });
            std.debug.print("cout_i({d}): {s}, ", .{ i, self.to_str(cout_i) });
            std.debug.print("carry_i({d}): {s}, ", .{ i, self.to_str(carry_i) });
            std.debug.print("sum({d}): {s}, ", .{ i, self.to_str(sum) });
            std.debug.print("cout({d}): {s}\n", .{ i, self.to_str(cout) });
        }
    }

    pub fn find_op(self: *LogicSystem, in1: usize, in2: usize, op_type: Operation.OperationType) ?usize {
        for (0..self.operations.items.len) |i| {
            const op = self.operations.items[i];
            if (op.op_type == op_type and ((op.data_indx1 == in1 and op.data_indx2 == in2) or (op.data_indx1 == in2 and op.data_indx2 == in1))) {
                return op.res_indx;
            }
        }
        return null;
    }
};

pub fn add_key(keys: *std.ArrayList(std.ArrayList(u8)), key: []const u8, allocator: std.mem.Allocator) !u64 {
    for (0..keys.items.len) |i| {
        if (keys.items[i].items[0] == key[0] and keys.items[i].items[1] == key[1] and keys.items[i].items[2] == key[2]) return i;
    }
    try keys.append((std.ArrayList(u8).init(allocator)));
    _ = try keys.items[keys.items.len - 1].writer().write(key);
    return keys.items.len - 1;
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var logic_system = LogicSystem.init(allocator);
    defer logic_system.deinit();

    var keys = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer keys.deinit();

    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        var it = std.mem.splitScalar(u8, line, ' ');
        const name = it.next().?;
        const val = it.next().?;
        try logic_system.add_data(name[0 .. name.len - 1], val);
    }
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var it = std.mem.splitScalar(u8, line, ' ');
        const data1 = it.next().?;
        const op = it.next().?;
        const data2 = it.next().?;
        _ = it.next();
        const res = it.next().?;
        try logic_system.add_operation(data1, op, data2, res);
    }
    for (0..logic_system.operations.items.len) |_| {
        for (0..logic_system.operations.items.len) |i| {
            logic_system.operations.items[i].execute(logic_system.data);
        }
    }
    logic_system.print_data();

    return logic_system.compute_z();
}

fn compareStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}

// --- Part Two ---
// After inspecting the monitoring device more closely, you determine that the system you're simulating is trying to add two binary numbers.

// Specifically, it is treating the bits on wires starting with x as one binary number, treating the bits on wires starting with y as a second binary number, and then attempting to add those two numbers together. The output of this operation is produced as a binary number on the wires starting with z. (In all three cases, wire 00 is the least significant bit, then 01, then 02, and so on.)

// The initial values for the wires in your puzzle input represent just one instance of a pair of numbers that sum to the wrong value. Ultimately, any two binary numbers provided as input should be handled correctly. That is, for any combination of bits on wires starting with x and wires starting with y, the sum of the two numbers those bits represent should be produced as a binary number on the wires starting with z.

// For example, if you have an addition system with four x wires, four y wires, and five z wires, you should be able to supply any four-bit number on the x wires, any four-bit number on the y numbers, and eventually find the sum of those two numbers as a five-bit number on the z wires. One of the many ways you could provide numbers to such a system would be to pass 11 on the x wires (1011 in binary) and 13 on the y wires (1101 in binary):

// x00: 1
// x01: 1
// x02: 0
// x03: 1
// y00: 1
// y01: 0
// y02: 1
// y03: 1
// If the system were working correctly, then after all gates are finished processing, you should find 24 (11+13) on the z wires as the five-bit binary number 11000:

// z00: 0
// z01: 0
// z02: 0
// z03: 1
// z04: 1
// Unfortunately, your actual system needs to add numbers with many more bits and therefore has many more wires.

// Based on forensic analysis of scuff marks and scratches on the device, you can tell that there are exactly four pairs of gates whose output wires have been swapped. (A gate can only be in at most one such pair; no gate's output was swapped multiple times.)

// For example, the system below is supposed to find the bitwise AND of the six-bit number on x00 through x05 and the six-bit number on y00 through y05 and then write the result as a six-bit number on z00 through z05:

// x00: 0
// x01: 1
// x02: 0
// x03: 1
// x04: 0
// x05: 1
// y00: 0
// y01: 0
// y02: 1
// y03: 1
// y04: 0
// y05: 1

// x00 AND y00 -> z05
// x01 AND y01 -> z02
// x02 AND y02 -> z01
// x03 AND y03 -> z03
// x04 AND y04 -> z04
// x05 AND y05 -> z00
// However, in this example, two pairs of gates have had their output wires swapped, causing the system to produce wrong answers. The first pair of gates with swapped outputs is x00 AND y00 -> z05 and x05 AND y05 -> z00; the second pair of gates is x01 AND y01 -> z02 and x02 AND y02 -> z01. Correcting these two swaps results in this system that works as intended for any set of initial values on wires that start with x or y:

// x00 AND y00 -> z00
// x01 AND y01 -> z01
// x02 AND y02 -> z02
// x03 AND y03 -> z03
// x04 AND y04 -> z04
// x05 AND y05 -> z05
// In this example, two pairs of gates have outputs that are involved in a swap. By sorting their output wires' names and joining them with commas, the list of wires involved in swaps is z00,z01,z02,z05.

// Of course, your actual system is much more complex than this, and the gates that need their outputs swapped could be anywhere, not just attached to a wire starting with z. If you were to determine that you need to swap output wires aaa with eee, ooo with z99, bbb with ccc, and aoc with z24, your answer would be aaa,aoc,bbb,ccc,eee,ooo,z24,z99.

// Your system of gates and wires has four pairs of gates which need their output wires swapped - eight wires in total. Determine which four pairs of gates need their outputs swapped so that your system correctly performs addition; what do you get if you sort the names of the eight wires involved in a swap and then join those names with commas?

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var logic_system = LogicSystem.init(allocator);
    defer logic_system.deinit();

    var keys = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer keys.deinit();

    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        var it = std.mem.splitScalar(u8, line, ' ');
        const name = it.next().?;
        const val = it.next().?;
        try logic_system.add_data(name[0 .. name.len - 1], val);
    }
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) continue;
        var it = std.mem.splitScalar(u8, line, ' ');
        const data1 = it.next().?;
        const op = it.next().?;
        const data2 = it.next().?;
        _ = it.next();
        const res = it.next().?;
        try logic_system.add_operation(data1, op, data2, res);
    }
    var errors = std.ArrayList([]const u8).init(allocator);
    defer errors.deinit();
    try logic_system.build_adder(&errors);
    //try logic_system.find_errors(&errors);
    for (0..logic_system.operations.items.len + 5) |_| {
        for (0..logic_system.operations.items.len) |i| {
            logic_system.operations.items[i].execute(logic_system.data);
        }
    }
    //logic_system.print_data();
    logic_system.answer_addition();
    if (errors.items.len > 0) {
        std.mem.sort([]const u8, errors.items, {}, comptime compareStrings);
        std.debug.print("{s}", .{errors.items[0]});
        for (1..errors.items.len) |i| {
            std.debug.print(",{s}", .{errors.items[i]});
        }
        std.debug.print("\n", .{});
    }
    return logic_system.compute_z();
}

test "day24" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("{d} in {d}ms\n", .{ try part1("../inputs/day24/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("{d} in {d}ms\n", .{ try part2("../inputs/day24/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
