const std = @import("std");
// https://adventofcode.com/2024/day/15
// --- Day 15: Warehouse Woes ---
// You appear back inside your own mini submarine! Each Historian drives their mini submarine in a different direction; maybe the Chief has his own submarine down here somewhere as well?

// You look up to see a vast school of lanternfish swimming past you. On closer inspection, they seem quite anxious, so you drive your mini submarine over to see if you can help.

// Because lanternfish populations grow rapidly, they need a lot of food, and that food needs to be stored somewhere. That's why these lanternfish have built elaborate warehouse complexes operated by robots!

// These lanternfish seem so anxious because they have lost control of the robot that operates one of their most important warehouses! It is currently running amok, pushing around boxes in the warehouse with no regard for lanternfish logistics or lanternfish inventory management strategies.

// Right now, none of the lanternfish are brave enough to swim up to an unpredictable robot so they could shut it off. However, if you could anticipate the robot's movements, maybe they could find a safe option.

// The lanternfish already have a map of the warehouse and a list of movements the robot will attempt to make (your puzzle input). The problem is that the movements will sometimes fail as boxes are shifted around, making the actual movements of the robot difficult to predict.

// For example:

// ##########
// #..O..O.O#
// #......O.#
// #.OO..O.O#
// #..O@..O.#
// #O#..O...#
// #O..O..O.#
// #.OO.O.OO#
// #....O...#
// ##########

// <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
// vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
// ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
// <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
// ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
// ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
// >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
// <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
// ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
// v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
// As the robot (@) attempts to move, if there are any boxes (O) in the way, the robot will also attempt to push those boxes. However, if this action would cause the robot or a box to move into a wall (#), nothing moves instead, including the robot. The initial positions of these are shown on the map at the top of the document the lanternfish gave you.

// The rest of the document describes the moves (^ for up, v for down, < for left, > for right) that the robot will attempt to make, in order. (The moves form a single giant sequence; they are broken into multiple lines just to make copy-pasting easier. Newlines within the move sequence should be ignored.)

// Here is a smaller example to get started:

// ########
// #..O.O.#
// ##@.O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// <^^>>>vv<v>>v<<
// Were the robot to attempt the given sequence of moves, it would push around the boxes as follows:

// Initial state:
// ########
// #..O.O.#
// ##@.O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// Move <:
// ########
// #..O.O.#
// ##@.O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// Move ^:
// ########
// #.@O.O.#
// ##..O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// Move ^:
// ########
// #.@O.O.#
// ##..O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// Move >:
// ########
// #..@OO.#
// ##..O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// Move >:
// ########
// #...@OO#
// ##..O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// Move >:
// ########
// #...@OO#
// ##..O..#
// #...O..#
// #.#.O..#
// #...O..#
// #......#
// ########

// Move v:
// ########
// #....OO#
// ##..@..#
// #...O..#
// #.#.O..#
// #...O..#
// #...O..#
// ########

// Move v:
// ########
// #....OO#
// ##..@..#
// #...O..#
// #.#.O..#
// #...O..#
// #...O..#
// ########

// Move <:
// ########
// #....OO#
// ##.@...#
// #...O..#
// #.#.O..#
// #...O..#
// #...O..#
// ########

// Move v:
// ########
// #....OO#
// ##.....#
// #..@O..#
// #.#.O..#
// #...O..#
// #...O..#
// ########

// Move >:
// ########
// #....OO#
// ##.....#
// #...@O.#
// #.#.O..#
// #...O..#
// #...O..#
// ########

// Move >:
// ########
// #....OO#
// ##.....#
// #....@O#
// #.#.O..#
// #...O..#
// #...O..#
// ########

// Move v:
// ########
// #....OO#
// ##.....#
// #.....O#
// #.#.O@.#
// #...O..#
// #...O..#
// ########

// Move <:
// ########
// #....OO#
// ##.....#
// #.....O#
// #.#O@..#
// #...O..#
// #...O..#
// ########

// Move <:
// ########
// #....OO#
// ##.....#
// #.....O#
// #.#O@..#
// #...O..#
// #...O..#
// ########
// The larger example has many more moves; after the robot has finished those moves, the warehouse would look like this:

