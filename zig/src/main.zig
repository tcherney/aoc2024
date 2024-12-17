const std = @import("std");
const day16 = @import("day16.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var timer = try std.time.Timer.start();
    std.debug.print("Lowest score {d} in {d}ms\n", .{ try day16.part1("../inputs/day16/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    std.debug.print("Tiles in shortest paths {d} in {d}ms\n", .{ try day16.part2("../inputs/day16/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}

test "hello" {
    std.debug.print("hello world", .{});
}
