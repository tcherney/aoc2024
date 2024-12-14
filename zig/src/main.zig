const std = @import("std");
const day14 = @import("day14.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Easter egg at second {d} in {d}ms\n", .{ try day14.part2("../inputs/day14/input.txt", allocator, 101, 103), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Safety factor after 100 seconds {d} in {d}ms\n", .{ try day14.part1("../inputs/day14/input.txt", allocator, 101, 103), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}

test "hello" {
    std.debug.print("hello world", .{});
}
