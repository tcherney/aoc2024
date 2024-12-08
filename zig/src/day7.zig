const std = @import("std");
// https://adventofcode.com/2024/day/7
// --- Day 7: Bridge Repair ---
// The Historians take you to a familiar rope bridge over a river in the middle of a jungle. The Chief isn't on this side of the bridge, though; maybe he's on the other side?

// When you go to cross the bridge, you notice a group of engineers trying to repair it. (Apparently, it breaks pretty frequently.) You won't be able to cross until it's fixed.

// You ask how long it'll take; the engineers tell you that it only needs final calibrations, but some young elephants were playing nearby and stole all the operators from their calibration equations! They could finish the calibrations if only someone could determine which test values could possibly be produced by placing any combination of operators into their calibration equations (your puzzle input).

// For example:

// 190: 10 19
// 3267: 81 40 27
// 83: 17 5
// 156: 15 6
// 7290: 6 8 6 15
// 161011: 16 10 13
// 192: 17 8 14
// 21037: 9 7 18 13
// 292: 11 6 16 20
// Each line represents a single equation. The test value appears before the colon on each line; it is your job to determine whether the remaining numbers can be combined with operators to produce the test value.

// Operators are always evaluated left-to-right, not according to precedence rules. Furthermore, numbers in the equations cannot be rearranged. Glancing into the jungle, you can see elephants holding two different types of operators: add (+) and multiply (*).

// Only three of the above equations can be made true by inserting operators:

// 190: 10 19 has only one position that accepts an operator: between 10 and 19. Choosing + would give 29, but choosing * would give the test value (10 * 19 = 190).
// 3267: 81 40 27 has two positions for operators. Of the four possible configurations of the operators, two cause the right side to match the test value: 81 + 40 * 27 and 81 * 40 + 27 both equal 3267 (when evaluated left-to-right)!
// 292: 11 6 16 20 can be solved in exactly one way: 11 + 6 * 16 + 20.
// The engineers just need the total calibration result, which is the sum of the test values from just the equations that could possibly be true. In the above example, the sum of the test values for the three equations listed above is 3749.

// Determine which equations could possibly be true. What is their total calibration result?
pub const CalcTree = struct {
    head: *Node,
    allocator: std.mem.Allocator,
    pub const Node = struct {
        val: u64,
        left: ?*Node,
        right: ?*Node,
        pub fn init(val: u64) Node {
            return .{
                .val = val,
                .left = null,
                .right = null,
            };
        }
    };
    pub fn deinit_node(node: ?*Node, allocator: std.mem.Allocator) void {
        if (node) |parent| {
            deinit_node(parent.left, allocator);
            deinit_node(parent.right, allocator);
            allocator.destroy(parent);
        }
    }
    pub fn deinit(self: *CalcTree) void {
        deinit_node(self.head.left, self.allocator);
        deinit_node(self.head.right, self.allocator);
        self.allocator.destroy(self.head);
    }
    pub fn add_node(target_val: u64, val: u64, nums: []u64, allocator: std.mem.Allocator) !*Node {
        var ret = try allocator.create(Node);
        ret.* = Node.init(val);
        if (nums.len > 1 and val <= target_val) {
            ret.left = try add_node(target_val, ret.val + nums[0], nums[1..], allocator);
            ret.right = try add_node(target_val, ret.val * nums[0], nums[1..], allocator);
        } else if (nums.len == 1 and val <= target_val) {
            ret.left = try allocator.create(Node);
            ret.right = try allocator.create(Node);
            ret.left.?.* = Node.init(ret.val + nums[0]);
            ret.right.?.* = Node.init(ret.val * nums[0]);
        }
        return ret;
    }
    pub fn build_tree(target_val: u64, nums: []u64, allocator: std.mem.Allocator) !CalcTree {
        var head = try allocator.create(Node);
        head.* = Node.init(nums[0]);
        head.left = try add_node(target_val, head.val + nums[1], nums[2..], allocator);
        head.right = try add_node(target_val, head.val * nums[1], nums[2..], allocator);
        return .{
            .head = head,
            .allocator = allocator,
        };
    }
    pub fn has_solution(self: *CalcTree, target_val: u64, current_node: *Node) bool {
        if (current_node.left == null and current_node.right == null) {
            if (current_node.val == target_val) return true;
            return false;
        }
        return self.has_solution(target_val, current_node.left.?) or self.has_solution(target_val, current_node.right.?);
    }
};

