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
    lights: u64,
    buttons: std.ArrayList(u64),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Machine {
        return .{
            .lights = 0,
            .buttons = std.ArrayList(u64).init(allocator),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *Machine) void {
        self.buttons.deinit();
    }
};

pub const MachineV2 = struct {
    buttons: std.ArrayList(std.ArrayList(u64)),
    joltages: std.ArrayList(u64),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) MachineV2 {
        return .{
            .buttons = std.ArrayList(std.ArrayList(u64)).init(allocator),
            .joltages = std.ArrayList(u64).init(allocator),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *MachineV2) void {
        self.joltages.deinit();
        for (self.buttons.items) |b| {
            b.deinit();
        }
        self.buttons.deinit();
    }

    pub fn find(items: std.ArrayList(u64), val: u64) bool {
        for (0..items.items.len) |i| {
            if (items.items[i] == val) return true;
        }
        return false;
    }

    pub fn swap_rows(mat: [][]f64, row1: usize, row2: usize) void {
        for (0..mat[0].len) |c| {
            const temp = mat[row1][c];
            mat[row1][c] = mat[row2][c];
            mat[row2][c] = temp;
        }
    }

    pub fn solve(self: *const MachineV2) !u64 {
        const cols = self.buttons.items.len + 1;
        const rows = self.joltages.items.len;
        var mat = try self.allocator.alloc([]f64, rows);
        defer self.allocator.free(mat);
        for (0..rows) |r| {
            mat[r] = try self.allocator.alloc(f64, cols);
            for (0..cols) |c| {
                if (c == cols - 1) {
                    mat[r][c] = @floatFromInt(self.joltages.items[r]);
                } else if (find(self.buttons.items[c], r)) {
                    mat[r][c] = 1;
                } else {
                    mat[r][c] = 0;
                }
                std.debug.print("{d}", .{mat[r][c]});
            }
            std.debug.print("\n", .{});
        }
        for (0..rows) |r| {
            var before: bool = false;
            for (0..cols) |c| {
                if (c == cols - 1) {
                    std.debug.print("= {d} ", .{mat[r][c]});
                } else if (mat[r][c] == 1) {
                    if (before) {
                        std.debug.print("+ x{d} ", .{c});
                    } else {
                        std.debug.print("x{d} ", .{c});
                        before = true;
                    }
                }
            }
            std.debug.print("\n", .{});
        }
        // ---------
        for (0..@min(cols, rows)) |k| {
            var i_max: usize = k;
            var v_max = mat[i_max][k];
            for (k + 1..rows) |i| {
                if (@abs(mat[i][k]) > v_max) {
                    v_max = mat[i][k];
                    i_max = i;
                }
            }
            if (i_max != k) {
                for (0..cols) |c| {
                    const temp = mat[k][c];
                    mat[k][c] = mat[i_max][c];
                    mat[i_max][c] = temp;
                }
            }
            for (k + 1..rows) |l| {
                const f = mat[l][k] / mat[k][k];
                for (k + 1..cols) |j| {
                    mat[l][j] -= mat[k][j] * f;
                }
                mat[l][k] = 0;
            }
        }
        std.debug.print("------------\n", .{});
        for (0..rows) |r| {
            for (0..cols) |c| {
                std.debug.print("{d}", .{mat[r][c]});
            }
            std.debug.print("\n", .{});
        }

        var x = try self.allocator.alloc(f64, cols);
        @memset(x, 0);
        defer self.allocator.free(x);
        var i: usize = rows - 1;
        while (i >= 0) : (i -= 1) {
            if (i + 1 < cols) {
                x[i] = mat[i][cols - 1];
                for (i + 1..cols) |j| {
                    x[i] -= mat[i][j] * x[j];
                }
                x[i] = x[i] / mat[i][i];
            }
            if (i == 0) break;
        }

        // for (0..rows) |i| {
        //     if (mat[i][i] == 0) {
        //         var c: usize = 1;
        //         while ((i + c) < rows and mat[i + c][i] == 0) {
        //             c += 1;
        //         }
        //         if ((i + c) == rows) {
        //             break;
        //         }
        //         const j = i;
        //         for (0..cols) |k| {
        //             const temp = mat[j][k];
        //             mat[j][k] = mat[j + c][k];
        //             mat[j + c][k] = temp;
        //         }
        //     }
        //     for (0..rows) |j| {
        //         if (i != j) {
        //             const p = mat[j][i] / mat[i][i];
        //             for (0..cols) |k| {
        //                 mat[j][k] = mat[j][k] - mat[i][k] * p;
        //             }
        //         }
        //     }
        // }
        // ---------------
        std.debug.print("------------\n", .{});
        for (0..rows) |r| {
            for (0..cols) |c| {
                std.debug.print("{d}", .{mat[r][c]});
            }
            std.debug.print("\n", .{});
        }
        for (0..rows) |r| {
            var before: bool = false;
            for (0..cols) |c| {
                if (c == cols - 1) {
                    std.debug.print("= {d} ", .{mat[r][c]});
                } else if (mat[r][c] != 0) {
                    if (before) {
                        if (mat[r][c] != 1) {
                            if (mat[r][c] < 0) {
                                std.debug.print("-", .{});
                            } else {
                                std.debug.print("+", .{});
                            }
                            std.debug.print(" {d}x{d} ", .{ mat[r][c], c });
                        } else {
                            std.debug.print("+ x{d} ", .{c});
                        }
                    } else {
                        if (mat[r][c] == 1) {
                            std.debug.print("x{d} ", .{c});
                        } else {
                            std.debug.print("{d}x{d} ", .{ mat[r][c], c });
                        }
                        before = true;
                    }
                }
            }
            std.debug.print("\n", .{});
            defer self.allocator.free(mat[r]);
        }
        return 0;
    }
};

