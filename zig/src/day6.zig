const std = @import("std");
// https://adventofcode.com/2024/day/6
// --- Day 6: Guard Gallivant ---
// The Historians use their fancy device again, this time to whisk you all away to the North Pole prototype suit manufacturing lab... in the year 1518! It turns out that having direct access to history is very convenient for a group of historians.

// You still have to be careful of time paradoxes, and so it will be important to avoid anyone from 1518 while The Historians search for the Chief. Unfortunately, a single guard is patrolling this part of the lab.

// Maybe you can work out where the guard will go ahead of time so that The Historians can search safely?

// You start by making a map (your puzzle input) of the situation. For example:

// ....#.....
// .........#
// ..........
// ..#.......
// .......#..
// ..........
// .#..^.....
// ........#.
// #.........
// ......#...
// The map shows the current position of the guard with ^ (to indicate the guard is currently facing up from the perspective of the map). Any obstructions - crates, desks, alchemical reactors, etc. - are shown as #.

// Lab guards in 1518 follow a very strict patrol protocol which involves repeatedly following these steps:

// If there is something directly in front of you, turn right 90 degrees.
// Otherwise, take a step forward.
// Following the above protocol, the guard moves up several times until she reaches an obstacle (in this case, a pile of failed suit prototypes):

// ....#.....
// ....^....#
// ..........
// ..#.......
// .......#..
// ..........
// .#........
// ........#.
// #.........
// ......#...
// Because there is now an obstacle in front of the guard, she turns right before continuing straight in her new facing direction:

// ....#.....
// ........>#
// ..........
// ..#.......
// .......#..
// ..........
// .#........
// ........#.
// #.........
// ......#...
// Reaching another obstacle (a spool of several very long polymers), she turns right again and continues downward:

// ....#.....
// .........#
// ..........
// ..#.......
// .......#..
// ..........
// .#......v.
// ........#.
// #.........
// ......#...
// This process continues for a while, but the guard eventually leaves the mapped area (after walking past a tank of universal solvent):

// ....#.....
// .........#
// ..........
// ..#.......
// .......#..
// ..........
// .#........
// ........#.
// #.........
// ......#v..
// By predicting the guard's route, you can determine which specific positions in the lab will be in the patrol path. Including the guard's starting position, the positions visited by the guard before leaving the area are marked with an X:

// ....#.....
// ....XXXXX#
// ....X...X.
// ..#.X...X.
// ..XXXXX#X.
// ..X.X.X.X.
// .#XXXXXXX.
// .XXXXXXX#.
// #XXXXXXX..
// ......#X..
// In this example, the guard will visit 41 distinct positions on your map.

// Predict the path of the guard. How many distinct positions will the guard visit before leaving the mapped area?
pub const Index = struct {
    x: usize,
    y: usize,
};

pub fn indx_to_x_y(indx: usize, width: usize) Index {
    const x = indx % width;
    return .{
        .x = x,
        .y = @divFloor(indx - x, width),
    };
}

pub inline fn x_y_to_indx(indx: Index, width: usize) usize {
    return indx.y * width + indx.x;
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var width: usize = undefined;
    var buf: [4096]u8 = undefined;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.indexOfScalar(u8, line, '\r')) |indx| {
            const carriage_less = line[0..indx];
            width = carriage_less.len;
            try map.appendSlice(carriage_less);
        } else {
            width = line.len;
            try map.appendSlice(line);
        }
    }
    const height = map.items.len / width;
    if (std.mem.indexOfScalar(u8, map.items, '^')) |indx| {
        var guard_loc = indx_to_x_y(indx, width);
        var inbounds = true;
        var guard_symbol: u8 = '^';
        while (inbounds) {
            switch (guard_symbol) {
                '^' => {
                    if (guard_loc.y == 0) {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        inbounds = false;
                    } else if (map.items[(guard_loc.y - 1) * width + guard_loc.x] == '#') {
                        guard_symbol = '>';
                    } else {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        guard_loc.y -= 1;
                        guard_symbol = '^';
                    }
                },
                'v' => {
                    if (guard_loc.y + 1 >= height) {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        inbounds = false;
                    } else if (map.items[(guard_loc.y + 1) * width + guard_loc.x] == '#') {
                        guard_symbol = '<';
                    } else {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        guard_loc.y += 1;
                        guard_symbol = 'v';
                    }
                },
                '>' => {
                    if (guard_loc.x + 1 >= width) {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        inbounds = false;
                    } else if (map.items[(guard_loc.y) * width + guard_loc.x + 1] == '#') {
                        guard_symbol = 'v';
                    } else {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        guard_loc.x += 1;
                        guard_symbol = '>';
                    }
                },
                '<' => {
                    if (guard_loc.x == 0) {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        inbounds = false;
                    } else if (map.items[(guard_loc.y) * width + guard_loc.x - 1] == '#') {
                        guard_symbol = '^';
                    } else {
                        map.items[x_y_to_indx(guard_loc, width)] = 'X';
                        guard_loc.x -= 1;
                        guard_symbol = '<';
                    }
                },
                else => unreachable,
            }
        }
    }
    return std.mem.count(u8, map.items, "X");
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = file_name;
    _ = allocator;
    return 0;
}
test "day6" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    std.debug.print("Number of distinct positions {d}\n", .{try part1("inputs/day6/input.txt", allocator)});
    std.debug.print("{d}\n", .{try part2("inputs/day6/input.txt", allocator)});
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
