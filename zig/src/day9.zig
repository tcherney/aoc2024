const std = @import("std");
// https://adventofcode.com/2024/day/9
// --- Day 9: Disk Fragmenter ---
// Another push of the button leaves you in the familiar hallways of some friendly amphipods! Good thing you each somehow got your own personal mini submarine. The Historians jet away in search of the Chief, mostly by driving directly into walls.

// While The Historians quickly figure out how to pilot these things, you notice an amphipod in the corner struggling with his computer. He's trying to make more contiguous free space by compacting all of the files, but his program isn't working; you offer to help.

// He shows you the disk map (your puzzle input) he's already generated. For example:

// 2333133121414131402
// The disk map uses a dense format to represent the layout of files and free space on the disk. The digits alternate between indicating the length of a file and the length of free space.

// So, a disk map like 12345 would represent a one-block file, two blocks of free space, a three-block file, four blocks of free space, and then a five-block file. A disk map like 90909 would represent three nine-block files in a row (with no free space between them).

// Each file on disk also has an ID number based on the order of the files as they appear before they are rearranged, starting with ID 0. So, the disk map 12345 has three files: a one-block file with ID 0, a three-block file with ID 1, and a five-block file with ID 2. Using one character for each block where digits are the file ID and . is free space, the disk map 12345 represents these individual blocks:

// 0..111....22222
// The first example above, 2333133121414131402, represents these individual blocks:

// 00...111...2...333.44.5555.6666.777.888899
// The amphipod would like to move file blocks one at a time from the end of the disk to the leftmost free space block (until there are no gaps remaining between file blocks). For the disk map 12345, the process looks like this:

// 0..111....22222
// 02.111....2222.
// 022111....222..
// 0221112...22...
// 02211122..2....
// 022111222......
// The first example requires a few more steps:

// 00...111...2...333.44.5555.6666.777.888899
// 009..111...2...333.44.5555.6666.777.88889.
// 0099.111...2...333.44.5555.6666.777.8888..
// 00998111...2...333.44.5555.6666.777.888...
// 009981118..2...333.44.5555.6666.777.88....
// 0099811188.2...333.44.5555.6666.777.8.....
// 009981118882...333.44.5555.6666.777.......
// 0099811188827..333.44.5555.6666.77........
// 00998111888277.333.44.5555.6666.7.........
// 009981118882777333.44.5555.6666...........
// 009981118882777333644.5555.666............
// 00998111888277733364465555.66.............
// 0099811188827773336446555566..............
// The final step of this file-compacting process is to update the filesystem checksum. To calculate the checksum, add up the result of multiplying each of these blocks' position with the file ID number it contains. The leftmost block is in position 0. If a block contains free space, skip it instead.

// Continuing the first example, the first few blocks' position multiplied by its file ID number are 0 * 0 = 0, 1 * 0 = 0, 2 * 9 = 18, 3 * 9 = 27, 4 * 8 = 32, and so on. In this example, the checksum is the sum of these, 1928.

// Compact the amphipod's hard drive using the process he requested. What is the resulting filesystem checksum? (Be careful copy/pasting the input for this puzzle; it is a single, very long line.)

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var result: u64 = 0;
    if (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var decompressed_in = std.ArrayList(i64).init(allocator);
        defer decompressed_in.deinit();
        var current_id: i64 = 0;
        //std.debug.print("line {s}\n", .{line});
        var current_index: usize = 0;
        // decompress
        while (current_index < line.len) {
            const file_len = line[current_index] - 48;
            current_index += 1;
            for (0..file_len) |_| {
                try decompressed_in.append(current_id);
            }
            //std.debug.print("id {d} {d} times\n", .{ current_id, file_len });
            current_id += 1;
            if (current_index < line.len) {
                const free_space_len = line[current_index] - 48;
                current_index += 1;
                for (0..free_space_len) |_| {
                    try decompressed_in.append(-1);
                }
                //std.debug.print("{d} free space\n", .{free_space_len});
            }
        }
        //std.debug.print("decompressed {any}\n", .{decompressed_in.items});
        current_index = decompressed_in.items.len - 1;
        // rotate
        while (true) {
            if (decompressed_in.items[current_index] == -1) {
                current_index -= 1;
                continue;
            }
            var swapped = false;
            for (0..current_index) |i| {
                if (decompressed_in.items[i] == -1) {
                    const tmp = decompressed_in.items[i];
                    decompressed_in.items[i] = decompressed_in.items[current_index];
                    decompressed_in.items[current_index] = tmp;
                    current_index -= 1;
                    swapped = true;
                    break;
                }
            }
            if (!swapped) break;
        }
        //std.debug.print("rotated {any}\n", .{decompressed_in.items});
        // checksum
        for (0..decompressed_in.items.len) |i| {
            if (decompressed_in.items[i] == -1) break;
            result += i * @as(u64, @bitCast(decompressed_in.items[i]));
        }
    }

    return result;
}

