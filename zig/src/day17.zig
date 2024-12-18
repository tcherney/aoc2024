const std = @import("std");
// https://adventofcode.com/2024/day/17
// --- Day 17: Chronospatial Computer ---
// The Historians push the button on their strange device, but this time, you all just feel like you're falling.

// "Situation critical", the device announces in a familiar voice. "Bootstrapping process failed. Initializing debugger...."

// The small handheld device suddenly unfolds into an entire computer! The Historians look around nervously before one of them tosses it to you.

// This seems to be a 3-bit computer: its program is a list of 3-bit numbers (0 through 7), like 0,1,2,3. The computer also has three registers named A, B, and C, but these registers aren't limited to 3 bits and can instead hold any integer.

// The computer knows eight instructions, each identified by a 3-bit number (called the instruction's opcode). Each instruction also reads the 3-bit number after it as an input; this is called its operand.

// A number called the instruction pointer identifies the position in the program from which the next opcode will be read; it starts at 0, pointing at the first 3-bit number in the program. Except for jump instructions, the instruction pointer increases by 2 after each instruction is processed (to move past the instruction's opcode and its operand). If the computer tries to read an opcode past the end of the program, it instead halts.

// So, the program 0,1,2,3 would run the instruction whose opcode is 0 and pass it the operand 1, then run the instruction having opcode 2 and pass it the operand 3, then halt.

// There are two types of operands; each instruction specifies the type of its operand. The value of a literal operand is the operand itself. For example, the value of the literal operand 7 is the number 7. The value of a combo operand can be found as follows:

// Combo operands 0 through 3 represent literal values 0 through 3.
// Combo operand 4 represents the value of register A.
// Combo operand 5 represents the value of register B.
// Combo operand 6 represents the value of register C.
// Combo operand 7 is reserved and will not appear in valid programs.
// The eight instructions are as follows:

// The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.

// The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.

// The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.

// The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.

// The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)

// The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)

// The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)

// The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)

// Here are some examples of instruction operation:

// If register C contains 9, the program 2,6 would set register B to 1.
// If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
// If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
// If register B contains 29, the program 1,7 would set register B to 26.
// If register B contains 2024 and register C contains 43690, the program 4,0 would set register B to 44354.
// The Historians' strange device has finished initializing its debugger and is displaying some information about the program it is trying to run (your puzzle input). For example:

// Register A: 729
// Register B: 0
// Register C: 0

// Program: 0,1,5,4,3,0
// Your first task is to determine what the program is trying to output. To do this, initialize the registers to the given values, then run the given program, collecting any output produced by out instructions. (Always join the values produced by out instructions with commas.) After the above program halts, its final output will be 4,6,3,5,6,3,5,2,1,0.

// Using the information provided by the debugger, initialize the registers to the given values, then run the program. Once it halts, what do you get if you use commas to join the values it output into a single string?

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
var num_buf: [1024]u8 = undefined;
var scratch_str: std.ArrayList(u8) = undefined;
const DEBUG = true;

