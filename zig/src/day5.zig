const std = @import("std");
// https://adventofcode.com/2024/day/5

// --- Day 5: Print Queue ---
// Satisfied with their search on Ceres, the squadron of scholars suggests subsequently scanning the stationery stacks of sub-basement 17.

// The North Pole printing department is busier than ever this close to Christmas, and while The Historians continue their search of this historically significant facility, an Elf operating a very familiar printer beckons you over.

// The Elf must recognize you, because they waste no time explaining that the new sleigh launch safety manual updates won't print correctly. Failure to update the safety manuals would be dire indeed, so you offer your services.

// Safety protocols clearly indicate that new pages for the safety manuals must be printed in a very specific order. The notation X|Y means that if both page number X and page number Y are to be produced as part of an update, page number X must be printed at some point before page number Y.

// The Elf has for you both the page ordering rules and the pages to produce in each update (your puzzle input), but can't figure out whether each update has the pages in the right order.

// For example:

// 47|53
// 97|13
// 97|61
// 97|47
// 75|29
// 61|13
// 75|53
// 29|13
// 97|29
// 53|29
// 61|53
// 97|53
// 61|29
// 47|13
// 75|47
// 97|75
// 47|61
// 75|61
// 47|29
// 75|13
// 53|13

// 75,47,61,53,29
// 97,61,53,29,13
// 75,29,13
// 75,97,47,61,53
// 61,13,29
// 97,13,75,29,47
// The first section specifies the page ordering rules, one per line. The first rule, 47|53, means that if an update includes both page number 47 and page number 53, then page number 47 must be printed at some point before page number 53. (47 doesn't necessarily need to be immediately before 53; other pages are allowed to be between them.)

// The second section specifies the page numbers of each update. Because most safety manuals are different, the pages needed in the updates are different too. The first update, 75,47,61,53,29, means that the update consists of page numbers 75, 47, 61, 53, and 29.

// To get the printers going as soon as possible, start by identifying which updates are already in the right order.

// In the above example, the first update (75,47,61,53,29) is in the right order:

// 75 is correctly first because there are rules that put each other page after it: 75|47, 75|61, 75|53, and 75|29.
// 47 is correctly second because 75 must be before it (75|47) and every other page must be after it according to 47|61, 47|53, and 47|29.
// 61 is correctly in the middle because 75 and 47 are before it (75|61 and 47|61) and 53 and 29 are after it (61|53 and 61|29).
// 53 is correctly fourth because it is before page number 29 (53|29).
// 29 is the only page left and so is correctly last.
// Because the first update does not include some page numbers, the ordering rules involving those missing page numbers are ignored.

// The second and third updates are also in the correct order according to the rules. Like the first update, they also do not include every page number, and so only some of the ordering rules apply - within each update, the ordering rules that involve missing page numbers are not used.

// The fourth update, 75,97,47,61,53, is not in the correct order: it would print 75 before 97, which violates the rule 97|75.

// The fifth update, 61,13,29, is also not in the correct order, since it breaks the rule 29|13.

// The last update, 97,13,75,29,47, is not in the correct order due to breaking several rules.

// For some reason, the Elves also need to know the middle page number of each update being printed. Because you are currently only printing the correctly-ordered updates, you will need to find the middle page number of each correctly-ordered update. In the above example, the correctly-ordered updates are:

// 75,47,61,53,29
// 97,61,53,29,13
// 75,29,13
// These have middle page numbers of 61, 53, and 29 respectively. Adding these page numbers together gives 143.

// Of course, you'll need to be careful: the actual list of page ordering rules is bigger and more complicated than the above example.

// Determine which updates are already in the correct order. What do you get if you add up the middle page number from those correctly-ordered updates?