// ##########
// #.O.O.OOO#
// #........#
// #OO......#
// #OO@.....#
// #O#.....O#
// #O.....OO#
// #O.....OO#
// #OO....OO#
// ##########
// The lanternfish use their own custom Goods Positioning System (GPS for short) to track the locations of the boxes. The GPS coordinate of a box is equal to 100 times its distance from the top edge of the map plus its distance from the left edge of the map. (This process does not stop at wall tiles; measure all the way to the edges of the map.)

// So, the box shown below has a distance of 1 from the top edge of the map and 4 from the left edge of the map, resulting in a GPS coordinate of 100 * 1 + 4 = 104.

// #######
// #...O..
// #......
// The lanternfish would like to know the sum of all boxes' GPS coordinates after the robot finishes moving. In the larger example, the sum of all boxes' GPS coordinates is 10092. In the smaller example, the sum is 2028.

// Predict the motion of the robot and boxes in the warehouse. After the robot is finished moving, what is the sum of all boxes' GPS coordinates?

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

    pub fn move(self: *Robot, map: std.ArrayList(u8), direction: u8) void {
        map.items[self.loc.to_indx()] = '.';
        switch (direction) {
            '^' => {
                const new_loc = Location{
                    .x = self.loc.x,
                    .y = self.loc.y - 1,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.y -= 1;
                    } else if (dest == 'O') {
                        var have_room = false;
                        var wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        while (map.items[wall_loc.to_indx()] == 'O') {
                            wall_loc.y -= 1;
                            if (map.items[wall_loc.to_indx()] == '.') {
                                have_room = true;
                                break;
                            }
                        }
                        if (have_room) {
                            self.loc.y -= 1;
                            while (wall_loc.y != self.loc.y) {
                                map.items[wall_loc.to_indx()] = 'O';
                                wall_loc.y += 1;
                            }
                        }
                    }
                }
            },
            '>' => {
                const new_loc = Location{
                    .x = self.loc.x + 1,
                    .y = self.loc.y,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.x += 1;
                    } else if (dest == 'O') {
                        var have_room = false;
                        var wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        while (map.items[wall_loc.to_indx()] == 'O') {
                            wall_loc.x += 1;
                            if (map.items[wall_loc.to_indx()] == '.') {
                                have_room = true;
                                break;
                            }
                        }
                        if (have_room) {
                            self.loc.x += 1;
                            while (wall_loc.x != self.loc.x) {
                                map.items[wall_loc.to_indx()] = 'O';
                                wall_loc.x -= 1;
                            }
                        }
                    }
                }
            },
            'v' => {
                const new_loc = Location{
                    .x = self.loc.x,
                    .y = self.loc.y + 1,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.y += 1;
                    } else if (dest == 'O') {
                        var have_room = false;
                        var wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        while (map.items[wall_loc.to_indx()] == 'O') {
                            wall_loc.y += 1;
                            if (map.items[wall_loc.to_indx()] == '.') {
                                have_room = true;
                                break;
                            }
                        }
                        if (have_room) {
                            self.loc.y += 1;
                            while (wall_loc.y != self.loc.y) {
                                map.items[wall_loc.to_indx()] = 'O';
                                wall_loc.y -= 1;
                            }
                        }
                    }
                }
            },
            '<' => {
                const new_loc = Location{
                    .x = self.loc.x - 1,
                    .y = self.loc.y,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.x -= 1;
                    } else if (dest == 'O') {
                        var have_room = false;
                        var wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        while (map.items[wall_loc.to_indx()] == 'O') {
                            wall_loc.x -= 1;
                            if (map.items[wall_loc.to_indx()] == '.') {
                                have_room = true;
                                break;
                            }
                        }
                        if (have_room) {
                            self.loc.x -= 1;
                            while (wall_loc.x != self.loc.x) {
                                map.items[wall_loc.to_indx()] = 'O';
                                wall_loc.x += 1;
                            }
                        }
                    }
                }
            },
            else => unreachable,
        }
        map.items[self.loc.to_indx()] = '@';
    }
    pub fn check_wall(self: *Robot, map: std.ArrayList(u8), wall_loc: Location, direction: u8) bool {
        switch (direction) {
            '^' => {
                var left_loc = Location{
                    .x = wall_loc.x,
                    .y = wall_loc.y - 1,
                };
                const right_loc = Location{
                    .x = wall_loc.x + 1,
                    .y = wall_loc.y - 1,
                };
                const dest_left = map.items[left_loc.to_indx()];
                const dest_right = map.items[right_loc.to_indx()];
                if (dest_left != '#' and dest_right != '#') {
                    if (dest_left == '.' and dest_right == '.') {
                        return true;
                    } else if (dest_left == '[') {
                        if (self.check_wall(map, left_loc, direction)) {
                            return true;
                        }
                        return false;
                    } else {
                        if (dest_left == ']' and dest_right == '.') {
                            left_loc.x -= 1;
                            if (self.check_wall(map, left_loc, direction)) {
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == '.') {
                            if (self.check_wall(map, right_loc, direction)) {
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == ']') {
                            left_loc.x -= 1;
                            if (self.check_wall(map, left_loc, direction) and self.check_wall(map, right_loc, direction)) {
                                return true;
                            }
                            return false;
                        } else {
                            unreachable;
                        }
                    }
                } else {
                    return false;
                }
            },
            '>' => {
                const right_loc = Location{
                    .x = wall_loc.x + 2,
                    .y = wall_loc.y,
                };
                const dest_right = map.items[right_loc.to_indx()];
                if (dest_right != '#') {
                    if (dest_right == '.') {
                        return true;
                    } else if (dest_right == '[') {
                        if (self.check_wall(map, right_loc, direction)) {
                            return true;
                        }
                        return false;
                    } else {
                        unreachable;
                    }
                } else {
                    return false;
                }
            },
            'v' => {
                var left_loc = Location{
                    .x = wall_loc.x,
                    .y = wall_loc.y + 1,
                };
                const right_loc = Location{
                    .x = wall_loc.x + 1,
                    .y = wall_loc.y + 1,
                };
                const dest_left = map.items[left_loc.to_indx()];
                const dest_right = map.items[right_loc.to_indx()];
                if (dest_left != '#' and dest_right != '#') {
                    if (dest_left == '.' and dest_right == '.') {
                        return true;
                    } else if (dest_left == '[') {
                        if (self.check_wall(map, left_loc, direction)) {
                            return true;
                        }
                        return false;
                    } else {
                        if (dest_left == ']' and dest_right == '.') {
                            left_loc.x -= 1;
                            if (self.check_wall(map, left_loc, direction)) {
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == '.') {
                            if (self.check_wall(map, right_loc, direction)) {
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == ']') {
                            left_loc.x -= 1;
                            if (self.check_wall(map, left_loc, direction) and self.check_wall(map, right_loc, direction)) {
                                return true;
                            }
                            return false;
                        } else {
                            unreachable;
                        }
                    }
                } else {
                    return false;
                }
            },
            '<' => {
                var left_loc = Location{
                    .x = wall_loc.x - 1,
                    .y = wall_loc.y,
                };
                const dest_left = map.items[left_loc.to_indx()];
                if (dest_left != '#') {
                    if (dest_left == '.') {
                        return true;
                    } else if (dest_left == ']') {
                        left_loc.x -= 1;
                        if (self.check_wall(map, left_loc, direction)) {
                            return true;
                        }
                        return false;
                    } else {
                        unreachable;
                    }
                } else {
                    return false;
                }
            },
            else => unreachable,
        }
        return false;
    }
    pub fn move_wall(self: *Robot, map: std.ArrayList(u8), wall_loc: Location, direction: u8) bool {
        switch (direction) {
            '^' => {
                var left_loc = Location{
                    .x = wall_loc.x,
                    .y = wall_loc.y - 1,
                };
                const right_loc = Location{
                    .x = wall_loc.x + 1,
                    .y = wall_loc.y - 1,
                };
                const dest_left = map.items[left_loc.to_indx()];
                const dest_right = map.items[right_loc.to_indx()];
                if (dest_left != '#' and dest_right != '#') {
                    if (dest_left == '.' and dest_right == '.') {
                        // move wall
                        var new_wall_loc = Location{
                            .x = wall_loc.x,
                            .y = wall_loc.y,
                        };
                        map.items[new_wall_loc.to_indx()] = '.';
                        new_wall_loc.x += 1;
                        map.items[new_wall_loc.to_indx()] = '.';
                        new_wall_loc.y -= 1;
                        map.items[new_wall_loc.to_indx()] = ']';
                        new_wall_loc.x -= 1;
                        map.items[new_wall_loc.to_indx()] = '[';
                        return true;
                    } else if (dest_left == '[') {
                        if (self.move_wall(map, left_loc, direction)) {
                            //move wall
                            var new_wall_loc = Location{
                                .x = wall_loc.x,
                                .y = wall_loc.y,
                            };
                            map.items[new_wall_loc.to_indx()] = '.';
                            new_wall_loc.x += 1;
                            map.items[new_wall_loc.to_indx()] = '.';
                            new_wall_loc.y -= 1;
                            map.items[new_wall_loc.to_indx()] = ']';
                            new_wall_loc.x -= 1;
                            map.items[new_wall_loc.to_indx()] = '[';
                            return true;
                        }
                        return false;
                    } else {
                        if (dest_left == ']' and dest_right == '.') {
                            left_loc.x -= 1;
                            if (self.move_wall(map, left_loc, direction)) {
                                //move wall
                                var new_wall_loc = Location{
                                    .x = wall_loc.x,
                                    .y = wall_loc.y,
                                };
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.x += 1;
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.y -= 1;
                                map.items[new_wall_loc.to_indx()] = ']';
                                new_wall_loc.x -= 1;
                                map.items[new_wall_loc.to_indx()] = '[';
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == '.') {
                            if (self.move_wall(map, right_loc, direction)) {
                                //move wall
                                var new_wall_loc = Location{
                                    .x = wall_loc.x,
                                    .y = wall_loc.y,
                                };
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.x += 1;
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.y -= 1;
                                map.items[new_wall_loc.to_indx()] = ']';
                                new_wall_loc.x -= 1;
                                map.items[new_wall_loc.to_indx()] = '[';
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == ']') {
                            left_loc.x -= 1;
                            if (self.move_wall(map, left_loc, direction) and self.move_wall(map, right_loc, direction)) {
                                var new_wall_loc = Location{
                                    .x = wall_loc.x,
                                    .y = wall_loc.y,
                                };
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.x += 1;
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.y -= 1;
                                map.items[new_wall_loc.to_indx()] = ']';
                                new_wall_loc.x -= 1;
                                map.items[new_wall_loc.to_indx()] = '[';
                                return true;
                            }
                            return false;
                        } else {
                            unreachable;
                        }
                    }
                } else {
                    return false;
                }
            },
            '>' => {
                const right_loc = Location{
                    .x = wall_loc.x + 2,
                    .y = wall_loc.y,
                };
                const dest_right = map.items[right_loc.to_indx()];
                if (dest_right != '#') {
                    if (dest_right == '.') {
                        // move wall
                        var new_wall_loc = Location{
                            .x = wall_loc.x,
                            .y = wall_loc.y,
                        };
                        map.items[new_wall_loc.to_indx()] = '.';
                        new_wall_loc.x += 1;
                        map.items[new_wall_loc.to_indx()] = '[';
                        new_wall_loc.x += 1;
                        map.items[new_wall_loc.to_indx()] = ']';
                        return true;
                    } else if (dest_right == '[') {
                        if (self.move_wall(map, right_loc, direction)) {
                            //move wall
                            var new_wall_loc = Location{
                                .x = wall_loc.x,
                                .y = wall_loc.y,
                            };
                            map.items[new_wall_loc.to_indx()] = '.';
                            new_wall_loc.x += 1;
                            map.items[new_wall_loc.to_indx()] = '[';
                            new_wall_loc.x += 1;
                            map.items[new_wall_loc.to_indx()] = ']';
                            return true;
                        }
                        return false;
                    } else {
                        unreachable;
                    }
                } else {
                    return false;
                }
            },
            'v' => {
                var left_loc = Location{
                    .x = wall_loc.x,
                    .y = wall_loc.y + 1,
                };
                const right_loc = Location{
                    .x = wall_loc.x + 1,
                    .y = wall_loc.y + 1,
                };
                const dest_left = map.items[left_loc.to_indx()];
                const dest_right = map.items[right_loc.to_indx()];
                if (dest_left != '#' and dest_right != '#') {
                    if (dest_left == '.' and dest_right == '.') {
                        // move wall
                        var new_wall_loc = Location{
                            .x = wall_loc.x,
                            .y = wall_loc.y,
                        };
                        map.items[new_wall_loc.to_indx()] = '.';
                        new_wall_loc.x += 1;
                        map.items[new_wall_loc.to_indx()] = '.';
                        new_wall_loc.y += 1;
                        map.items[new_wall_loc.to_indx()] = ']';
                        new_wall_loc.x -= 1;
                        map.items[new_wall_loc.to_indx()] = '[';
                        return true;
                    } else if (dest_left == '[') {
                        if (self.move_wall(map, left_loc, direction)) {
                            //move wall
                            var new_wall_loc = Location{
                                .x = wall_loc.x,
                                .y = wall_loc.y,
                            };
                            map.items[new_wall_loc.to_indx()] = '.';
                            new_wall_loc.x += 1;
                            map.items[new_wall_loc.to_indx()] = '.';
                            new_wall_loc.y += 1;
                            map.items[new_wall_loc.to_indx()] = ']';
                            new_wall_loc.x -= 1;
                            map.items[new_wall_loc.to_indx()] = '[';
                            return true;
                        }
                        return false;
                    } else {
                        if (dest_left == ']' and dest_right == '.') {
                            left_loc.x -= 1;
                            if (self.move_wall(map, left_loc, direction)) {
                                //move wall
                                var new_wall_loc = Location{
                                    .x = wall_loc.x,
                                    .y = wall_loc.y,
                                };
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.x += 1;
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.y += 1;
                                map.items[new_wall_loc.to_indx()] = ']';
                                new_wall_loc.x -= 1;
                                map.items[new_wall_loc.to_indx()] = '[';
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == '.') {
                            if (self.move_wall(map, right_loc, direction)) {
                                //move wall
                                var new_wall_loc = Location{
                                    .x = wall_loc.x,
                                    .y = wall_loc.y,
                                };
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.x += 1;
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.y += 1;
                                map.items[new_wall_loc.to_indx()] = ']';
                                new_wall_loc.x -= 1;
                                map.items[new_wall_loc.to_indx()] = '[';
                                return true;
                            }
                            return false;
                        } else if (dest_right == '[' and dest_left == ']') {
                            left_loc.x -= 1;
                            if (self.move_wall(map, left_loc, direction) and self.move_wall(map, right_loc, direction)) {
                                var new_wall_loc = Location{
                                    .x = wall_loc.x,
                                    .y = wall_loc.y,
                                };
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.x += 1;
                                map.items[new_wall_loc.to_indx()] = '.';
                                new_wall_loc.y += 1;
                                map.items[new_wall_loc.to_indx()] = ']';
                                new_wall_loc.x -= 1;
                                map.items[new_wall_loc.to_indx()] = '[';
                                return true;
                            }
                            return false;
                        } else {
                            unreachable;
                        }
                    }
                } else {
                    return false;
                }
            },
            '<' => {
                var left_loc = Location{
                    .x = wall_loc.x - 1,
                    .y = wall_loc.y,
                };
                const dest_left = map.items[left_loc.to_indx()];
                if (dest_left != '#') {
                    if (dest_left == '.') {
                        // move wall
                        var new_wall_loc = Location{
                            .x = wall_loc.x + 1,
                            .y = wall_loc.y,
                        };
                        map.items[new_wall_loc.to_indx()] = '.';
                        new_wall_loc.x -= 1;
                        map.items[new_wall_loc.to_indx()] = ']';
                        new_wall_loc.x -= 1;
                        map.items[new_wall_loc.to_indx()] = '[';
                        return true;
                    } else if (dest_left == ']') {
                        left_loc.x -= 1;
                        if (self.move_wall(map, left_loc, direction)) {
                            //move wall
                            var new_wall_loc = Location{
                                .x = wall_loc.x + 1,
                                .y = wall_loc.y,
                            };
                            map.items[new_wall_loc.to_indx()] = '.';
                            new_wall_loc.x -= 1;
                            map.items[new_wall_loc.to_indx()] = ']';
                            new_wall_loc.x -= 1;
                            map.items[new_wall_loc.to_indx()] = '[';
                            return true;
                        }
                        return false;
                    } else {
                        unreachable;
                    }
                } else {
                    return false;
                }
            },
            else => unreachable,
        }
        return false;
    }
    pub fn move2(self: *Robot, map: std.ArrayList(u8), direction: u8) void {
        //std.debug.print("Moving {c}\n", .{direction});
        map.items[self.loc.to_indx()] = '.';
        switch (direction) {
            '^' => {
                const new_loc = Location{
                    .x = self.loc.x,
                    .y = self.loc.y - 1,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.y -= 1;
                    } else if (dest == '[') {
                        const wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.y -= 1;
                        }
                    } else if (dest == ']') {
                        const wall_loc = Location{
                            .x = new_loc.x - 1,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.y -= 1;
                        }
                    }
                }
            },
            '>' => {
                const new_loc = Location{
                    .x = self.loc.x + 1,
                    .y = self.loc.y,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.x += 1;
                    } else if (dest == '[') {
                        const wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.x += 1;
                        }
                    } else if (dest == ']') {
                        const wall_loc = Location{
                            .x = new_loc.x - 1,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.x += 1;
                        }
                    }
                }
            },
            'v' => {
                const new_loc = Location{
                    .x = self.loc.x,
                    .y = self.loc.y + 1,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.y += 1;
                    } else if (dest == '[') {
                        const wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.y += 1;
                        }
                    } else if (dest == ']') {
                        const wall_loc = Location{
                            .x = new_loc.x - 1,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.y += 1;
                        }
                    }
                }
            },
            '<' => {
                const new_loc = Location{
                    .x = self.loc.x - 1,
                    .y = self.loc.y,
                };
                const dest = map.items[new_loc.to_indx()];
                if (dest != '#') {
                    if (dest == '.') {
                        self.loc.x -= 1;
                    } else if (dest == '[') {
                        const wall_loc = Location{
                            .x = new_loc.x,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.x -= 1;
                        }
                    } else if (dest == ']') {
                        const wall_loc = Location{
                            .x = new_loc.x - 1,
                            .y = new_loc.y,
                        };
                        if (self.check_wall(map, wall_loc, direction)) {
                            _ = self.move_wall(map, wall_loc, direction);
                            self.loc.x -= 1;
                        }
                    }
                }
            },
            else => unreachable,
        }
        map.items[self.loc.to_indx()] = '@';
    }
};

