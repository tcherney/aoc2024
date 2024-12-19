const std = @import("std");
// https://adventofcode.com/2024/day/18

// --- Day 19: Linen Layout ---
// Today, The Historians take you up to the hot springs on Gear Island! Very suspiciously, absolutely nothing goes wrong as they begin their careful search of the vast field of helixes.

// Could this finally be your chance to visit the onsen next door? Only one way to find out.

// After a brief conversation with the reception staff at the onsen front desk, you discover that you don't have the right kind of money to pay the admission fee. However, before you can leave, the staff get your attention. Apparently, they've heard about how you helped at the hot springs, and they're willing to make a deal: if you can simply help them arrange their towels, they'll let you in for free!

// Every towel at this onsen is marked with a pattern of colored stripes. There are only a few patterns, but for any particular pattern, the staff can get you as many towels with that pattern as you need. Each stripe can be white (w), blue (u), black (b), red (r), or green (g). So, a towel with the pattern ggr would have a green stripe, a green stripe, and then a red stripe, in that order. (You can't reverse a pattern by flipping a towel upside-down, as that would cause the onsen logo to face the wrong way.)

// The Official Onsen Branding Expert has produced a list of designs - each a long sequence of stripe colors - that they would like to be able to display. You can use any towels you want, but all of the towels' stripes must exactly match the desired design. So, to display the design rgrgr, you could use two rg towels and then an r towel, an rgr towel and then a gr towel, or even a single massive rgrgr towel (assuming such towel patterns were actually available).

// To start, collect together all of the available towel patterns and the list of desired designs (your puzzle input). For example:

// r, wr, b, g, bwu, rb, gb, br

// brwrr
// bggr
// gbbr
// rrbgbr
// ubwu
// bwurrg
// brgr
// bbrgwb
// The first line indicates the available towel patterns; in this example, the onsen has unlimited towels with a single red stripe (r), unlimited towels with a white stripe and then a red stripe (wr), and so on.

// After the blank line, the remaining lines each describe a design the onsen would like to be able to display. In this example, the first design (brwrr) indicates that the onsen would like to be able to display a black stripe, a red stripe, a white stripe, and then two red stripes, in that order.

// Not all designs will be possible with the available towels. In the above example, the designs are possible or impossible as follows:

// brwrr can be made with a br towel, then a wr towel, and then finally an r towel.
// bggr can be made with a b towel, two g towels, and then an r towel.
// gbbr can be made with a gb towel and then a br towel.
// rrbgbr can be made with r, rb, g, and br.
// ubwu is impossible.
// bwurrg can be made with bwu, r, r, and g.
// brgr can be made with br, g, and r.
// bbrgwb is impossible.
// In this example, 6 of the eight designs are possible with the available towel patterns.

// To get into the onsen as soon as possible, consult your list of towel patterns and desired designs carefully. How many designs are possible?
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
var num_buf: [1024]u8 = undefined;
var scratch_str: std.ArrayList(u8) = undefined;
const DEBUG = false;

pub fn largest_string(context: void, lhs: std.ArrayList(u8), rhs: std.ArrayList(u8)) bool {
    _ = context;
    return lhs.items.len > rhs.items.len;
}
var solve_cache: std.StringHashMap(bool) = undefined;
pub fn solve_rec(patterns: std.ArrayList(std.ArrayList(u8)), design: []u8) !bool {
    if (design.len == 0) return true;
    if (solve_cache.contains(design)) {
        return solve_cache.get(design).?;
    }
    for (0..patterns.items.len) |i| {
        //std.debug.print("{d} {s}\n", .{ i, design });
        if (patterns.items[i].items.len <= design.len and std.mem.eql(u8, patterns.items[i].items, design[0..patterns.items[i].items.len])) {
            if (patterns.items[i].items.len == design.len) return true;
            //std.debug.print("matched pattern {s} on {s}, string is now {s}\n", .{ patterns.items[i].items, design, design[patterns.items[i].items.len..] });
            const result = try solve_rec(patterns, design[patterns.items[i].items.len..]);
            try solve_cache.put(design[patterns.items[i].items.len..], result);
            if (result) return result;
        }
    }
    //std.debug.print("return false\n", .{});
    return false;
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var patterns = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var designs = std.ArrayList(std.ArrayList(u8)).init(allocator);
    //patterns
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        var it = std.mem.splitAny(u8, line, ", ");
        while (it.next()) |design| {
            if (design.len == 0) continue;
            try patterns.append(std.ArrayList(u8).init(allocator));
            _ = try patterns.items[patterns.items.len - 1].writer().write(design);
        }
    }
    //designs
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        try designs.append(std.ArrayList(u8).init(allocator));
        _ = try designs.items[designs.items.len - 1].writer().write(line);
    }
    std.mem.sort(std.ArrayList(u8), patterns.items, {}, largest_string);
    std.debug.print("Patterns\n", .{});
    for (0..patterns.items.len) |i| {
        std.debug.print("{s} len {d}\n", .{ patterns.items[i].items, patterns.items[i].items.len });
    }
    std.debug.print("Designs\n", .{});
    for (0..designs.items.len) |i| {
        std.debug.print("{s} len {d}\n", .{ designs.items[i].items, designs.items[i].items.len });
    }
    solve_cache = std.StringHashMap(bool).init(allocator);
    defer solve_cache.deinit();
    var total_possible: u64 = 0;
    for (0..designs.items.len) |i| {
        if (try solve_rec(patterns, designs.items[i].items)) {
            total_possible += 1;
        }
        //std.debug.print("total_possible {d}\n", .{total_possible});
    }

    for (0..patterns.items.len) |i| {
        patterns.items[i].deinit();
    }
    patterns.deinit();
    for (0..designs.items.len) |i| {
        designs.items[i].deinit();
    }
    designs.deinit();

    return total_possible;
}