pub const Instruction = struct {
    opcode: Opcode,
    operand: u3,
    pub const Opcode = enum(u3) {
        adv = 0,
        bxl = 1,
        bst = 2,
        jnz = 3,
        bxc = 4,
        out = 5,
        bdv = 6,
        cdv = 7,
    };
    pub fn init(opcode: u8, operand: u8) Instruction {
        return Instruction{
            .opcode = @enumFromInt(@as(u3, @intCast(opcode - 48))),
            .operand = @as(u3, @intCast(operand - 48)),
        };
    }

    pub fn str(self: *Instruction) ![]u8 {
        scratch_str.clearRetainingCapacity();
        switch (self.opcode) {
            .adv => {
                try scratch_str.writer().print("adv ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        try scratch_str.writer().print("{d}", .{self.operand});
                    },
                    4 => {
                        try scratch_str.writer().print("A", .{});
                    },
                    5 => {
                        try scratch_str.writer().print("B", .{});
                    },
                    6 => {
                        try scratch_str.writer().print("C", .{});
                    },
                    7 => unreachable,
                }
            },
            .bxl => {
                try scratch_str.writer().print("bxl ", .{});
                try scratch_str.writer().print("{d}", .{self.operand});
            },
            .bst => {
                try scratch_str.writer().print("bst ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        try scratch_str.writer().print("{d}", .{self.operand});
                    },
                    4 => {
                        try scratch_str.writer().print("A", .{});
                    },
                    5 => {
                        try scratch_str.writer().print("B", .{});
                    },
                    6 => {
                        try scratch_str.writer().print("C", .{});
                    },
                    7 => unreachable,
                }
            },
            .jnz => {
                try scratch_str.writer().print("jnz ", .{});
                try scratch_str.writer().print("{d}", .{self.operand});
            },
            .bxc => {
                try scratch_str.writer().print("bxc", .{});
            },
            .out => {
                try scratch_str.writer().print("out ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        try scratch_str.writer().print("{d}", .{self.operand});
                    },
                    4 => {
                        try scratch_str.writer().print("A", .{});
                    },
                    5 => {
                        try scratch_str.writer().print("B", .{});
                    },
                    6 => {
                        try scratch_str.writer().print("C", .{});
                    },
                    7 => unreachable,
                }
            },
            .bdv => {
                try scratch_str.writer().print("bdv ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        try scratch_str.writer().print("{d}", .{self.operand});
                    },
                    4 => {
                        try scratch_str.writer().print("A", .{});
                    },
                    5 => {
                        try scratch_str.writer().print("B", .{});
                    },
                    6 => {
                        try scratch_str.writer().print("C", .{});
                    },
                    7 => unreachable,
                }
            },
            .cdv => {
                try scratch_str.writer().print("cdv ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        try scratch_str.writer().print("{d}", .{self.operand});
                    },
                    4 => {
                        try scratch_str.writer().print("A", .{});
                    },
                    5 => {
                        try scratch_str.writer().print("B", .{});
                    },
                    6 => {
                        try scratch_str.writer().print("C", .{});
                    },
                    7 => unreachable,
                }
            },
        }
        return scratch_str.items;
    }

    pub fn print(self: *Instruction) void {
        switch (self.opcode) {
            .adv => {
                std.debug.print("adv ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        std.debug.print("{d}\n", .{self.operand});
                    },
                    4 => {
                        std.debug.print("A\n", .{});
                    },
                    5 => {
                        std.debug.print("B\n", .{});
                    },
                    6 => {
                        std.debug.print("C\n", .{});
                    },
                    7 => unreachable,
                }
            },
            .bxl => {
                std.debug.print("bxl ", .{});
                std.debug.print("{d}\n", .{self.operand});
            },
            .bst => {
                std.debug.print("bst ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        std.debug.print("{d}\n", .{self.operand});
                    },
                    4 => {
                        std.debug.print("A\n", .{});
                    },
                    5 => {
                        std.debug.print("B\n", .{});
                    },
                    6 => {
                        std.debug.print("C\n", .{});
                    },
                    7 => unreachable,
                }
            },
            .jnz => {
                std.debug.print("jnz ", .{});
                std.debug.print("{d}\n", .{self.operand});
            },
            .bxc => {
                std.debug.print("bxc\n", .{});
            },
            .out => {
                std.debug.print("out ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        std.debug.print("{d}\n", .{self.operand});
                    },
                    4 => {
                        std.debug.print("A\n", .{});
                    },
                    5 => {
                        std.debug.print("B\n", .{});
                    },
                    6 => {
                        std.debug.print("C\n", .{});
                    },
                    7 => unreachable,
                }
            },
            .bdv => {
                std.debug.print("bdv ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        std.debug.print("{d}\n", .{self.operand});
                    },
                    4 => {
                        std.debug.print("A\n", .{});
                    },
                    5 => {
                        std.debug.print("B\n", .{});
                    },
                    6 => {
                        std.debug.print("C\n", .{});
                    },
                    7 => unreachable,
                }
            },
            .cdv => {
                std.debug.print("cdv ", .{});
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        std.debug.print("{d}\n", .{self.operand});
                    },
                    4 => {
                        std.debug.print("A\n", .{});
                    },
                    5 => {
                        std.debug.print("B\n", .{});
                    },
                    6 => {
                        std.debug.print("C\n", .{});
                    },
                    7 => unreachable,
                }
            },
        }
    }

    pub fn execute(self: *Instruction, registers: *Registers, machine: *Machine) !void {
        //std.debug.print("Executing {any} at pc {d}\n", .{ self.*, machine.pc });
        switch (self.opcode) {
            .adv => {
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand))))), @divFloor(registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand)))))) });
                        }
                        registers.A = @divFloor(registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand))))));
                    },
                    4 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.A), @divFloor(registers.A, std.math.pow(i64, 2, registers.A)) });
                        }
                        registers.A = @divFloor(registers.A, std.math.pow(i64, 2, registers.A));
                    },
                    5 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.B), @divFloor(registers.A, std.math.pow(i64, 2, registers.B)) });
                        }
                        registers.A = @divFloor(registers.A, std.math.pow(i64, 2, registers.B));
                    },
                    6 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.C), @divFloor(registers.A, std.math.pow(i64, 2, registers.C)) });
                        }
                        registers.A = @divFloor(registers.A, std.math.pow(i64, 2, registers.C));
                    },
                    7 => {
                        unreachable;
                    },
                }
                machine.pc += 1;
            },
            .bxl => {
                if (DEBUG) {
                    std.debug.print("{s} {d}^{d}={d}\n", .{ try self.str(), registers.B, @as(i64, @bitCast(@as(u64, @intCast(self.operand)))), registers.B ^ @as(i64, @bitCast(@as(u64, @intCast(self.operand)))) });
                }
                registers.B = registers.B ^ @as(i64, @bitCast(@as(u64, @intCast(self.operand))));
                machine.pc += 1;
            },
            .bst => {
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), @as(i64, @bitCast(@as(u64, @intCast(self.operand)))), 8, @mod(@as(i64, @bitCast(@as(u64, @intCast(self.operand)))), 8) });
                        }
                        registers.B = @mod(@as(i64, @bitCast(@as(u64, @intCast(self.operand)))), 8);
                    },
                    4 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), registers.A, 8, @mod(registers.A, 8) });
                        }
                        registers.B = @mod(registers.A, 8);
                    },
                    5 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), registers.B, 8, @mod(registers.B, 8) });
                        }
                        registers.B = @mod(registers.B, 8);
                    },
                    6 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), registers.B, 8, @mod(registers.A, 8) });
                        }
                        registers.B = @mod(registers.C, 8);
                    },
                    7 => {
                        unreachable;
                    },
                }
                machine.pc += 1;
            },
            .jnz => {
                if (registers.A != 0) {
                    if (DEBUG) {
                        std.debug.print("{s} jmp {d}\n", .{ try self.str(), self.operand });
                    }
                    machine.pc = self.operand;
                } else {
                    machine.pc += 1;
                }
            },
            .bxc => {
                if (DEBUG) {
                    std.debug.print("{s} {d}^{d}={d}\n", .{ try self.str(), registers.B, registers.C, registers.B ^ registers.C });
                }
                registers.B = registers.B ^ registers.C;
                machine.pc += 1;
            },
            .out => {
                if (machine.output.items.len > 0) {
                    try machine.output.append(',');
                }
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), @as(i64, @bitCast(@as(u64, @intCast(self.operand)))), 8, @mod(@as(i64, @bitCast(@as(u64, @intCast(self.operand)))), 8) });
                        }
                        try machine.output.writer().print("{d}", .{@mod(@as(i64, @bitCast(@as(u64, @intCast(self.operand)))), 8)});
                    },
                    4 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), registers.A, 8, @mod(registers.A, 8) });
                        }
                        try machine.output.writer().print("{d}", .{@mod(registers.A, 8)});
                    },
                    5 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), registers.B, 8, @mod(registers.B, 8) });
                        }
                        try machine.output.writer().print("{d}", .{@mod(registers.B, 8)});
                    },
                    6 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}%{d}={d}\n", .{ try self.str(), registers.C, 8, @mod(registers.C, 8) });
                        }
                        try machine.output.writer().print("{d}", .{@mod(registers.C, 8)});
                    },
                    7 => {
                        unreachable;
                    },
                }
                machine.pc += 1;
            },
            .bdv => {
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand))))), @divFloor(registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand)))))) });
                        }
                        registers.B = @divFloor(registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand))))));
                    },
                    4 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.A), @divFloor(registers.A, std.math.pow(i64, 2, registers.A)) });
                        }
                        registers.B = @divFloor(registers.A, std.math.pow(i64, 2, registers.A));
                    },
                    5 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.B), @divFloor(registers.A, std.math.pow(i64, 2, registers.B)) });
                        }
                        registers.B = @divFloor(registers.A, std.math.pow(i64, 2, registers.B));
                    },
                    6 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.C), @divFloor(registers.A, std.math.pow(i64, 2, registers.C)) });
                        }
                        registers.B = @divFloor(registers.A, std.math.pow(i64, 2, registers.C));
                    },
                    7 => {
                        unreachable;
                    },
                }
                machine.pc += 1;
            },
            .cdv => {
                switch (self.operand) {
                    0, 1, 2, 3 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand))))), @divFloor(registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand)))))) });
                        }
                        registers.C = @divFloor(registers.A, std.math.pow(i64, 2, @as(i64, @bitCast(@as(u64, @intCast(self.operand))))));
                    },
                    4 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.A), @divFloor(registers.A, std.math.pow(i64, 2, registers.A)) });
                        }
                        registers.C = @divFloor(registers.A, std.math.pow(i64, 2, registers.A));
                    },
                    5 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.B), @divFloor(registers.A, std.math.pow(i64, 2, registers.B)) });
                        }
                        registers.C = @divFloor(registers.A, std.math.pow(i64, 2, registers.B));
                    },
                    6 => {
                        if (DEBUG) {
                            std.debug.print("{s} {d}/{d}={d}\n", .{ try self.str(), registers.A, std.math.pow(i64, 2, registers.C), @divFloor(registers.A, std.math.pow(i64, 2, registers.C)) });
                        }
                        registers.C = @divFloor(registers.A, std.math.pow(i64, 2, registers.C));
                    },
                    7 => {
                        unreachable;
                    },
                }
                machine.pc += 1;
            },
        }
        //machine.print_state();
    }
};

