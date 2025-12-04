// --- Day 3: Lobby ---
// You descend a short staircase, enter the surprisingly vast lobby, and are quickly cleared by the security checkpoint. When you get to the main elevators, however, you discover that each one has a red light above it: they're all offline.

// "Sorry about that," an Elf apologizes as she tinkers with a nearby control panel. "Some kind of electrical surge seems to have fried them. I'll try to get them online soon."

// You explain your need to get further underground. "Well, you could at least take the escalator down to the printing department, not that you'd get much further than that without the elevators working. That is, you could if the escalator weren't also offline."

// "But, don't worry! It's not fried; it just needs power. Maybe you can get it running while I keep working on the elevators."

// There are batteries nearby that can supply emergency power to the escalator for just such an occasion. The batteries are each labeled with their joltage rating, a value from 1 to 9. You make a note of their joltage ratings (your puzzle input). For example:

// 987654321111111
// 811111111111119
// 234234234234278
// 818181911112111
// The batteries are arranged into banks; each line of digits in your input corresponds to a single bank of batteries. Within each bank, you need to turn on exactly two batteries; the joltage that the bank produces is equal to the number formed by the digits on the batteries you've turned on. For example, if you have a bank like 12345 and you turn on batteries 2 and 4, the bank would produce 24 jolts. (You cannot rearrange batteries.)

// You'll need to find the largest possible joltage each bank can produce. In the above example:

// In 987654321111111, you can make the largest joltage possible, 98, by turning on the first two batteries.
// In 811111111111119, you can make the largest joltage possible by turning on the batteries labeled 8 and 9, producing 89 jolts.
// In 234234234234278, you can make 78 by turning on the last two batteries (marked 7 and 8).
// In 818181911112111, the largest joltage you can produce is 92.
// The total output joltage is the sum of the maximum joltage from each bank, so in this example, the total output joltage is 98 + 89 + 78 + 92 = 357.

// There are many batteries in front of you. Find the maximum joltage possible from each bank; what is the total output joltage?

const std = @import("std");
pub fn day3(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day1/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var cmds = std.ArrayList(i32).init(self.allocator);
    defer cmds.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        const modifier: i32 = if (line[0] == 'L') -1 else 1;
        line = line[1..];
        try cmds.append(try std.fmt.parseInt(i32, line, 10) * modifier);
    }
    // std.debug.print("{any}\n", .{cmds.items.len});
    // for (0..cmds.items.len) |i| {
    //     std.debug.print("{any}\n", .{cmds.items[i]});
    // }
    var current_rot: i32 = 50;
    var zero_cnt: i32 = 0;
    var part1: i32 = 0;
    for (cmds.items) |n| {
        const start_rot = current_rot;
        current_rot = @mod(current_rot + n, 100);
        if (current_rot == 0) {
            zero_cnt += 1;
            part1 += 1;
        } else if (n < 0 and current_rot > start_rot and start_rot != 0) {
            zero_cnt += 1;
        } else if (n > 0 and current_rot < start_rot and start_rot != 0) {
            zero_cnt += 1;
        }
        if (n >= 100) {
            zero_cnt += @divFloor(n, 100);
        } else if (n <= -100) {
            zero_cnt += @divFloor(n, -100);
        }
        //std.debug.print("{any} {any} {any} {any}\n", .{ n, start_rot, current_rot, zero_cnt });
    }
    std.debug.print("Password for part 1 {d}\nPassword for part 2 {d}\n", .{ part1, zero_cnt });
}
