// --- Day 10: Factory ---
// Just across the hall, you find a large factory. Fortunately, the Elves here have plenty of time to decorate. Unfortunately, it's because the factory machines are all offline, and none of the Elves can figure out the initialization procedure.

// The Elves do have the manual for the machines, but the section detailing the initialization procedure was eaten by a Shiba Inu. All that remains of the manual are some indicator light diagrams, button wiring schematics, and joltage requirements for each machine.

// For example:

// [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
// [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
// [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
// The manual describes one machine per line. Each line contains a single indicator light diagram in [square brackets], one or more button wiring schematics in (parentheses), and joltage requirements in {curly braces}.

// To start a machine, its indicator lights must match those shown in the diagram, where . means off and # means on. The machine has the number of indicator lights shown, but its indicator lights are all initially off.

// So, an indicator light diagram like [.##.] means that the machine has four indicator lights which are initially off and that the goal is to simultaneously configure the first light to be off, the second light to be on, the third to be on, and the fourth to be off.

// You can toggle the state of indicator lights by pushing any of the listed buttons. Each button lists which indicator lights it toggles, where 0 means the first light, 1 means the second light, and so on. When you push a button, each listed indicator light either turns on (if it was off) or turns off (if it was on). You have to push each button an integer number of times; there's no such thing as "0.5 presses" (nor can you push a button a negative number of times).

// So, a button wiring schematic like (0,3,4) means that each time you push that button, the first, fourth, and fifth indicator lights would all toggle between on and off. If the indicator lights were [#.....], pushing the button would change them to be [...##.] instead.

// Because none of the machines are running, the joltage requirements are irrelevant and can be safely ignored.

// You can push each button as many times as you like. However, to save on time, you will need to determine the fewest total presses required to correctly configure all indicator lights for all machines in your list.

// There are a few ways to correctly configure the first machine:

// [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
// You could press the first three buttons once each, a total of 3 button presses.
// You could press (1,3) once, (2,3) once, and (0,1) twice, a total of 4 button presses.
// You could press all of the buttons except (1,3) once each, a total of 5 button presses.
// However, the fewest button presses required is 2. One way to do this is by pressing the last two buttons ((0,2) and (0,1)) once each.

// The second machine can be configured with as few as 3 button presses:

// [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
// One way to achieve this is by pressing the last three buttons ((0,4), (0,1,2), and (1,2,3,4)) once each.

// The third machine has a total of six indicator lights that need to be configured correctly:

// [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
// The fewest presses required to correctly configure it is 2; one way to do this is by pressing buttons (0,3,4) and (0,1,2,4,5) once each.

// So, the fewest button presses required to correctly configure the indicator lights on all of the machines is 2 + 3 + 2 = 7.

// Analyze each machine's indicator light diagram and button wiring schematics. What is the fewest button presses required to correctly configure the indicator lights on all of the machines?

const std = @import("std");
const common = @import("common");

pub const Machine = struct {
    lights: []u8,
    buttons: std.ArrayList(std.ArrayList(usize)),
    joltages: std.ArrayList(usize),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Machine {
        return .{
            .lights = std.ArrayList(u8).init(allocator),
            .buttons = std.ArrayList(std.ArrayList(usize)).init(allocator),
            .joltages = std.ArrayList(usize),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *Machine) void {
        self.allocator.free(self.lights);
        self.joltages.deinit();
        for (0..self.buttons.items.len) |i| {
            self.buttons.items[i].deinit();
        }
        self.buttons.deinit();
    }
};

pub fn day10_p2(_: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day10/small.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
    }
}

var dp: common.StringKeyMap(usize) = undefined;
//TODO sounds like we can do a DP with input state storing min presses
pub fn min_presses(machine: Machine, state: []u8) !usize {
    const e = try dp.getOrPut(state);
    if (e.found_existing) return e.value_ptr.*;
    if (std.mem.eql(u8, machine.lights, state)) {
        e.value_ptr.* = 0;
    } else {
        //TODO prob have to alloc state for each button press, try each button and recurse
        var min_val: usize = std.math.maxInt(usize);
        for (machine.buttons.items) |b| {
            var new_state = try machine.allocator.dupe(u8, state);
            defer machine.allocator.free(new_state);
            for (b.items) |i| {
                if (new_state[i] == '.') {
                    new_state[i] = '#';
                } else {
                    new_state[i] = '.';
                }
            }
            min_val = @min(min_val, 1 + try min_presses(machine, new_state));
        }
        e.value_ptr.* = min_val;
    }
    return e.value_ptr.*;
}

pub fn day10_p1(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day10/small.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var machines = std.ArrayList(Machine).init(self.allocator);
    defer machines.deinit();
    dp = common.StringKeyMap(usize).init(self.allocator);
    defer dp.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        const start_light = std.mem.indexOfScalar(u8, line, '[') orelse continue;
        const end_light = std.mem.indexOfScalar(u8, line, ']') orelse continue;
        var machine = Machine.init(self.allocator);
        machine.lights = self.allocator.alloc(u8, end_light - start_light + 1);
        @memcpy(machine.lights, line[start_light + 1 .. end_light]);
        var curr_indx = end_light + 1;
        while (std.mem.indexOfScalarPos(u8, line, curr_indx, '(')) |bracket| {
            const other_bracket = std.mem.indexOfScalarPos(u8, line, bracket, ')').?;
            var iter = std.mem.splitScalar(u8, line[bracket + 1 .. other_bracket], ',');
            var button = std.ArrayList(usize).init(self.allocator);
            while (iter.next()) |n| {
                try button.append(std.fmt.parseInt(usize, n, 10));
            }
            try machine.buttons.append(button);
            curr_indx = other_bracket + 1;
        }

        while (std.mem.indexOfScalarPos(u8, line, curr_indx, '{')) |bracket| {
            const other_bracket = std.mem.indexOfScalarPos(u8, line, bracket, '}').?;
            var iter = std.mem.splitScalar(u8, line[bracket + 1 .. other_bracket], ',');
            while (iter.next()) |n| {
                try machine.joltages.append(std.fmt.parseInt(usize, n, 10));
            }
            curr_indx = other_bracket + 1;
        }
        try machines.append(machine);
    }
    var fewest_presses: usize = 0;
    for (machines.items) |m| {
        var state = self.allocator.alloc(u8, m.lights.len);
        defer self.allocator.free(state);
        @memset(state, '.');
        fewest_presses += try min_presses(m, &state);
    }
    std.debug.print("Fewest possible presses: {d}\n", .{fewest_presses});
}
