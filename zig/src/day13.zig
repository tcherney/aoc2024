const std = @import("std");
// https://adventofcode.com/2024/day/13
// here are a little unusual. Instead of a joystick or directional buttons to control the claw, these machines have two buttons labeled A and B. Worse, you can't just put in a token and play; it costs 3 tokens to push the A button and 1 token to push the B button.

// With a little experimentation, you figure out that each machine's buttons are configured to move the claw a specific amount to the right (along the X axis) and a specific amount forward (along the Y axis) each time that button is pressed.

// Each machine contains one prize; to win the prize, the claw must be positioned exactly above the prize on both the X and Y axes.

// You wonder: what is the smallest number of tokens you would have to spend to win as many prizes as possible? You assemble a list of every machine's button behavior and prize location (your puzzle input). For example:

// Button A: X+94, Y+34
// Button B: X+22, Y+67
// Prize: X=8400, Y=5400

// Button A: X+26, Y+66
// Button B: X+67, Y+21
// Prize: X=12748, Y=12176

// Button A: X+17, Y+86
// Button B: X+84, Y+37
// Prize: X=7870, Y=6450

// Button A: X+69, Y+23
// Button B: X+27, Y+71
// Prize: X=18641, Y=10279
// This list describes the button configuration and prize location of four different claw machines.

// For now, consider just the first claw machine in the list:

// Pushing the machine's A button would move the claw 94 units along the X axis and 34 units along the Y axis.
// Pushing the B button would move the claw 22 units along the X axis and 67 units along the Y axis.
// The prize is located at X=8400, Y=5400; this means that from the claw's initial position, it would need to move exactly 8400 units along the X axis and exactly 5400 units along the Y axis to be perfectly aligned with the prize in this machine.
// The cheapest way to win the prize is by pushing the A button 80 times and the B button 40 times. This would line up the claw along the X axis (because 80*94 + 40*22 = 8400) and along the Y axis (because 80*34 + 40*67 = 5400). Doing this would cost 80*3 tokens for the A presses and 40*1 for the B presses, a total of 280 tokens.

// For the second and fourth claw machines, there is no combination of A and B presses that will ever win a prize.

// For the third claw machine, the cheapest way to win the prize is by pushing the A button 38 times and the B button 86 times. Doing this would cost a total of 200 tokens.

// So, the most prizes you could possibly win is two; the minimum tokens you would have to spend to win all (two) prizes is 480.

// You estimate that each button would need to be pressed no more than 100 times to win a prize. How else would someone be expected to play?

// Figure out how to win as many prizes as possible. What is the fewest tokens you would have to spend to win all possible prizes?

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

pub const Button = struct {
    x: i64,
    y: i64,
    cost: i64,
};
pub const Goal = struct { x: i64, y: i64 };
pub fn dumb_search(problem: *Problem) i64 {
    for (0..100) |a| {
        for (0..100) |b| {
            if (@as(i64, @bitCast(a)) * problem.button_a.x + @as(i64, @bitCast(b)) * problem.button_b.x == problem.goal.x and @as(i64, @bitCast(a)) * problem.button_a.y + @as(i64, @bitCast(b)) * problem.button_b.y == problem.goal.y) {
                return 3 * @as(i64, @bitCast(a)) + @as(i64, @bitCast(b));
            }
        }
    }
    return 0;
}
pub fn dumber_search(problem: *Problem) i64 {
    var x_max = @divFloor(problem.goal.x, problem.button_a.x);
    var y_max = @divFloor(problem.goal.y, problem.button_a.y);
    const A_CAP = @as(u64, @bitCast(if (x_max > y_max) x_max else y_max));
    x_max = @divFloor(problem.goal.x, problem.button_b.x);
    y_max = @divFloor(problem.goal.y, problem.button_b.y);
    const B_CAP = @as(u64, @bitCast(if (x_max > y_max) x_max else y_max));
    std.debug.print("A_CAP {d} B_CAP {d}\n", .{ A_CAP, B_CAP });
    for (0..A_CAP) |a| {
        for (0..B_CAP) |b| {
            if (@as(i64, @bitCast(a)) * problem.button_a.x + @as(i64, @bitCast(b)) * problem.button_b.x == problem.goal.x and @as(i64, @bitCast(a)) * problem.button_a.y + @as(i64, @bitCast(b)) * problem.button_b.y == problem.goal.y) {
                return 3 * @as(i64, @bitCast(a)) + @as(i64, @bitCast(b));
            }
        }
    }
    return 0;
}

pub const Equation = struct {
    a: i64,
    b: i64,
    ans: i64,
};

