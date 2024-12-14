const std = @import("std");
// https://adventofcode.com/2024/day/14
// --- Day 14: Restroom Redoubt ---
// One of The Historians needs to use the bathroom; fortunately, you know there's a bathroom near an unvisited location on their list, and so you're all quickly teleported directly to the lobby of Easter Bunny Headquarters.

// Unfortunately, EBHQ seems to have "improved" bathroom security again after your last visit. The area outside the bathroom is swarming with robots!

// To get The Historian safely to the bathroom, you'll need a way to predict where the robots will be in the future. Fortunately, they all seem to be moving on the tile floor in predictable straight lines.

// You make a list (your puzzle input) of all of the robots' current positions (p) and velocities (v), one robot per line. For example:

// p=0,4 v=3,-3
// p=6,3 v=-1,-3
// p=10,3 v=-1,2
// p=2,0 v=2,-1
// p=0,0 v=1,3
// p=3,0 v=-2,-2
// p=7,6 v=-1,-3
// p=3,0 v=-1,-2
// p=9,3 v=2,3
// p=7,3 v=-1,2
// p=2,4 v=2,-3
// p=9,5 v=-3,-3
// Each robot's position is given as p=x,y where x represents the number of tiles the robot is from the left wall and y represents the number of tiles from the top wall (when viewed from above). So, a position of p=0,0 means the robot is all the way in the top-left corner.

// Each robot's velocity is given as v=x,y where x and y are given in tiles per second. Positive x means the robot is moving to the right, and positive y means the robot is moving down. So, a velocity of v=1,-2 means that each second, the robot moves 1 tile to the right and 2 tiles up.

// The robots outside the actual bathroom are in a space which is 101 tiles wide and 103 tiles tall (when viewed from above). However, in this example, the robots are in a space which is only 11 tiles wide and 7 tiles tall.

// The robots are good at navigating over/under each other (due to a combination of springs, extendable legs, and quadcopters), so they can share the same tile and don't interact with each other. Visually, the number of robots on each tile in this example looks like this:

// 1.12.......
// ...........
// ...........
// ......11.11
// 1.1........
// .........1.
// .......1...
// These robots have a unique feature for maximum bathroom security: they can teleport. When a robot would run into an edge of the space they're in, they instead teleport to the other side, effectively wrapping around the edges. Here is what robot p=2,4 v=2,-3 does for the first few seconds:

// Initial state:
// ...........
// ...........
// ...........
// ...........
// ..1........
// ...........
// ...........

// After 1 second:
// ...........
// ....1......
// ...........
// ...........
// ...........
// ...........
// ...........

// After 2 seconds:
// ...........
// ...........
// ...........
// ...........
// ...........
// ......1....
// ...........

// After 3 seconds:
// ...........
// ...........
// ........1..
// ...........
// ...........
// ...........
// ...........

// After 4 seconds:
// ...........
// ...........
// ...........
// ...........
// ...........
// ...........
// ..........1

// After 5 seconds:
// ...........
// ...........
// ...........
// .1.........
// ...........
// ...........
// ...........
// The Historian can't wait much longer, so you don't have to simulate the robots for very long. Where will the robots be after 100 seconds?

// In the above example, the number of robots on each tile after 100 seconds has elapsed looks like this:

// ......2..1.
// ...........
// 1..........
// .11........
// .....1.....
// ...12......
// .1....1....
// To determine the safest area, count the number of robots in each quadrant after 100 seconds. Robots that are exactly in the middle (horizontally or vertically) don't count as being in any quadrant, so the only relevant robots are:

// ..... 2..1.
// ..... .....
// 1.... .....

// ..... .....
// ...12 .....
// .1... 1....
// In this example, the quadrants contain 1, 3, 4, and 1 robot. Multiplying these together gives a total safety factor of 12.

// Predict the motion of the robots in your list within a space which is 101 tiles wide and 103 tiles tall. What will the safety factor be after exactly 100 seconds have elapsed?
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
var map_width: usize = undefined;
var map_height: usize = undefined;