pub const Registers = struct {
    A: i64,
    B: i64,
    C: i64,
};

pub const Machine = struct {
    pc: usize = 0,
    registers: Registers = undefined,
    instructions: std.ArrayList(Instruction) = undefined,
    output: std.ArrayList(u8) = undefined,
    allocator: std.mem.Allocator,
    pub fn init(allocator: std.mem.Allocator) Machine {
        return .{
            .pc = 0,
            .registers = undefined,
            .instructions = std.ArrayList(Instruction).init(allocator),
            .output = std.ArrayList(u8).init(allocator),
            .allocator = allocator,
        };
    }
    pub fn print_state(self: *Machine) void {
        std.debug.print("PC: {d}\n", .{self.pc});
        std.debug.print("Register A: {d}\n", .{self.registers.A});
        std.debug.print("Register B: {d}\n", .{self.registers.B});
        std.debug.print("Register C: {d}\n", .{self.registers.C});
        std.debug.print("Output: {s}\n", .{self.output.items});
    }
    pub fn reset(self: *Machine, A: i64) void {
        self.registers.A = A;
        self.registers.B = 0;
        self.registers.C = 0;
        self.output.clearRetainingCapacity();
    }
    pub fn run(self: *Machine) ![]u8 {
        self.pc = 0;
        if (DEBUG) {
            std.debug.print("Start state\n", .{});
            self.print_state();
        }
        while (self.pc < self.instructions.items.len) {
            try self.instructions.items[self.pc].execute(&self.registers, self);
        }
        return self.output.items;
    }

    pub fn trimmed_run(self: *Machine) ![]u8 {
        _ = try self.run();
        while (std.mem.indexOfScalar(u8, self.output.items, ',')) |indx| {
            _ = self.output.orderedRemove(indx);
        }
        return self.output.items;
    }

    pub fn deinit(self: *Machine) void {
        self.instructions.deinit();
        self.output.deinit();
    }
};

