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

pub fn update_and_clear(arr: []usize, i: usize, val: usize) void {
    arr[i] = val;
    for (i + 1..arr.len) |j| {
        arr[j] = 0;
    }
    //std.debug.print("{any}\n", .{arr});
}

pub fn calc_largest(arr: []usize) usize {
    var total: usize = 0;
    for (0..12) |i| {
        total += std.math.pow(usize, 10, i) * arr[11 - i];
    }
    return total;
}

pub fn day3_p2(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day3/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var banks = std.ArrayList(std.ArrayList(usize)).init(self.allocator);
    defer banks.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        try banks.append(std.ArrayList(usize).init(self.allocator));
        for (line) |c| {
            try banks.items[banks.items.len - 1].append(c - 48);
        }
    }
    std.debug.print("Banks\n", .{});
    for (0..banks.items.len) |i| {
        for (0..banks.items[i].items.len) |j| {
            std.debug.print("{d}", .{banks.items[i].items[j]});
        }
        std.debug.print("\n", .{});
    }

    var total: usize = 0;
    for (0..banks.items.len) |i| {
        var highest: [12]usize = [_]usize{0} ** 12;
        const bank_len = banks.items[i].items.len;
        for (0..banks.items[i].items.len) |j| {
            const jolt = banks.items[i].items[j];
            for (0..12) |k| {
                //std.debug.print("{d} > {d} and {d} < {d} - (12 - {d} - 1)\n", .{ jolt, highest[k], j, bank_len, k });
                if (jolt > highest[k] and j < bank_len - (12 - k - 1)) {
                    update_and_clear(&highest, k, jolt);
                    break;
                }
            }
        }
        const largest = calc_largest(&highest);
        std.debug.print("{d}: {d}\n", .{ i, largest });
        total += largest;
    }
    std.debug.print("Total joltage: {d}\n", .{total});

    for (0..banks.items.len) |i| {
        banks.items[i].deinit();
    }
}
pub fn day3_p1(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day3/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var banks = std.ArrayList(std.ArrayList(usize)).init(self.allocator);
    defer banks.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        try banks.append(std.ArrayList(usize).init(self.allocator));
        for (line) |c| {
            try banks.items[banks.items.len - 1].append(c - 48);
        }
    }
    std.debug.print("Banks\n", .{});
    for (0..banks.items.len) |i| {
        for (0..banks.items[i].items.len) |j| {
            std.debug.print("{d}", .{banks.items[i].items[j]});
        }
        std.debug.print("\n", .{});
    }

    var total: usize = 0;
    for (0..banks.items.len) |i| {
        var first: usize = 0;
        var second: usize = 0;
        for (0..banks.items[i].items.len) |j| {
            const jolt = banks.items[i].items[j];
            if (jolt > first and j < banks.items[i].items.len - 1) {
                first = jolt;
                second = 0;
            } else if (jolt > second) {
                second = jolt;
            }
        }
        const largest = first * 10 + second;
        std.debug.print("{d}\n", .{largest});
        total += largest;
    }
    std.debug.print("Total joltage: {d}\n", .{total});

    for (0..banks.items.len) |i| {
        banks.items[i].deinit();
    }
}