// --- Part Two ---
// The staff don't really like some of the towel arrangements you came up with. To avoid an endless cycle of towel rearrangement, maybe you should just give them every possible option.

// Here are all of the different ways the above example's designs can be made:

// brwrr can be made in two different ways: b, r, wr, r or br, wr, r.

// bggr can only be made with b, g, g, and r.

// gbbr can be made 4 different ways:

// g, b, b, r
// g, b, br
// gb, b, r
// gb, br
// rrbgbr can be made 6 different ways:

// r, r, b, g, b, r
// r, r, b, g, br
// r, r, b, gb, r
// r, rb, g, b, r
// r, rb, g, br
// r, rb, gb, r
// bwurrg can only be made with bwu, r, r, and g.

// brgr can be made in two different ways: b, r, g, r or br, g, r.

// ubwu and bbrgwb are still impossible.

// Adding up all of the ways the towels in this example could be arranged into the desired designs yields 16 (2 + 1 + 4 + 6 + 1 + 2).

// They'll let you into the onsen as soon as you have the list. What do you get if you add up the number of different ways you could make each design?
var solve_arrangements_cache: std.StringHashMap(u64) = undefined;
pub fn solve_arrangements_rec(patterns: std.ArrayList(std.ArrayList(u8)), design: []u8) !u64 {
    if (design.len == 0) return 1;
    if (solve_arrangements_cache.contains(design)) {
        return solve_arrangements_cache.get(design).?;
    }
    var count: u64 = 0;
    for (0..patterns.items.len) |i| {
        //std.debug.print("{d} {s}\n", .{ i, design });
        if (patterns.items[i].items.len <= design.len and std.mem.eql(u8, patterns.items[i].items, design[0..patterns.items[i].items.len])) {
            //if (patterns.items[i].items.len == design.len) return 1;
            //std.debug.print("matched pattern {s} on {s}, string is now {s}\n", .{ patterns.items[i].items, design, design[patterns.items[i].items.len..] });
            const result = try solve_arrangements_rec(patterns, design[patterns.items[i].items.len..]);
            try solve_arrangements_cache.put(design[patterns.items[i].items.len..], result);
            count += result;
        }
    }
    //std.debug.print("return false\n", .{});
    return count;
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var patterns = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var designs = std.ArrayList(std.ArrayList(u8)).init(allocator);
    //patterns
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        var it = std.mem.splitAny(u8, line, ", ");
        while (it.next()) |design| {
            if (design.len == 0) continue;
            try patterns.append(std.ArrayList(u8).init(allocator));
            _ = try patterns.items[patterns.items.len - 1].writer().write(design);
        }
    }
    //designs
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        try designs.append(std.ArrayList(u8).init(allocator));
        _ = try designs.items[designs.items.len - 1].writer().write(line);
    }
    std.mem.sort(std.ArrayList(u8), patterns.items, {}, largest_string);
    std.debug.print("Patterns\n", .{});
    for (0..patterns.items.len) |i| {
        std.debug.print("{s} len {d}\n", .{ patterns.items[i].items, patterns.items[i].items.len });
    }
    std.debug.print("Designs\n", .{});
    for (0..designs.items.len) |i| {
        std.debug.print("{s} len {d}\n", .{ designs.items[i].items, designs.items[i].items.len });
    }
    solve_arrangements_cache = std.StringHashMap(u64).init(allocator);
    defer solve_arrangements_cache.deinit();
    var total_possible: u64 = 0;
    for (0..designs.items.len) |i| {
        total_possible += try solve_arrangements_rec(patterns, designs.items[i].items);
        //std.debug.print("total_possible {d}\n", .{total_possible});
    }

    for (0..patterns.items.len) |i| {
        patterns.items[i].deinit();
    }
    patterns.deinit();
    for (0..designs.items.len) |i| {
        designs.items[i].deinit();
    }
    designs.deinit();

    return total_possible;
}

test "day19" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Designs possible {d} in {d}ms\n", .{ try part1("../inputs/day19/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Designs possible {d} in {d}ms\n", .{ try part2("../inputs/day19/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