pub fn part1(file_name: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var machine = Machine.init(allocator);
    defer machine.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var it = std.mem.splitScalar(u8, line, ' ');
        if (std.mem.indexOf(u8, it.next().?, "Program")) |_| {
            var it_inst = std.mem.splitScalar(u8, it.next().?, ',');
            while (it_inst.next()) |inst_part| {
                try machine.instructions.append(Instruction.init(inst_part[0], it_inst.next().?[0]));
            }
        } else {
            if (line.len == 0) continue;
            const unproc_reg = it.next().?;
            const register_letter = unproc_reg[0 .. unproc_reg.len - 1];
            if (std.mem.eql(u8, register_letter, "A")) {
                machine.registers.A = try std.fmt.parseInt(i64, it.next().?, 10);
            } else if (std.mem.eql(u8, register_letter, "B")) {
                machine.registers.B = try std.fmt.parseInt(i64, it.next().?, 10);
            } else if (std.mem.eql(u8, register_letter, "C")) {
                machine.registers.C = try std.fmt.parseInt(i64, it.next().?, 10);
            }
        }
    }
    machine.registers.A = 0 + 7 * std.math.pow(i64, 8, 1) + 2 * std.math.pow(i64, 8, 2) + 5 * std.math.pow(i64, 8, 3) + 4 * std.math.pow(i64, 8, 4) + 3 * std.math.pow(i64, 8, 5);
    if (DEBUG) {
        std.debug.print("Machine {any}\n", .{machine});
        std.debug.print("Registers {any}\n", .{machine.registers});
        std.debug.print("Instructions {any}\n", .{machine.instructions.items});
    }
    return try std.fmt.bufPrint(&num_buf, "{s}", .{try machine.run()});
}