pub fn print_map(map: std.ArrayList(u8), with_color: bool) void {
    for (0..map_height) |i| {
        for (0..map_width) |j| {
            switch (map.items[i * map_width + j]) {
                '#' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[0], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                'O', '[', ']' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[2], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                '.' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[1], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                '@' => if (with_color) std.debug.print("{s}{c}" ++ color_end, .{ colors[5], map.items[i * map_width + j] }) else std.debug.print("{c}", .{map.items[i * map_width + j]}),
                else => unreachable,
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn calc_GPS(map: std.ArrayList(u8), symbol: u8) u64 {
    var result: u64 = 0;
    var current_index: usize = 0;
    while (std.mem.indexOfScalarPos(u8, map.items, current_index, symbol)) |indx| {
        const box_loc = Location.init(indx);
        result += (100 * @as(u64, @bitCast(box_loc.y))) + @as(u64, @bitCast(box_loc.x));
        current_index = indx + 1;
    }
    return result;
}

var num_buf: [1024]u8 = undefined;
pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var actions = std.ArrayList(u8).init(allocator);
    defer actions.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        _ = try map.writer().write(line);
        map_width = line.len;
    }
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        _ = try actions.writer().write(line);
    }
    map_height = map.items.len / map_width;
    print_map(map, true);
    std.debug.print("Actions {s}\n", .{actions.items});
    var robot = Robot{
        .loc = Location.init(std.mem.indexOfScalar(u8, map.items, '@').?),
    };
    std.debug.print("Robot {any}\n", .{robot});
    for (actions.items) |action| {
        robot.move(map, action);
        //print_map(map);
    }
    print_map(map, true);
    return calc_GPS(map, 'O');
}

// --- Part Two ---
// The lanternfish use your information to find a safe moment to swim in and turn off the malfunctioning robot! Just as they start preparing a festival in your honor, reports start coming in that a second warehouse's robot is also malfunctioning.

// This warehouse's layout is surprisingly similar to the one you just helped. There is one key difference: everything except the robot is twice as wide! The robot's list of movements doesn't change.

// To get the wider warehouse's map, start with your original map and, for each tile, make the following changes:

// If the tile is #, the new map contains ## instead.
// If the tile is O, the new map contains [] instead.
// If the tile is ., the new map contains .. instead.
// If the tile is @, the new map contains @. instead.
// This will produce a new warehouse map which is twice as wide and with wide boxes that are represented by []. (The robot does not change size.)

// The larger example from before would now look like this:

// ####################
// ##....[]....[]..[]##
// ##............[]..##
// ##..[][]....[]..[]##
// ##....[]@.....[]..##
// ##[]##....[]......##
// ##[]....[]....[]..##
// ##..[][]..[]..[][]##
// ##........[]......##
// ####################
// Because boxes are now twice as wide but the robot is still the same size and speed, boxes can be aligned such that they directly push two other boxes at once. For example, consider this situation:

// #######
// #...#.#
// #.....#
// #..OO@#
// #..O..#
// #.....#
// #######

// <vv<<^^<<^^
// After appropriately resizing this map, the robot would push around these boxes as follows:

// Initial state:
// ##############
// ##......##..##
// ##..........##
// ##....[][]@.##
// ##....[]....##
// ##..........##
// ##############

// Move <:
// ##############
// ##......##..##
// ##..........##
// ##...[][]@..##
// ##....[]....##
// ##..........##
// ##############

// Move v:
// ##############
// ##......##..##
// ##..........##
// ##...[][]...##
// ##....[].@..##
// ##..........##
// ##############

// Move v:
// ##############
// ##......##..##
// ##..........##
// ##...[][]...##
// ##....[]....##
// ##.......@..##
// ##############

// Move <:
// ##############
// ##......##..##
// ##..........##
// ##...[][]...##
// ##....[]....##
// ##......@...##
// ##############

// Move <:
// ##############
// ##......##..##
// ##..........##
// ##...[][]...##
// ##....[]....##
// ##.....@....##
// ##############

// Move ^:
// ##############
// ##......##..##
// ##...[][]...##
// ##....[]....##
// ##.....@....##
// ##..........##
// ##############

// Move ^:
// ##############
// ##......##..##
// ##...[][]...##
// ##....[]....##
// ##.....@....##
// ##..........##
// ##############

// Move <:
// ##############
// ##......##..##
// ##...[][]...##
// ##....[]....##
// ##....@.....##
// ##..........##
// ##############

// Move <:
// ##############
// ##......##..##
// ##...[][]...##
// ##....[]....##
// ##...@......##
// ##..........##
// ##############

// Move ^:
// ##############
// ##......##..##
// ##...[][]...##
// ##...@[]....##
// ##..........##
// ##..........##
// ##############

// Move ^:
// ##############
// ##...[].##..##
// ##...@.[]...##
// ##....[]....##
// ##..........##
// ##..........##
// ##############
// This warehouse also uses GPS to locate the boxes. For these larger boxes, distances are measured from the edge of the map to the closest edge of the box in question. So, the box shown below has a distance of 1 from the top edge of the map and 5 from the left edge of the map, resulting in a GPS coordinate of 100 * 1 + 5 = 105.

// ##########
// ##...[]...
// ##........
// In the scaled-up version of the larger example from above, after the robot has finished all of its moves, the warehouse would look like this:

// ####################
// ##[].......[].[][]##
// ##[]...........[].##
// ##[]........[][][]##
// ##[]......[]....[]##
// ##..##......[]....##
// ##..[]............##
// ##..@......[].[][]##
// ##......[][]..[]..##
// ####################
// The sum of these boxes' GPS coordinates is 9021.

// Predict the motion of the robot and boxes in this new, scaled-up warehouse. What is the sum of all boxes' final GPS coordinates?

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    var actions = std.ArrayList(u8).init(allocator);
    defer actions.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        _ = try map.writer().write(line);
        map_width = line.len;
    }
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        _ = try actions.writer().write(line);
    }
    map_height = map.items.len / map_width;
    print_map(map, true);
    std.debug.print("Actions {s} len {d}\n", .{ actions.items, actions.items.len });
    var expanded_map = std.ArrayList(u8).init(allocator);
    for (map.items) |symbol| {
        switch (symbol) {
            '#' => _ = try expanded_map.writer().write("##"),
            'O' => _ = try expanded_map.writer().write("[]"),
            '.' => _ = try expanded_map.writer().write(".."),
            '@' => _ = try expanded_map.writer().write("@."),
            else => unreachable,
        }
    }
    map_width *= 2;
    defer expanded_map.deinit();
    map.deinit();
    print_map(expanded_map, true);
    var robot = Robot{
        .loc = Location.init(std.mem.indexOfScalar(u8, expanded_map.items, '@').?),
    };
    std.debug.print("Robot {any}\n", .{robot});
    for (actions.items) |action| {
        robot.move2(expanded_map, action);
        //print_map(expanded_map, true);
    }
    print_map(expanded_map, true);
    return calc_GPS(expanded_map, '[');
}

test "day15" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Sum of all boxes' GPS coordinates {d} in {d}ms\n", .{ try part1("../inputs/day15/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Sum of all boxes' GPS coordinates {d} in {d}ms\n", .{ try part2("../inputs/day15/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
