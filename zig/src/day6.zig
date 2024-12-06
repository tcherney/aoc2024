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
    pub fn cmp(self: *Index, other: Index) bool {
        return self.x == other.x and self.y == other.y;
    }
};

pub const Node = struct {
    val: u8 = '.',
    visited: bool = false,
    pub fn update(self: *Node, guard_symbol: u8) bool {
        if (!self.visited or (self.visited and self.val != guard_symbol)) {
            self.visited = true;
            self.val = guard_symbol;
        }
        // visited location again going same direction, we have cycle
        else if (self.visited and self.val == guard_symbol) {
            //std.debug.print("cycle detected\n", .{});
            return true;
        }
        return false;
    }
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

// --- Part Two ---
// While The Historians begin working around the guard's patrol route, you borrow their fancy device and step outside the lab. From the safety of a supply closet, you time travel through the last few months and record the nightly status of the lab's guard post on the walls of the closet.

// Returning after what seems like only a few seconds to The Historians, they explain that the guard's patrol area is simply too large for them to safely search the lab without getting caught.

// Fortunately, they are pretty sure that adding a single new obstruction won't cause a time paradox. They'd like to place the new obstruction in such a way that the guard will get stuck in a loop, making the rest of the lab safe to search.

// To have the lowest chance of creating a time paradox, The Historians would like to know all of the possible positions for such an obstruction. The new obstruction can't be placed at the guard's starting position - the guard is there right now and would notice.

// In the above example, there are only 6 different positions where a new obstruction would cause the guard to get stuck in a loop. The diagrams of these six situations use O to mark the new obstruction, | to show a position where the guard moves up/down, - to show a position where the guard moves left/right, and + to show a position where the guard moves both up/down and left/right.

// Option one, put a printing press next to the guard's starting position:

// ....#.....
// ....+---+#
// ....|...|.
// ..#.|...|.
// ....|..#|.
// ....|...|.
// .#.O^---+.
// ........#.
// #.........
// ......#...
// Option two, put a stack of failed suit prototypes in the bottom right quadrant of the mapped area:

// ....#.....
// ....+---+#
// ....|...|.
// ..#.|...|.
// ..+-+-+#|.
// ..|.|.|.|.
// .#+-^-+-+.
// ......O.#.
// #.........
// ......#...
// Option three, put a crate of chimney-squeeze prototype fabric next to the standing desk in the bottom right quadrant:

// ....#.....
// ....+---+#
// ....|...|.
// ..#.|...|.
// ..+-+-+#|.
// ..|.|.|.|.
// .#+-^-+-+.
// .+----+O#.
// #+----+...
// ......#...
// Option four, put an alchemical retroencabulator near the bottom left corner:

// ....#.....
// ....+---+#
// ....|...|.
// ..#.|...|.
// ..+-+-+#|.
// ..|.|.|.|.
// .#+-^-+-+.
// ..|...|.#.
// #O+---+...
// ......#...
// Option five, put the alchemical retroencabulator a bit to the right instead:

// ....#.....
// ....+---+#
// ....|...|.
// ..#.|...|.
// ..+-+-+#|.
// ..|.|.|.|.
// .#+-^-+-+.
// ....|.|.#.
// #..O+-+...
// ......#...
// Option six, put a tank of sovereign glue right next to the tank of universal solvent:

// ....#.....
// ....+---+#
// ....|...|.
// ..#.|...|.
// ..+-+-+#|.
// ..|.|.|.|.
// .#+-^-+-+.
// .+----++#.
// #+----++..
// ......#O..
// It doesn't really matter what you choose to use as an obstacle so long as you and The Historians can put it into position without the guard noticing. The important thing is having enough options that you can find one that minimizes time paradoxes, and in this example, there are 6 different positions you could choose.

// You need to get the guard stuck in a loop by adding a single new obstruction. How many different positions could you choose for this obstruction?

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
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
    var result: usize = 0;
    var nodes: std.ArrayList(Node) = std.ArrayList(Node).init(allocator);
    for (0..map.items.len) |_| {
        try nodes.append(Node{});
    }
    defer nodes.deinit();
    for (0..map.items.len) |i| {
        if (map.items[i] != '.') continue;
        //std.debug.print("placing obstruction at {d}\n", .{i});
        for (0..nodes.items.len) |j| {
            nodes.items[j].visited = false;
            nodes.items[j].val = '.';
        }
        var cycle_detected = false;
        var map_copy = try map.clone();
        map_copy.items[i] = '#';
        defer map_copy.deinit();
        if (std.mem.indexOfScalar(u8, map_copy.items, '^')) |indx| {
            var guard_loc = indx_to_x_y(indx, width);
            var inbounds = true;
            var guard_symbol: u8 = '^';
            while (inbounds and !cycle_detected) {
                // for (0..height) |j| {
                //     for (0..width) |k| {
                //         std.debug.print("{c}", .{map_copy.items[j * width + k]});
                //     }
                //     std.debug.print("\n", .{});
                // }
                // std.debug.print("\n", .{});
                var current_node = &nodes.items[x_y_to_indx(guard_loc, width)];
                switch (guard_symbol) {
                    '^' => {
                        if (guard_loc.y == 0) {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            inbounds = false;
                        } else if (map_copy.items[(guard_loc.y - 1) * width + guard_loc.x] == '#') {
                            guard_symbol = '>';
                        } else {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            cycle_detected = current_node.update(guard_symbol);
                            guard_loc.y -= 1;
                            guard_symbol = '^';
                        }
                    },
                    'v' => {
                        if (guard_loc.y + 1 >= height) {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            inbounds = false;
                        } else if (map_copy.items[(guard_loc.y + 1) * width + guard_loc.x] == '#') {
                            guard_symbol = '<';
                        } else {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            cycle_detected = current_node.update(guard_symbol);
                            guard_loc.y += 1;
                            guard_symbol = 'v';
                        }
                    },
                    '>' => {
                        if (guard_loc.x + 1 >= width) {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            inbounds = false;
                        } else if (map_copy.items[(guard_loc.y) * width + guard_loc.x + 1] == '#') {
                            guard_symbol = 'v';
                        } else {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            cycle_detected = current_node.update(guard_symbol);
                            guard_loc.x += 1;
                            guard_symbol = '>';
                        }
                    },
                    '<' => {
                        if (guard_loc.x == 0) {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            inbounds = false;
                        } else if (map_copy.items[(guard_loc.y) * width + guard_loc.x - 1] == '#') {
                            guard_symbol = '^';
                        } else {
                            map_copy.items[x_y_to_indx(guard_loc, width)] = 'X';
                            cycle_detected = current_node.update(guard_symbol);
                            guard_loc.x -= 1;
                            guard_symbol = '<';
                        }
                    },
                    else => unreachable,
                }
                if (cycle_detected) result += 1;
            }
        }
    }
    return result;
}
test "day6" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    std.debug.print("Number of distinct positions {d}\n", .{try part1("inputs/day6/input.txt", allocator)});
    std.debug.print("Number of positions for obstruction {d}\n", .{try part2("inputs/day6/input.txt", allocator)});
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