pub fn solve_equation(res: u64, nums: []u64, allocator: std.mem.Allocator) !bool {
    var tree = try CalcTree.build_tree(res, nums, allocator);
    const ret = tree.has_solution(res, tree.head);
    //std.debug.print("{any}\n", .{tree});
    tree.deinit();
    return ret;
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var buf: [4096]u8 = undefined;
    var nums: std.ArrayList(u64) = std.ArrayList(u64).init(allocator);
    defer nums.deinit();
    var result: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var cleaned_line: []const u8 = undefined;
        if (std.mem.indexOfScalar(u8, line, '\r')) |indx| {
            cleaned_line = line[0..indx];
        } else {
            cleaned_line = line;
        }
        var it = std.mem.tokenizeScalar(u8, cleaned_line, ' ');
        var calc_str = it.next().?;
        calc_str = calc_str[0 .. calc_str.len - 1];
        const calc_res = try std.fmt.parseInt(u64, calc_str, 10);
        //std.debug.print("Result: {d}\n", .{calc_res});
        nums.clearRetainingCapacity();
        while (it.next()) |num_str| {
            try nums.append(try std.fmt.parseInt(u64, num_str, 10));
        }
        if (try solve_equation(calc_res, nums.items, allocator)) result += calc_res;
    }
    return result;
}

// --- Part Two ---
// The engineers seem concerned; the total calibration result you gave them is nowhere close to being within safety tolerances. Just then, you spot your mistake: some well-hidden elephants are holding a third type of operator.

// The concatenation operator (||) combines the digits from its left and right inputs into a single number. For example, 12 || 345 would become 12345. All operators are still evaluated left-to-right.

// Now, apart from the three equations that could be made true using only addition and multiplication, the above example has three more equations that can be made true by inserting operators:

// 156: 15 6 can be made true through a single concatenation: 15 || 6 = 156.
// 7290: 6 8 6 15 can be made true using 6 * 8 || 6 * 15.
// 192: 17 8 14 can be made true using 17 || 8 + 14.
// Adding up all six test values (the three that could be made before using only + and * plus the new three that can now be made by also using ||) produces the new total calibration result of 11387.

// Using your new knowledge of elephant hiding spots, determine which equations could possibly be true. What is their total calibration result?

//TODO add reverse
pub const CalcTreeP2 = struct {
    has_solution: bool = false,
    var num_buf: [1024]u8 = undefined;
    pub fn add_node(self: *CalcTreeP2, target_val: u64, val: u64, nums: []u64) !void {
        if (!self.has_solution and nums.len > 1 and val <= target_val) {
            try self.add_node(target_val, val + nums[0], nums[1..]);
            try self.add_node(target_val, try std.fmt.parseInt(u64, try std.fmt.bufPrint(&num_buf, "{d}{d}", .{ val, nums[0] }), 10), nums[1..]);
            try self.add_node(target_val, val * nums[0], nums[1..]);
        } else if (!self.has_solution and nums.len == 1 and val <= target_val) {
            self.has_solution = (val + nums[0] == target_val) or (val * nums[0] == target_val) or (try std.fmt.parseInt(u64, try std.fmt.bufPrint(&num_buf, "{d}{d}", .{ val, nums[0] }), 10) == target_val);
            if (self.has_solution) {
                //std.debug.print("found solution for {d}\n", .{target_val});
            }
        } else if (!self.has_solution and nums.len == 0) {
            self.has_solution = val == target_val;
        }
    }
    pub fn build_tree(target_val: u64, nums: []u64) !bool {
        var tree = CalcTreeP2{
            .has_solution = false,
        };
        try tree.add_node(target_val, nums[0] + nums[1], nums[2..]);
        try tree.add_node(target_val, try std.fmt.parseInt(u64, try std.fmt.bufPrint(&num_buf, "{d}{d}", .{ nums[0], nums[1] }), 10), nums[2..]);
        try tree.add_node(target_val, nums[0] * nums[1], nums[2..]);
        const result = tree.has_solution;
        return result;
    }
};

pub fn solve_equation_p2(res: u64, nums: []u64) !bool {
    return try CalcTreeP2.build_tree(res, nums);
}
pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var buf: [4096]u8 = undefined;
    var nums: std.ArrayList(u64) = std.ArrayList(u64).init(allocator);
    defer nums.deinit();
    var result: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var cleaned_line: []const u8 = undefined;
        if (std.mem.indexOfScalar(u8, line, '\r')) |indx| {
            cleaned_line = line[0..indx];
        } else {
            cleaned_line = line;
        }
        var it = std.mem.tokenizeScalar(u8, cleaned_line, ' ');
        var calc_str = it.next().?;
        calc_str = calc_str[0 .. calc_str.len - 1];
        const calc_res = try std.fmt.parseInt(u64, calc_str, 10);
        //std.debug.print("Result: {d}\n", .{calc_res});
        nums.clearRetainingCapacity();
        while (it.next()) |num_str| {
            try nums.append(try std.fmt.parseInt(u64, num_str, 10));
        }
        if (try solve_equation_p2(calc_res, nums.items)) result += calc_res;
    }
    return result;
}
test "day7" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Calibration result {d} in {d}ms\n", .{ try part1("inputs/day7/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Calibration result concat {d} in {d}ms\n", .{ try part2("inputs/day7/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
