const std = @import("std");
// https://adventofcode.com/2024/day/25
// --- Day 25: Code Chronicle ---
// Out of ideas and time, The Historians agree that they should go back to check the Chief Historian's office one last time, just in case he went back there without you noticing.

// When you get there, you are surprised to discover that the door to his office is locked! You can hear someone inside, but knocking yields no response. The locks on this floor are all fancy, expensive, virtual versions of five-pin tumbler locks, so you contact North Pole security to see if they can help open the door.

// Unfortunately, they've lost track of which locks are installed and which keys go with them, so the best they can do is send over schematics of every lock and every key for the floor you're on (your puzzle input).

// The schematics are in a cryptic file format, but they do contain manufacturer information, so you look up their support number.

// "Our Virtual Five-Pin Tumbler product? That's our most expensive model! Way more secure than--" You explain that you need to open a door and don't have a lot of time.

// "Well, you can't know whether a key opens a lock without actually trying the key in the lock (due to quantum hidden variables), but you can rule out some of the key/lock combinations."

// "The virtual system is complicated, but part of it really is a crude simulation of a five-pin tumbler lock, mostly for marketing reasons. If you look at the schematics, you can figure out whether a key could possibly fit in a lock."

// He transmits you some example schematics:

// #####
// .####
// .####
// .####
// .#.#.
// .#...
// .....

// #####
// ##.##
// .#.##
// ...##
// ...#.
// ...#.
// .....

// .....
// #....
// #....
// #...#
// #.#.#
// #.###
// #####

// .....
// .....
// #.#..
// ###..
// ###.#
// ###.#
// #####

// .....
// .....
// .....
// #....
// #.#..
// #.#.#
// #####
// "The locks are schematics that have the top row filled (#) and the bottom row empty (.); the keys have the top row empty and the bottom row filled. If you look closely, you'll see that each schematic is actually a set of columns of various heights, either extending downward from the top (for locks) or upward from the bottom (for keys)."

// "For locks, those are the pins themselves; you can convert the pins in schematics to a list of heights, one per column. For keys, the columns make up the shape of the key where it aligns with pins; those can also be converted to a list of heights."

// "So, you could say the first lock has pin heights 0,5,3,4,3:"

// #####
// .####
// .####
// .####
// .#.#.
// .#...
// .....
// "Or, that the first key has heights 5,0,2,1,3:"

// .....
// #....
// #....
// #...#
// #.#.#
// #.###
// #####
// "These seem like they should fit together; in the first four columns, the pins and key don't overlap. However, this key cannot be for this lock: in the rightmost column, the lock's pin overlaps with the key, which you know because in that column the sum of the lock height and key height is more than the available space."

// "So anyway, you can narrow down the keys you'd need to try by just testing each key with each lock, which means you would have to check... wait, you have how many locks? But the only installation that size is at the North--" You disconnect the call.

// In this example, converting both locks to pin heights produces:

// 0,5,3,4,3
// 1,2,0,5,3
// Converting all three keys to heights produces:

// 5,0,2,1,3
// 4,3,4,0,2
// 3,0,2,0,1
// Then, you can try every key with every lock:

// Lock 0,5,3,4,3 and key 5,0,2,1,3: overlap in the last column.
// Lock 0,5,3,4,3 and key 4,3,4,0,2: overlap in the second column.
// Lock 0,5,3,4,3 and key 3,0,2,0,1: all columns fit!
// Lock 1,2,0,5,3 and key 5,0,2,1,3: overlap in the first column.
// Lock 1,2,0,5,3 and key 4,3,4,0,2: all columns fit!
// Lock 1,2,0,5,3 and key 3,0,2,0,1: all columns fit!
// So, in this example, the number of unique lock/key pairs that fit together without overlapping in any column is 3.

// Analyze your lock and key schematics. How many unique lock/key pairs fit together without overlapping in any column?
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
var num_buf: [4096]u8 = undefined;
var scratch_str: std.ArrayList(u8) = undefined;
const DEBUG = false;

const MAX_COLS = 5;
pub const Lock = struct {
    cols: [MAX_COLS]u64 = [_]u64{0} ** MAX_COLS,
    pub fn add_pin(self: *Lock, indx: usize) void {
        self.cols[indx] += 1;
    }
    pub fn unlockable(self: *Lock, key: Key) bool {
        for (0..self.cols.len) |i| {
            if (self.cols[i] + key.cols[i] > MAX_COLS) return false;
        }
        return true;
    }
};