pub const Location = struct {
    x: i64,
    y: i64,
    fn init(indx: usize) Location {
        const x = @as(i64, @bitCast(indx % map_width));
        return .{
            .x = x,
            .y = @as(i64, @bitCast(@divFloor(@as(i64, @bitCast(indx)) - @as(i64, @bitCast(x)), @as(i64, @bitCast(map_width))))),
        };
    }
    fn to_indx(loc: *const Location) usize {
        return @as(usize, @bitCast(loc.y)) * map_width + @as(usize, @bitCast(loc.x));
    }
};

pub const Robot = struct {
    loc: Location = undefined,
    vel: Velocity = undefined,

    pub const Velocity = struct {
        x: i64,
        y: i64,
    };
    pub fn simulate(self: *Robot, turns: u64) Location {
        self.loc.x = @mod(self.loc.x + (self.vel.x * @as(i64, @bitCast(turns))), @as(i64, @bitCast(map_width)));
        self.loc.y = @mod(self.loc.y + (self.vel.y * @as(i64, @bitCast(turns))), @as(i64, @bitCast(map_height)));
        return self.loc;
    }
};
var longest_col: usize = 0;
var longest_col_index: usize = 0;
pub fn run_robots_p2(robots: std.ArrayList(Robot), map: std.ArrayList(u8), rounds: usize) u64 {
    for (0..map.items.len) |i| {
        map.items[i] = 0;
    }
    for (0..robots.items.len) |i| {
        map.items[robots.items[i].simulate(rounds).to_indx()] += 1;
    }
    var col_in_row: usize = 0;
    var previous_col = false;
    var most_col_in_row: usize = 0;
    for (0..map_height) |i| {
        for (0..map_width) |j| {
            if (map.items[i * map_width + j] == 0) {
                if (previous_col) {
                    if (col_in_row > most_col_in_row) {
                        most_col_in_row = col_in_row;
                    }
                    col_in_row = 0;
                    previous_col = false;
                }
            } else {
                col_in_row += 1;
                previous_col = true;
            }
        }
    }
    return most_col_in_row;
}