pub const State = struct {
    state: u64,
    buttons_left: std.ArrayList(u64),
    cost: u64,
};

pub const Queue = std.ArrayList(State);

pub fn combinations(allocator: std.mem.Allocator, sequence: []u64, length: usize) !std.ArrayList(std.ArrayList(u64)) {
    var combos = std.ArrayList(std.ArrayList(u64)).init(allocator);
    for (0..sequence.len) |i| {
        const rem_items = sequence[i + 1 ..];
        const item = sequence[i];
        if (length > 1) {
            const rem_combos = try combinations(allocator, rem_items, length - 1);
            defer rem_combos.deinit();
            for (0..rem_combos.items.len) |j| {
                try rem_combos.items[j].append(item);
                try combos.append(rem_combos.items[j]);
            }
        } else {
            var new_combo = std.ArrayList(u64).init(allocator);
            try new_combo.append(item);
            try combos.append(new_combo);
        }
    }
    return combos;
}

pub fn min_pressesv2(machine: Machine) !u64 {
    for (1..machine.buttons.items.len) |presses| {
        var combos = try combinations(machine.allocator, machine.buttons.items, presses);
        defer {
            for (0..combos.items.len) |i| {
                combos.items[i].deinit();
            }
            combos.deinit();
        }
        //std.debug.print("Combos\n", .{});
        for (combos.items) |c| {
            var state: u64 = 0;
            for (c.items) |b| {
                //std.debug.print("{d} ", .{b});
                state ^= b;
            }
            //std.debug.print("\n", .{});
            if (state == machine.lights) {
                return c.items.len;
            }
        }
    }
    return 100000;
}

pub fn min_presses(machine: Machine) !u64 {
    var q = Queue.init(machine.allocator);
    defer {
        for (0..q.items.len) |i| {
            q.items[i].buttons_left.deinit();
        }
        q.deinit();
    }
    const starting_buttons = try machine.buttons.clone();
    try q.append(State{
        .state = 0,
        .buttons_left = starting_buttons,
        .cost = 0,
    });
    var visited = std.AutoHashMap(u64, bool).init(machine.allocator);
    defer visited.deinit();
    while (q.items.len > 0) {
        const s = q.orderedRemove(0);
        defer s.buttons_left.deinit();
        if (s.state == machine.lights) {
            return s.cost;
        }
        try visited.put(s.state, true);
        for (s.buttons_left.items) |b| {
            const new_state = s.state ^ b;
            if (visited.get(new_state) == null) {
                var new_buttons = try s.buttons_left.clone();
                for (0..new_buttons.items.len) |i| {
                    if (new_buttons.items[i] == b) {
                        _ = new_buttons.swapRemove(i);
                        //std.debug.print("Removed {d}\n", .{i});
                        break;
                    }
                }
                try q.append(.{
                    .state = new_state,
                    .buttons_left = new_buttons,
                    .cost = s.cost + 1,
                });
            }
        }
    }
    return std.math.maxInt(u64);
}

