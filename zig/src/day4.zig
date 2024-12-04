const std = @import("std");
// https://adventofcode.com/2024/day/4

// --- Day 4: Ceres Search ---
// "Looks like the Chief's not here. Next!" One of The Historians pulls out a device and pushes the only button on it. After a brief flash, you recognize the interior of the Ceres monitoring station!

// As the search for the Chief continues, a small Elf who lives on the station tugs on your shirt; she'd like to know if you could help her with her word search (your puzzle input). She only has to find one word: XMAS.

// This word search allows words to be horizontal, vertical, diagonal, written backwards, or even overlapping other words. It's a little unusual, though, as you don't merely need to find one instance of XMAS - you need to find all of them. Here are a few ways XMAS might appear, where irrelevant characters have been replaced with .:

// ..X...
// .SAMX.
// .A..A.
// XMAS.S
// .X....
// The actual word search will be full of letters instead. For example:

// MMMSXXMASM
// MSAMXMSMSA
// AMXSXMAAMM
// MSAMASMSMX
// XMASAMXAMM
// XXAMMXXAMA
// SMSMSASXSS
// SAXAMASAAA
// MAMMMXMMMM
// MXMXAXMASX
// In this word search, XMAS occurs a total of 18 times; here's the same word search again, but where letters not involved in any XMAS have been replaced with .:

// ....XXMAS.
// .SAMXMS...
// ...S..A...
// ..A.A.MS.X
// XMASAMX.MM
// X.....XA.A
// S.S.S.S.SS
// .A.A.A.A.A
// ..M.M.M.MM
// .X.X.XMASX
// Take a look at the little Elf's word search. How many times does XMAS appear?

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

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var word_search = std.ArrayList(u8).init(allocator);
    defer word_search.deinit();
    var width: usize = undefined;
    var buf: [4096]u8 = undefined;
    var result: u64 = 0;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        width = line.len;
        try word_search.appendSlice(line);
    }
    const height = word_search.items.len / width;
    var indx: usize = 0;
    while (indx < word_search.items.len) {
        const search_pos = std.mem.indexOfScalarPos(u8, word_search.items, indx, 'X');
        if (search_pos) |pos| {
            indx = pos + 1;
            const xy = indx_to_x_y(pos, width);
            //backwards
            if (xy.x >= 3) {
                if (word_search.items[xy.y * width + xy.x - 1] == 'M' and word_search.items[xy.y * width + xy.x - 2] == 'A' and word_search.items[xy.y * width + xy.x - 3] == 'S') {
                    result += 1;
                }
            }
            //forwards
            if (xy.x + 3 < width) {
                if (word_search.items[xy.y * width + xy.x + 1] == 'M' and word_search.items[xy.y * width + xy.x + 2] == 'A' and word_search.items[xy.y * width + xy.x + 3] == 'S') {
                    result += 1;
                }
            }
            //up
            if (xy.y >= 3) {
                if (word_search.items[(xy.y - 1) * width + xy.x] == 'M' and word_search.items[(xy.y - 2) * width + xy.x] == 'A' and word_search.items[(xy.y - 3) * width + xy.x] == 'S') {
                    result += 1;
                }
            }
            //down
            if (xy.y + 3 < height) {
                if (word_search.items[(xy.y + 1) * width + xy.x] == 'M' and word_search.items[(xy.y + 2) * width + xy.x] == 'A' and word_search.items[(xy.y + 3) * width + xy.x] == 'S') {
                    result += 1;
                }
            }
            //diagupforward
            if (xy.y >= 3 and xy.x + 3 < width) {
                if (word_search.items[(xy.y - 1) * width + xy.x + 1] == 'M' and word_search.items[(xy.y - 2) * width + xy.x + 2] == 'A' and word_search.items[(xy.y - 3) * width + xy.x + 3] == 'S') {
                    result += 1;
                }
            }
            //diagdownforward
            if (xy.y + 3 < height and xy.x + 3 < width) {
                if (word_search.items[(xy.y + 1) * width + xy.x + 1] == 'M' and word_search.items[(xy.y + 2) * width + xy.x + 2] == 'A' and word_search.items[(xy.y + 3) * width + xy.x + 3] == 'S') {
                    result += 1;
                }
            }
            //diagupbackward
            if (xy.y >= 3 and xy.x >= 3) {
                if (word_search.items[(xy.y - 1) * width + xy.x - 1] == 'M' and word_search.items[(xy.y - 2) * width + xy.x - 2] == 'A' and word_search.items[(xy.y - 3) * width + xy.x - 3] == 'S') {
                    result += 1;
                }
            }
            //diagdownbackward
            if (xy.y + 3 < height and xy.x >= 3) {
                if (word_search.items[(xy.y + 1) * width + xy.x - 1] == 'M' and word_search.items[(xy.y + 2) * width + xy.x - 2] == 'A' and word_search.items[(xy.y + 3) * width + xy.x - 3] == 'S') {
                    result += 1;
                }
            }
        } else break;
    }
    return result;
}

// --- Part Two ---
// The Elf looks quizzically at you. Did you misunderstand the assignment?

// Looking for the instructions, you flip over the word search to find that this isn't actually an XMAS puzzle; it's an X-MAS puzzle in which you're supposed to find two MAS in the shape of an X. One way to achieve that is like this:

// M.S
// .A.
// M.S
// Irrelevant characters have again been replaced with . in the above diagram. Within the X, each MAS can be written forwards or backwards.

// Here's the same example from before, but this time all of the X-MASes have been kept instead:

// .M.S......
// ..A..MSMS.
// .M.S.MAA..
// ..A.ASMSM.
// .M.S.M....
// ..........
// S.S.S.S.S.
// .A.A.A.A..
// M.M.M.M.M.
// ..........
// In this example, an X-MAS appears 9 times.

// Flip the word search from the instructions back over to the word search side and try again. How many times does an X-MAS appear?
//TODO  center search around the middle A search the corners for the 4 possible configurations
pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = file_name;
    _ = allocator;
}
test "day4" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    std.debug.print("XMAS appears {d} times\n", .{try part1("inputs/day4/input.txt", allocator)});
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