pub fn print_robots(map: std.ArrayList(u8)) void {
    for (0..map_height) |i| {
        for (0..map_width) |j| {
            if (i == map_height / 2 or j == map_width / 2) {
                std.debug.print(" ", .{});
            } else {
                if (i < map_height / 2 and j < map_width / 2) {
                    std.debug.print("{s}", .{colors[0]});
                } else if (i < map_height / 2 and j > map_width / 2) {
                    std.debug.print("{s}", .{colors[1]});
                } else if (i > map_height / 2 and j < map_width / 2) {
                    std.debug.print("{s}", .{colors[2]});
                } else {
                    std.debug.print("{s}", .{colors[3]});
                }
                if (map.items[i * map_width + j] == 0) {
                    std.debug.print("." ++ color_end, .{});
                } else {
                    std.debug.print("{d}" ++ color_end, .{map.items[i * map_width + j]});
                }
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn run_robots(robots: std.ArrayList(Robot), map: std.ArrayList(u8), rounds: usize) u64 {
    for (0..map.items.len) |i| {
        map.items[i] = 0;
    }
    for (0..robots.items.len) |i| {
        map.items[robots.items[i].simulate(rounds).to_indx()] += 1;
    }
    var q1_bots: u64 = 0;
    var q2_bots: u64 = 0;
    var q3_bots: u64 = 0;
    var q4_bots: u64 = 0;
    for (0..map_height) |i| {
        for (0..map_width) |j| {
            if (map.items[i * map_width + j] == 0) {
                continue;
            } else {
                if (i < map_height / 2 and j < map_width / 2) {
                    q1_bots += map.items[i * map_width + j];
                } else if (i < map_height / 2 and j > map_width / 2) {
                    q2_bots += map.items[i * map_width + j];
                } else if (i > map_height / 2 and j < map_width / 2) {
                    q3_bots += map.items[i * map_width + j];
                } else {
                    q4_bots += map.items[i * map_width + j];
                }
            }
        }
    }
    return q1_bots * q2_bots * q3_bots * q4_bots;
}

var num_buf: [1024]u8 = undefined;
pub fn part1(file_name: []const u8, allocator: std.mem.Allocator, width: u64, height: u64) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        const position_start = std.mem.indexOf(u8, line, "p=").?;
        const position_y_index = std.mem.indexOfScalarPos(u8, line, position_start, ',').? + 1;
        const position_x = try std.fmt.parseInt(i64, line[position_start + 2 .. position_y_index - 1], 10);
        const position_y_end = std.mem.indexOfScalarPos(u8, line, position_y_index, ' ').?;
        const position_y = try std.fmt.parseInt(i64, line[position_y_index..position_y_end], 10);

        const velocity_start = std.mem.indexOf(u8, line, "v=").?;
        const velocity_y_index = std.mem.indexOfScalarPos(u8, line, velocity_start, ',').? + 1;
        const velocity_x = try std.fmt.parseInt(i64, line[velocity_start + 2 .. velocity_y_index - 1], 10);
        const velocity_y_end = line.len;
        const velocity_y = try std.fmt.parseInt(i64, line[velocity_y_index..velocity_y_end], 10);
        try robots.append(Robot{
            .loc = .{
                .x = position_x,
                .y = position_y,
            },
            .vel = .{
                .x = velocity_x,
                .y = velocity_y,
            },
        });
    }
    map_width = width;
    map_height = height;
    for (0..map_height) |_| {
        for (0..map_width) |_| {
            try map.append(0);
        }
    }
    //std.debug.print("map {s}\nwidth {d} height {d} len {d}\n", .{ map.items, map_width, map_height, map.items.len });
    //std.debug.print("Robots {any}\n", .{robots.items});
    const result = run_robots(robots, map, 100);
    //print_robots(map);
    return result;
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator, width: u64, height: u64) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        const position_start = std.mem.indexOf(u8, line, "p=").?;
        const position_y_index = std.mem.indexOfScalarPos(u8, line, position_start, ',').? + 1;
        const position_x = try std.fmt.parseInt(i64, line[position_start + 2 .. position_y_index - 1], 10);
        const position_y_end = std.mem.indexOfScalarPos(u8, line, position_y_index, ' ').?;
        const position_y = try std.fmt.parseInt(i64, line[position_y_index..position_y_end], 10);

        const velocity_start = std.mem.indexOf(u8, line, "v=").?;
        const velocity_y_index = std.mem.indexOfScalarPos(u8, line, velocity_start, ',').? + 1;
        const velocity_x = try std.fmt.parseInt(i64, line[velocity_start + 2 .. velocity_y_index - 1], 10);
        const velocity_y_end = line.len;
        const velocity_y = try std.fmt.parseInt(i64, line[velocity_y_index..velocity_y_end], 10);
        try robots.append(Robot{
            .loc = .{
                .x = position_x,
                .y = position_y,
            },
            .vel = .{
                .x = velocity_x,
                .y = velocity_y,
            },
        });
    }
    map_width = width;
    map_height = height;
    for (0..map_height) |_| {
        for (0..map_width) |_| {
            try map.append(0);
        }
    }
    //std.debug.print("map {s}\nwidth {d} height {d} len {d}\n", .{ map.items, map_width, map_height, map.items.len });
    //std.debug.print("Robots {any}\n", .{robots.items});
    for (0..map_width * map_height) |i| {
        const col_length = run_robots_p2(robots, map, 1);
        if (col_length > longest_col) {
            longest_col = col_length;
            longest_col_index = i + 1;
            print_robots(map);
        }
    }
    return longest_col_index;
}
test "day14" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Easter egg at second {d} in {d}ms\n", .{ try part2("inputs/day14/input.txt", allocator, 101, 103), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Safety factor after 100 seconds {d} in {d}ms\n", .{ try part1("inputs/day14/input.txt", allocator, 101, 103), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
