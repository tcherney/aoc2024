const std = @import("std");
// https://adventofcode.com/2024/day/3

// --- Day 3: Mull It Over ---
// "Our computers are having issues, so I have no idea if we have any Chief Historians in stock! You're welcome to check the warehouse, though," says the mildly flustered shopkeeper at the North Pole Toboggan Rental Shop. The Historians head out to take a look.

// The shopkeeper turns to you. "Any chance you can see why our computers are having issues again?"

// The computer appears to be trying to run a program, but its memory (your puzzle input) is corrupted. All of the instructions have been jumbled up!

// It seems like the goal of the program is just to multiply some numbers. It does that with instructions like mul(X,Y), where X and Y are each 1-3 digit numbers. For instance, mul(44,46) multiplies 44 by 46 to get a result of 2024. Similarly, mul(123,4) would multiply 123 by 4.

// However, because the program's memory has been corrupted, there are also many invalid characters that should be ignored, even if they look like part of a mul instruction. Sequences like mul(4*, mul(6,9!, ?(12,34), or mul ( 2 , 4 ) do nothing.

// For example, consider the following section of corrupted memory:

// xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
// Only the four highlighted sections are real mul instructions. Adding up the result of each instruction produces 161 (2*4 + 5*5 + 11*8 + 8*5).

// Scan the corrupted memory for uncorrupted mul instructions. What do you get if you add up all of the results of the multiplications?

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var first_num_string = std.ArrayList(u8).init(allocator);
    var second_num_string = std.ArrayList(u8).init(allocator);
    defer first_num_string.deinit();
    defer second_num_string.deinit();
    var buf: [4096]u8 = undefined;
    var result: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_index: u64 = 0;
        while (std.mem.indexOfPos(u8, line, line_index, "mul(")) |indx| {
            //std.debug.print("found at {any}\n", .{indx});
            defer first_num_string.clearRetainingCapacity();
            defer second_num_string.clearRetainingCapacity();
            line_index = indx + 4;
            while (line[line_index] >= 48 and line[line_index] <= 57) {
                //std.debug.print("adding {c} to first num\n", .{line[line_index]});
                try first_num_string.append(line[line_index]);
                line_index += 1;
            }
            //std.debug.print("next char {c}\n", .{line[line_index]});
            if (line[line_index] != ',') continue;
            line_index += 1;
            while (line[line_index] >= 48 and line[line_index] <= 57) {
                //std.debug.print("adding {c} to second num\n", .{line[line_index]});
                try second_num_string.append(line[line_index]);
                line_index += 1;
            }
            if (line[line_index] != ')') continue;
            line_index += 1;
            const first_num = try std.fmt.parseInt(u64, first_num_string.items, 10);
            const second_num = try std.fmt.parseInt(u64, second_num_string.items, 10);
            result += first_num * second_num;
            std.debug.print("mul({d},{d})\n", .{ first_num, second_num });
        }
    }

    return result;
}

// --- Part Two ---
// As you scan through the corrupted memory, you notice that some of the conditional statements are also still intact. If you handle some of the uncorrupted conditional statements in the program, you might be able to get an even more accurate result.

// There are two new instructions you'll need to handle:

// The do() instruction enables future mul instructions.
// The don't() instruction disables future mul instructions.
// Only the most recent do() or don't() instruction applies. At the beginning of the program, mul instructions are enabled.

// For example:

// xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
// This corrupted memory is similar to the example from before, but this time the mul(5,5) and mul(11,8) instructions are disabled because there is a don't() instruction before them. The other mul instructions function normally, including the one at the end that gets re-enabled by a do() instruction.

// This time, the sum of the results is 48 (2*4 + 8*5).

// Handle the new instructions; what do you get if you add up all of the results of just the enabled multiplications?
pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = file_name;
    _ = allocator;
}
test "day3" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    std.debug.print("Multiplication result {d}\n", .{try part1("inputs/day3/input.txt", allocator)});
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