// --- Part Two ---
// Upon completion, two things immediately become clear. First, the disk definitely has a lot more contiguous free space, just like the amphipod hoped. Second, the computer is running much more slowly! Maybe introducing all of that file system fragmentation was a bad idea?

// The eager amphipod already has a new plan: rather than move individual blocks, he'd like to try compacting the files on his disk by moving whole files instead.

// This time, attempt to move whole files to the leftmost span of free space blocks that could fit the file. Attempt to move each file exactly once in order of decreasing file ID number starting with the file with the highest file ID number. If there is no span of free space to the left of a file that is large enough to fit the file, the file does not move.

// The first example from above now proceeds differently:

// 00...111...2...333.44.5555.6666.777.888899
// 0099.111...2...333.44.5555.6666.777.8888..
// 0099.1117772...333.44.5555.6666.....8888..
// 0099.111777244.333....5555.6666.....8888..
// 00992111777.44.333....5555.6666.....8888..
// The process of updating the filesystem checksum is the same; now, this example's checksum would be 2858.

// Start over, now compacting the amphipod's hard drive using this new method instead. What is the resulting filesystem checksum?

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var result: u64 = 0;
    if (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var decompressed_in = std.ArrayList(i64).init(allocator);
        defer decompressed_in.deinit();
        var current_id: i64 = 0;
        //std.debug.print("line {s}\n", .{line});
        var current_index: usize = 0;
        // decompress
        while (current_index < line.len) {
            const file_len = line[current_index] - 48;
            current_index += 1;
            for (0..file_len) |_| {
                try decompressed_in.append(current_id);
            }
            //std.debug.print("id {d} {d} times\n", .{ current_id, file_len });
            current_id += 1;
            if (current_index < line.len) {
                const free_space_len = line[current_index] - 48;
                current_index += 1;
                for (0..free_space_len) |_| {
                    try decompressed_in.append(-1);
                }
                //std.debug.print("{d} free space\n", .{free_space_len});
            }
        }
        //std.debug.print("decompressed {any}\n", .{decompressed_in.items});
        current_index = decompressed_in.items.len - 1;
        // rotate
        while (current_index > 0) {
            if (decompressed_in.items[current_index] == -1) {
                current_index -= 1;
                continue;
            }
            // find out how many ids we need to swap
            const id_to_swap = decompressed_in.items[current_index];
            var num_same_id: u64 = 0;
            var j: usize = current_index;
            while (j >= 0) : (j -= 1) {
                if (decompressed_in.items[j] != id_to_swap) break;
                num_same_id += 1;
                if (j == 0) break;
            }
            var can_swap = false;
            var num_free_space: usize = 0;
            var free_space_id: usize = undefined;
            //std.debug.print("id_to_swap {d} current_index {d}, num_same_id {d}\n", .{ id_to_swap, current_index, num_same_id });
            for (0..current_index) |i| {
                if (decompressed_in.items[i] == -1) {
                    num_free_space += 1;
                    // found a block to swap
                    if (num_free_space == num_same_id) {
                        can_swap = true;
                        free_space_id = i - num_free_space + 1;
                        //std.debug.print("free space id {d} num_free_space {d}\n", .{ free_space_id, num_free_space });
                        break;
                    }
                } else {
                    num_free_space = 0;
                }
            }
            if (can_swap) {
                for (0..num_same_id) |i| {
                    const tmp = decompressed_in.items[current_index - i];
                    decompressed_in.items[current_index - i] = decompressed_in.items[free_space_id + i];
                    decompressed_in.items[free_space_id + i] = tmp;
                }
            }
            if (num_same_id >= current_index) break;
            current_index -= num_same_id;
        }
        //std.debug.print("rotated {any}\n", .{decompressed_in.items});
        // checksum
        for (0..decompressed_in.items.len) |i| {
            if (decompressed_in.items[i] == -1) continue;
            result += i * @as(u64, @bitCast(decompressed_in.items[i]));
        }
    }

    return result;
}
test "day9" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Filesystem checksum is {d} in {d}ms\n", .{ try part1("inputs/day9/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Filesystem checksum is {d} in {d}ms\n", .{ try part2("inputs/day9/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