// --- Part Two ---
// Digging deeper in the device's manual, you discover the problem: this program is supposed to output another copy of the program! Unfortunately, the value in register A seems to have been corrupted. You'll need to find a new value to which you can initialize register A so that the program's output instructions produce an exact copy of the program itself.

// For example:

// Register A: 2024
// Register B: 0
// Register C: 0

// Program: 0,3,5,4,3,0
// This program outputs a copy of itself if register A is instead initialized to 117440. (The original initial value of register A, 2024, is ignored.)

// What is the lowest positive initial value for register A that causes the program to output a copy of itself?
pub fn solve_rec(machine: *Machine, program: std.ArrayList(u8), digit: i64, solved_digits: i64) !i64 {
    if (DEBUG) {
        std.debug.print("digit {d} solved digit {d}\n", .{ digit, solved_digits });
    }
    const found_digits = solved_digits * 8;
    for (0..8) |i| {
        const a = found_digits + @as(i64, @bitCast(i));
        machine.reset(a);
        const trimmed_out = try machine.trimmed_run();
        var matching_digit = true;
        for (0..@as(u64, @bitCast(digit))) |j| {
            if (program.items[program.items.len - 1 - j] != trimmed_out[trimmed_out.len - 1 - j]) matching_digit = false;
        }
        if (matching_digit) {
            if (digit == program.items.len) {
                return a;
            }
            const ret = try solve_rec(machine, program, digit + 1, a);
            if (ret != -1) return ret;
        }
    }
    return -1;
}