pub const Key = struct {
    cols: [MAX_COLS]u64 = [_]u64{0} ** MAX_COLS,
    pub fn add_pin(self: *Key, indx: usize) void {
        self.cols[indx] += 1;
    }
};

pub fn add_key(keys: *std.ArrayList(std.ArrayList(u8)), key: []const u8, allocator: std.mem.Allocator) !u64 {
    for (0..keys.items.len) |i| {
        if (keys.items[i].items[0] == key[0] and keys.items[i].items[1] == key[1] and keys.items[i].items[2] == key[2]) return i;
    }
    try keys.append((std.ArrayList(u8).init(allocator)));
    _ = try keys.items[keys.items.len - 1].writer().write(key);
    return keys.items.len - 1;
}

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var locks = std.ArrayList(Lock).init(allocator);
    defer locks.deinit();
    var keys = std.ArrayList(Key).init(allocator);
    defer keys.deinit();

    // var keys = std.ArrayList(std.ArrayList(u8)).init(allocator);
    // defer keys.deinit();
    var is_key = false;
    var is_lock = false;
    var rows_parsed: usize = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) {
            is_key = false;
            is_lock = false;
            continue;
        }
        if (!is_key and !is_lock) {
            if (std.mem.count(u8, line, "#") == 5) {
                is_lock = true;
                is_key = false;
                try locks.append(Lock{});
            } else {
                is_key = true;
                is_lock = false;
                try keys.append(Key{});
            }
            rows_parsed = 0;
        } else if (is_key and rows_parsed < MAX_COLS) {
            for (0..5) |i| {
                if (line[i] == '#') {
                    keys.items[keys.items.len - 1].add_pin(i);
                }
            }
            rows_parsed += 1;
        } else if (is_lock and rows_parsed < MAX_COLS) {
            for (0..5) |i| {
                if (line[i] == '#') {
                    locks.items[locks.items.len - 1].add_pin(i);
                }
            }
            rows_parsed += 1;
        }
    }
    std.debug.print("Locks:\n", .{});
    for (0..locks.items.len) |i| {
        std.debug.print("{any}\n", .{locks.items[i].cols});
    }
    std.debug.print("Keys:\n", .{});
    for (0..keys.items.len) |i| {
        std.debug.print("{any}\n", .{keys.items[i].cols});
    }
    var lock_key_combo: u64 = 0;
    for (0..locks.items.len) |i| {
        for (0..keys.items.len) |j| {
            if (locks.items[i].unlockable(keys.items[j])) {
                lock_key_combo += 1;
            }
        }
    }

    return lock_key_combo;
}

fn compareStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}

// --- Part Two ---
// You and The Historians crowd into the office, startling the Chief Historian awake! The Historians all take turns looking confused until one asks where he's been for the last few months.

// "I've been right here, working on this high-priority request from Santa! I think the only time I even stepped away was about a month ago when I went to grab a cup of coffee..."

// Just then, the Chief notices the time. "Oh no! I'm going to be late! I must have fallen asleep trying to put the finishing touches on this chronicle Santa requested, but now I don't have enough time to go visit the last 50 places on my list and complete the chronicle before Santa leaves! He said he needed it before tonight's sleigh launch."

// One of The Historians holds up the list they've been using this whole time to keep track of where they've been searching. Next to each place you all visited, they checked off that place with a star. Other Historians hold up their own notes they took on the journey; as The Historians, how could they resist writing everything down while visiting all those historically significant places?

// The Chief's eyes get wide. "With all this, we might just have enough time to finish the chronicle! Santa said he wanted it wrapped up with a bow, so I'll call down to the wrapping department and... hey, could you bring it up to Santa? I'll need to be in my seat to watch the sleigh launch by then."

// You nod, and The Historians quickly work to collect their notes into the final set of pages for the chronicle.

//NA
pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = file_name;
    _ = allocator;
    return 0;
}

test "day25" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Key combos {d} in {d}ms\n", .{ try part1("../inputs/day25/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    //std.debug.print("{d} in {d}ms\n", .{ try part2("../inputs/day25/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
