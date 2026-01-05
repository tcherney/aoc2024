// --- Day 6: Trash Compactor ---
// After helping the Elves in the kitchen, you were taking a break and helping them re-enact a movie scene when you over-enthusiastically jumped into the garbage chute!

// A brief fall later, you find yourself in a garbage smasher. Unfortunately, the door's been magnetically sealed.

// As you try to find a way out, you are approached by a family of cephalopods! They're pretty sure they can get the door open, but it will take some time. While you wait, they're curious if you can help the youngest cephalopod with her math homework.

// Cephalopod math doesn't look that different from normal math. The math worksheet (your puzzle input) consists of a list of problems; each problem has a group of numbers that need to either be either added (+) or multiplied (*) together.

// However, the problems are arranged a little strangely; they seem to be presented next to each other in a very long horizontal list. For example:

// 123 328  51 64
//  45 64  387 23
//   6 98  215 314
// *   +   *   +
// Each problem's numbers are arranged vertically; at the bottom of the problem is the symbol for the operation that needs to be performed. Problems are separated by a full column of only spaces. The left/right alignment of numbers within each problem can be ignored.

// So, this worksheet contains four problems:

// 123 * 45 * 6 = 33210
// 328 + 64 + 98 = 490
// 51 * 387 * 215 = 4243455
// 64 + 23 + 314 = 401
// To check their work, cephalopod students are given the grand total of adding together all of the answers to the individual problems. In this worksheet, the grand total is 33210 + 490 + 4243455 + 401 = 4277556.

// Of course, the actual worksheet is much wider. You'll need to make sure to unroll it completely so that you can read the problems clearly.

// Solve the problems on the math worksheet. What is the grand total found by adding together all of the answers to the individual problems?

// --- Part Two ---
// The big cephalopods come back to check on how things are going. When they see that your grand total doesn't match the one expected by the worksheet, they realize they forgot to explain how to read cephalopod math.

// Cephalopod math is written right-to-left in columns. Each number is given in its own column, with the most significant digit at the top and the least significant digit at the bottom. (Problems are still separated with a column consisting only of spaces, and the symbol at the bottom of the problem is still the operator to use.)

// Reading the problems right-to-left one column at a time, the problems are now quite different:

// The rightmost problem is 4 + 431 + 623 = 1058
// The second problem from the right is 175 * 581 * 32 = 3253600
// The third problem from the right is 8 + 248 + 369 = 625
// Finally, the leftmost problem is 356 * 24 * 1 = 8544
// Now, the grand total is 1058 + 3253600 + 625 + 8544 = 3263827.

// Solve the problems on the math worksheet again. What is the grand total found by adding together all of the answers to the individual problems?

const std = @import("std");
const common = @import("common");

var scratch_buffer: [1024]u8 = undefined;
pub fn on_render(self: anytype) !void {
    //TODO highlight probblems as they are solved
    const str = try std.fmt.bufPrint(&scratch_buffer, "Day 6\nPart 1: {d}\nPart 2: {d}", .{ part1, part2 });
    self.e.renderer.ascii.draw_text(str, 5, 0, common.Colors.GREEN, self.window);
}

pub fn deinit(_: anytype) void {
    if (state != .init) {
        for (0..problems.items.len) |i| {
            problems.items[i].deinit();
        }
        problems.deinit();
        full_input.deinit();
    }
}

pub fn update(self: anytype) !void {
    switch (state) {
        .init => {
            try init(self);
        },
        .part1 => {
            try day6_p1();
        },
        .part2 => {
            try day6_p2();
        },
        else => {},
    }
}

pub fn init(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day6/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    problems = std.ArrayList(Problem).init(self.allocator);
    full_input = std.ArrayList(u8).init(self.allocator);
    var col: usize = 0;
    var row: usize = 0;
    h = 0;
    w = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        try full_input.writer().print("{s}", .{line});
        w = line.len;
        var tokens = std.mem.splitScalar(u8, line, ' ');
        while (tokens.next()) |t| {
            if (t.len == 0) continue;
            if (row == 0) {
                try problems.append(Problem.init(self.allocator));
            }
            if (t[0] == '*') {
                problems.items[col].operation = .Mult;
            } else if (t[0] == '+') {
                problems.items[col].operation = .Add;
            }
            col += 1;
        }
        row += 1;
        col = 0;
    }
    h = row - 1;
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
var h: usize = 0;
var w: usize = 0;
var problems: std.ArrayList(Problem) = undefined;
var full_input: std.ArrayList(u8) = undefined;

pub const Problem = struct {
    numbers: std.ArrayList(usize),
    operation: ?Operation,

    pub const Operation = enum { Mult, Add };
    pub fn init(allocator: std.mem.Allocator) Problem {
        return .{
            .numbers = std.ArrayList(usize).init(allocator),
            .operation = null,
        };
    }

    pub fn set_operation(self: *Problem, operation: Operation) void {
        self.operation = operation;
    }

    pub fn deinit(self: *Problem) void {
        self.numbers.deinit();
    }

    pub fn compute(self: *const Problem) usize {
        var total: usize = if (self.operation.? == .Add) 0 else 1;
        for (self.numbers.items) |i| {
            switch (self.operation.?) {
                .Mult => {
                    total *= i;
                },
                .Add => {
                    total += i;
                },
            }
        }
        return total;
    }
};

pub fn create_numbers() !void {
    var curr_problem: usize = 0;
    for (0..w) |j| {
        var n: usize = 0;
        var exists: bool = false;
        std.debug.print("------\n", .{});
        var num_digits: usize = 0;
        var digits: [4]usize = [_]usize{0} ** 4;
        for (0..h) |i| {
            std.debug.print("{c}\n", .{full_input.items[i * w + j]});
            if (full_input.items[i * w + j] != ' ') {
                exists = true;
                digits[i] = (full_input.items[i * w + j] - 48);
                num_digits += 1;
            }
        }
        if (exists) {
            for (0..4) |i| {
                if (digits[i] != 0) {
                    n += digits[i] * std.math.pow(usize, 10, num_digits - 1);
                    num_digits -= 1;
                }
            }
            std.debug.print("Adding number: {d}\n", .{n});
            try problems.items[curr_problem].numbers.append(n);
        } else {
            curr_problem += 1;
        }
    }
}

pub fn day6_p2() !void {
    part2 = 0;
    std.debug.print("Full input w:{d} h:{d}\n{s}\n", .{ w, h, full_input.items });
    std.debug.print("Problems\n", .{});
    try create_numbers();
    for (problems.items) |*p| {
        for (p.numbers.items) |n| {
            std.debug.print("{d} ", .{n});
        }
        part2 += p.compute();
        std.debug.print("{any}\n", .{p.operation});
    }
    std.debug.print("Grand total: {d}\n", .{part2});
}

pub fn day6_p1() !void {
    part1 = 0;
    std.debug.print("Problems\n", .{});
    for (problems.items) |p| {
        for (p.numbers.items) |n| {
            std.debug.print("{d} ", .{n});
        }
        part1 += p.compute();
        std.debug.print("{any}\n", .{p.operation});
    }
    std.debug.print("Grand total: {d}\n", .{part1});
}