pub const Rule = struct {
    x: u8,
    y: u8,
    pub fn init(line: []const u8) !Rule {
        //std.debug.print("line {any}\n", .{line});
        var it = std.mem.tokenizeScalar(u8, line, '|');
        const num1 = it.next().?;
        const num2 = it.next().?;
        //std.debug.print("num1 {s} {d}, num2 {s} {d}\n", .{ num1, num1.len, num2, num2.len });
        return .{
            .x = try std.fmt.parseInt(u8, num1, 10),
            .y = try std.fmt.parseInt(u8, num2, 10),
        };
    }
};

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var pages = std.ArrayList(u8).init(allocator);
    var rules: std.ArrayList(Rule) = std.ArrayList(Rule).init(allocator);
    defer rules.deinit();
    defer pages.deinit();
    var buf: [4096]u8 = undefined;
    var result: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const filtered_line = std.mem.trim(u8, line, "\r");
        if (std.mem.indexOfScalar(u8, filtered_line, '|') != null) {
            try rules.append(try Rule.init(filtered_line));
        } else if (std.mem.indexOfScalar(u8, filtered_line, ',') != null) {
            var passed = true;
            var it = std.mem.tokenizeScalar(u8, filtered_line, ',');
            while (it.next()) |val| {
                try pages.append(try std.fmt.parseInt(u8, val, 10));
            }
            for (rules.items) |rule| {
                var x_indx: ?usize = null;
                var y_indx: ?usize = null;
                for (0..pages.items.len) |i| {
                    if (pages.items[i] == rule.x) {
                        //std.debug.print("found x {d}\n", .{rule.x});
                        x_indx = i;
                    }
                    if (pages.items[i] == rule.y) {
                        //std.debug.print("found y {d}\n", .{rule.y});
                        y_indx = i;
                    }
                    if (x_indx != null and y_indx != null) break;
                }
                if (x_indx != null and y_indx != null) {
                    if (y_indx.? < x_indx.?) {
                        passed = false;
                        break;
                    }
                }
            }
            if (passed) {
                std.debug.print("{s}\n", .{filtered_line});
                result += @as(usize, @intCast(pages.items[@divFloor(pages.items.len, 2)]));
            }
            pages.clearRetainingCapacity();
        }
    }
    return result;
}

// --- Part Two ---
// While the Elves get to work printing the correctly-ordered updates, you have a little time to fix the rest of them.

// For each of the incorrectly-ordered updates, use the page ordering rules to put the page numbers in the right order. For the above example, here are the three incorrectly-ordered updates and their correct orderings:

// 75,97,47,61,53 becomes 97,75,47,61,53.
// 61,13,29 becomes 61,29,13.
// 97,13,75,29,47 becomes 97,75,47,29,13.
// After taking only the incorrectly-ordered updates and ordering them correctly, their middle page numbers are 47, 29, and 47. Adding these together produces 123.

// Find the updates which are not in the correct order. What do you get if you add up the middle page numbers after correctly ordering just those updates?

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var pages = std.ArrayList(u8).init(allocator);
    var rules: std.ArrayList(Rule) = std.ArrayList(Rule).init(allocator);
    defer rules.deinit();
    defer pages.deinit();
    var buf: [4096]u8 = undefined;
    var result: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const filtered_line = std.mem.trim(u8, line, "\r");
        if (std.mem.indexOfScalar(u8, filtered_line, '|') != null) {
            try rules.append(try Rule.init(filtered_line));
        } else if (std.mem.indexOfScalar(u8, filtered_line, ',') != null) {
            var broken_update = false;
            var it = std.mem.tokenizeScalar(u8, filtered_line, ',');
            while (it.next()) |val| {
                try pages.append(try std.fmt.parseInt(u8, val, 10));
            }
            var rule_broke = true;
            while (rule_broke) {
                rule_broke = false;
                for (rules.items) |rule| {
                    var x_indx: ?usize = null;
                    var y_indx: ?usize = null;
                    for (0..pages.items.len) |i| {
                        if (pages.items[i] == rule.x) {
                            //std.debug.print("found x {d}\n", .{rule.x});
                            x_indx = i;
                        }
                        if (pages.items[i] == rule.y) {
                            //std.debug.print("found y {d}\n", .{rule.y});
                            y_indx = i;
                        }
                        if (x_indx != null and y_indx != null) break;
                    }
                    if (x_indx != null and y_indx != null) {
                        if (y_indx.? < x_indx.?) {
                            broken_update = true;
                            //std.debug.print("swapping\n", .{});
                            rule_broke = true;
                            const temp = pages.items[x_indx.?];
                            pages.items[x_indx.?] = pages.items[y_indx.?];
                            pages.items[y_indx.?] = temp;
                        }
                    }
                }
            }
            if (broken_update) {
                std.debug.print("{any}\n", .{pages.items});
                result += @as(usize, @intCast(pages.items[@divFloor(pages.items.len, 2)]));
            }
            pages.clearRetainingCapacity();
        }
    }
    return result;
}
test "day5" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    std.debug.print("Correct page number total {d}\n", .{try part1("inputs/day5/input.txt", allocator)});
    std.debug.print("Correct page number total {d}\n", .{try part2("inputs/day5/input.txt", allocator)});
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