pub fn linear_equation(problem: *Problem) i64 {
    var eq1 = Equation{
        .a = problem.button_a.x,
        .b = problem.button_b.x,
        .ans = problem.goal.x,
    };
    var eq2 = Equation{
        .a = problem.button_a.y,
        .b = problem.button_b.y,
        .ans = problem.goal.y,
    };
    const eq1_mul: i64 = eq2.b;
    const eq2_mul: i64 = eq1.b;
    eq1.a *= eq1_mul;
    eq1.b *= eq1_mul;
    eq1.ans *= eq1_mul;

    eq2.a *= eq2_mul;
    eq2.b *= eq2_mul;
    eq2.ans *= eq2_mul;

    var eq_a = Equation{
        .a = eq1.a - eq2.a,
        .b = eq1.b - eq2.b,
        .ans = eq1.ans - eq2.ans,
    };
    if (@mod(eq_a.ans, eq_a.a) != 0) return 0;
    eq_a.a = @divFloor(eq_a.ans, eq_a.a);
    var eq_b = Equation{
        .a = problem.button_a.x,
        .b = problem.button_b.x,
        .ans = problem.goal.x,
    };
    eq_b.a *= eq_a.a;
    eq_b.ans -= eq_b.a;
    if (@mod(eq_b.ans, eq_b.b) != 0) return 0;
    eq_b.b = @divFloor(eq_b.ans, eq_b.b);
    return 3 * eq_a.a + eq_b.b;
}
pub const Problem = struct {
    button_a: Button = undefined,
    button_b: Button = undefined,
    goal: Goal = undefined,
    cost: u64 = undefined,
};
var num_buf: [1024]u8 = undefined;
pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var problems = std.ArrayList(Problem).init(allocator);
    defer problems.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        std.debug.print("processing line {s}\n", .{line});
        const start_a = std.mem.indexOf(u8, line, "Button A:");
        if (start_a) |_| {
            const x_start = std.mem.indexOfScalar(u8, line, '+').?;
            const x_end = std.mem.indexOfScalarPos(u8, line, x_start, ',').?;
            const y_start = std.mem.indexOfScalarPos(u8, line, x_end, '+').?;
            const y_end = line.len;
            try problems.append(Problem{ .button_a = Button{ .x = try std.fmt.parseInt(i64, line[x_start + 1 .. x_end], 10), .y = try std.fmt.parseInt(i64, line[y_start + 1 .. y_end], 10), .cost = 3 } });
        }
        const start_b = std.mem.indexOf(u8, line, "Button B:");
        if (start_b) |_| {
            const x_start = std.mem.indexOfScalar(u8, line, '+').?;
            const x_end = std.mem.indexOfScalarPos(u8, line, x_start, ',').?;
            const y_start = std.mem.indexOfScalarPos(u8, line, x_end, '+').?;
            const y_end = line.len;
            problems.items[problems.items.len - 1].button_b = Button{ .x = try std.fmt.parseInt(i64, line[x_start + 1 .. x_end], 10), .y = try std.fmt.parseInt(i64, line[y_start + 1 .. y_end], 10), .cost = 1 };
        }
        const start_prize = std.mem.indexOf(u8, line, "Prize");
        if (start_prize) |_| {
            const x_start = std.mem.indexOfScalar(u8, line, '=').?;
            const x_end = std.mem.indexOfScalarPos(u8, line, x_start, ',').?;
            const y_start = std.mem.indexOfScalarPos(u8, line, x_end, '=').?;
            const y_end = line.len;
            problems.items[problems.items.len - 1].goal = Goal{ .x = try std.fmt.parseInt(i64, line[x_start + 1 .. x_end], 10), .y = try std.fmt.parseInt(i64, line[y_start + 1 .. y_end], 10) };
        }
    }
    for (0..problems.items.len) |i| {
        std.debug.print("Problem {any}\n", .{problems.items[i]});
    }
    var result: u64 = 0;
    for (0..problems.items.len) |i| {
        result += @as(u64, @bitCast(dumb_search(&problems.items[i])));
    }
    return result;
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var problems = std.ArrayList(Problem).init(allocator);
    defer problems.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        //std.debug.print("processing line {s}\n", .{line});
        const start_a = std.mem.indexOf(u8, line, "Button A:");
        if (start_a) |_| {
            const x_start = std.mem.indexOfScalar(u8, line, '+').?;
            const x_end = std.mem.indexOfScalarPos(u8, line, x_start, ',').?;
            const y_start = std.mem.indexOfScalarPos(u8, line, x_end, '+').?;
            const y_end = line.len;
            try problems.append(Problem{ .button_a = Button{ .x = try std.fmt.parseInt(i64, line[x_start + 1 .. x_end], 10), .y = try std.fmt.parseInt(i64, line[y_start + 1 .. y_end], 10), .cost = 3 } });
        }
        const start_b = std.mem.indexOf(u8, line, "Button B:");
        if (start_b) |_| {
            const x_start = std.mem.indexOfScalar(u8, line, '+').?;
            const x_end = std.mem.indexOfScalarPos(u8, line, x_start, ',').?;
            const y_start = std.mem.indexOfScalarPos(u8, line, x_end, '+').?;
            const y_end = line.len;
            problems.items[problems.items.len - 1].button_b = Button{ .x = try std.fmt.parseInt(i64, line[x_start + 1 .. x_end], 10), .y = try std.fmt.parseInt(i64, line[y_start + 1 .. y_end], 10), .cost = 1 };
        }
        const start_prize = std.mem.indexOf(u8, line, "Prize");
        if (start_prize) |_| {
            const x_start = std.mem.indexOfScalar(u8, line, '=').?;
            const x_end = std.mem.indexOfScalarPos(u8, line, x_start, ',').?;
            const y_start = std.mem.indexOfScalarPos(u8, line, x_end, '=').?;
            const y_end = line.len;
            problems.items[problems.items.len - 1].goal = Goal{ .x = try std.fmt.parseInt(i64, line[x_start + 1 .. x_end], 10) + 10000000000000, .y = try std.fmt.parseInt(i64, line[y_start + 1 .. y_end], 10) + 10000000000000 };
        }
    }
    // for (0..problems.items.len) |i| {
    //     std.debug.print("Problem {any}\n", .{problems.items[i]});
    // }
    var result: u64 = 0;
    for (0..problems.items.len) |i| {
        result += @as(u64, @bitCast(linear_equation(&problems.items[i])));
    }
    return result;
}
test "day13" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Number of tokens {d} in {d}ms\n", .{ try part1("inputs/day13/test.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Number of tokens {d} in {d}ms\n", .{ try part2("inputs/day13/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