pub fn part2(file_name: []const u8, allocator: std.mem.Allocator) !i64 {
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    var buf: [65536]u8 = undefined;
    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();
    var machine = Machine.init(allocator);
    defer machine.deinit();
    var program = std.ArrayList(u8).init(allocator);
    defer program.deinit();
    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |unfiltered| {
        var line = unfiltered;
        if (std.mem.indexOfScalar(u8, unfiltered, '\r')) |indx| {
            line = unfiltered[0..indx];
        }
        var it = std.mem.splitScalar(u8, line, ' ');
        if (std.mem.indexOf(u8, it.next().?, "Program")) |_| {
            var it_inst = std.mem.splitScalar(u8, it.next().?, ',');
            while (it_inst.next()) |inst_part| {
                const operand = it_inst.next().?;
                try machine.instructions.append(Instruction.init(inst_part[0], operand[0]));
                try program.append(inst_part[0]);
                try program.append(operand[0]);
            }
        } else {
            if (line.len == 0) continue;
            const unproc_reg = it.next().?;
            const register_letter = unproc_reg[0 .. unproc_reg.len - 1];
            if (std.mem.eql(u8, register_letter, "A")) {
                machine.registers.A = try std.fmt.parseInt(i64, it.next().?, 10);
            } else if (std.mem.eql(u8, register_letter, "B")) {
                machine.registers.B = try std.fmt.parseInt(i64, it.next().?, 10);
            } else if (std.mem.eql(u8, register_letter, "C")) {
                machine.registers.C = try std.fmt.parseInt(i64, it.next().?, 10);
            }
        }
    }
    if (DEBUG) {
        machine.print_state();
        std.debug.print("Instructions: {s}\n", .{program.items});
        for (0..machine.instructions.items.len) |i| {
            machine.instructions.items[i].print();
        }
    }
    // machine.registers.A = 6 + 1 * std.math.pow(i64, 8, 1) + 3 * std.math.pow(i64, 8, 2) + 2 * std.math.pow(i64, 8, 3) + 2 * std.math.pow(i64, 8, 4);
    // machine.registers.A += 3 * std.math.pow(i64, 8, 5) + 1 * std.math.pow(i64, 8, 6) + 1 * std.math.pow(i64, 8, 7) + 2 * std.math.pow(i64, 8, 8);
    // machine.registers.A += 1 * std.math.pow(i64, 8, 9) + 2 * std.math.pow(i64, 8, 10) + 3 * std.math.pow(i64, 8, 11) + 4 * std.math.pow(i64, 8, 12);
    // machine.registers.A += 7 * std.math.pow(i64, 8, 13) + 7 * std.math.pow(i64, 8, 14) + 3 * std.math.pow(i64, 8, 15);
    // for (0..8) |i| {
    //     machine.reset(@as(i64, @bitCast(i + 192)));
    //     std.debug.print("{s}\n", .{try machine.run()});
    //     std.time.sleep(std.time.ns_per_s * 2);
    // }

    return solve_rec(&machine, program, 1, 0);
}

test "day17" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    scratch_str = std.ArrayList(u8).init(allocator);
    var timer = try std.time.Timer.start();
    std.debug.print("Joined output {s} in {d}ms\n", .{ try part1("../inputs/day17/copy.txt", allocator), timer.lap() / std.time.ns_per_ms });
    //std.debug.print("Minimum A {d} in {d}ms\n", .{ try part2("../inputs/day17/input.txt", allocator), timer.lap() / std.time.ns_per_ms });
    scratch_str.deinit();
    if (gpa.deinit() == .leak) {
        std.debug.print("Leaked!\n", .{});
    }
}