pub fn day10_p2(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day10/small.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var machines = std.ArrayList(MachineV2).init(self.allocator);
    defer machines.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        var machine = MachineV2.init(self.allocator);
        var curr_indx: usize = 0;
        while (std.mem.indexOfScalarPos(u8, line, curr_indx, '(')) |bracket| {
            const other_bracket = std.mem.indexOfScalarPos(u8, line, bracket, ')').?;
            var iter = std.mem.splitScalar(u8, line[bracket + 1 .. other_bracket], ',');
            var button = std.ArrayList(u64).init(self.allocator);
            while (iter.next()) |n| {
                try button.append(try std.fmt.parseInt(u64, n, 10));
            }
            try machine.buttons.append(button);
            curr_indx = other_bracket + 1;
        }

        while (std.mem.indexOfScalarPos(u8, line, curr_indx, '{')) |bracket| {
            const other_bracket = std.mem.indexOfScalarPos(u8, line, bracket, '}').?;
            var iter = std.mem.splitScalar(u8, line[bracket + 1 .. other_bracket], ',');
            while (iter.next()) |n| {
                try machine.joltages.append(try std.fmt.parseInt(u64, n, 10));
            }
            curr_indx = other_bracket + 1;
        }
        try machines.append(machine);
    }
    var fewest_presses: u64 = 0;
    var j: usize = 0;
    for (machines.items) |m| {
        //std.debug.print("Machine {d}\n", .{j});
        j += 1;
        fewest_presses += try m.solve();
    }
    for (0..machines.items.len) |i| {
        machines.items[i].deinit();
    }
    std.debug.print("Fewest possible presses: {d}\n", .{fewest_presses});
}

pub fn day10_p1(self: anytype) !void {
    const f = try std.fs.cwd().openFile("inputs/day10/input.txt", .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var machines = std.ArrayList(Machine).init(self.allocator);
    defer machines.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        if (line.len == 0) break;
        const start_light = std.mem.indexOfScalar(u8, line, '[') orelse continue;
        const end_light = std.mem.indexOfScalar(u8, line, ']') orelse continue;
        var machine = Machine.init(self.allocator);
        const lights = line[start_light + 1 .. end_light];
        var light: u64 = 0;
        var offset: u64 = 1;
        for (lights) |l| {
            if (l == '#') {
                light |= offset;
            }
            offset <<= 1;
        }
        machine.lights = light;
        var curr_indx = end_light + 1;
        while (std.mem.indexOfScalarPos(u8, line, curr_indx, '(')) |bracket| {
            const other_bracket = std.mem.indexOfScalarPos(u8, line, bracket, ')').?;
            var iter = std.mem.splitScalar(u8, line[bracket + 1 .. other_bracket], ',');
            var button: u64 = 0;
            while (iter.next()) |n| {
                button |= @as(u64, 1) << (try std.fmt.parseInt(u6, n, 10));
            }
            try machine.buttons.append(button);
            curr_indx = other_bracket + 1;
        }

        try machines.append(machine);
    }
    var fewest_presses: u64 = 0;
    var j: usize = 0;
    try common.timer_start();
    for (machines.items) |m| {
        //std.debug.print("Machine {d}\n", .{j});
        j += 1;
        fewest_presses += try min_pressesv2(m);
    }
    for (0..machines.items.len) |i| {
        machines.items[i].deinit();
    }
    std.debug.print("Fewest possible presses: {d}\nIn {d} seconds.\n", .{ fewest_presses, common.timer_end() });
}
