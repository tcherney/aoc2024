const std = @import("std");
const builtin = @import("builtin");
const engine = @import("engine");
const common = @import("common");
const emcc = @import("emcc.zig");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");
const day9 = @import("day9.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");

pub const Engine = engine.Engine;
const GAME_LOG = std.log.scoped(.game);
pub const TUI = engine.TUI(Game.State);

const TERMINAL_HEIGHT_OFFSET = 70;
const TERMINAL_WIDTH_OFFSET = 30;

const GAME_STEPS = 1000;

pub const Game = struct {
    running: bool = true,
    e: Engine = undefined,
    allocator: std.mem.Allocator = undefined,
    //frame_limit: u64 = 16_666_667,
    frame_limit: u64 = std.time.ns_per_s * 2,
    lock: std.Thread.Mutex = undefined,
    window: engine.Texture,
    world: std.ArrayList(std.ArrayList(u8)) = undefined,
    world_buffer: std.ArrayList(std.ArrayList(u8)) = undefined,
    viewport: common.Rectangle = undefined,
    state: State = .start,
    world_steps: u32 = 0,
    tui: TUI,
    pub const State = enum {
        game,
        start,
        pause,
    };
    const Self = @This();
    pub const Error = error{} || engine.Error || std.posix.GetRandomError || std.mem.Allocator.Error;
    pub fn init(allocator: std.mem.Allocator) Error!Self {
        return Self{
            .allocator = allocator,
            .window = engine.Texture.init(allocator),
            .tui = TUI.init(allocator, .ascii),
        };
    }
    pub fn deinit(self: *Self) Error!void {
        try self.e.deinit();
        self.window.deinit();
        self.tui.deinit();
        if (day9.part1 or day9.part2) {
            day9.deinit(self);
        }
    }
    //TODO handle mouse/touch
    pub fn on_mouse_change(self: *Self, mouse_event: engine.MouseEvent) void {
        GAME_LOG.info("{any}\n", .{mouse_event});
        _ = self;
    }
    pub fn on_window_change(self: *Self, win_size: engine.WindowSize) void {
        self.lock.lock();
        GAME_LOG.info("changed height {d}\n", .{win_size.height});
        self.lock.unlock();
    }

    pub fn on_key_down(self: *Self, key: engine.KEYS) void {
        GAME_LOG.info("{}\n", .{key});
        if (key == engine.KEYS.KEY_q) {
            self.running = false;
        }
        switch (self.state) {
            .game => {
                if (key == .KEY_w or key == .KEY_W) {} else if (key == .KEY_a or key == .KEY_A) {} else if (key == .KEY_s or key == .KEY_S) {} else if (key == .KEY_d or key == .KEY_D) {} else if (key == .KEY_q or key == .KEY_Q) {
                    self.running = false;
                } else if (key == .KEY_ESC) {
                    self.state = .pause;
                }
            },
            .start => {
                if (key == .KEY_SPACE) {
                    self.state = .game;
                }
            },
            .pause => {
                if (key == .KEY_ESC) {
                    self.state = .game;
                }
            },
        }
    }

    pub fn on_start_clicked(self: *Self) void {
        self.state = .game;
    }
    var scratch_buffer: [32]u8 = undefined;
    pub fn on_render(self: *Self, dt: u64) !void {
        if (!day9.part2) return;
        self.e.renderer.ascii.set_bg(0, 0, 0, self.window);
        for (0..self.window.ascii_buffer.len) |i| {
            self.window.ascii_buffer[i] = ' ';
        }
        switch (self.state) {
            .game => {
                if (day9.part2) {
                    day9.on_render(self, dt);
                }
            },
            .start, .pause => {
                try self.tui.draw(&self.e.renderer, self.window, 0, 0, self.state);
            },
        }
        try self.e.renderer.ascii.flip(self.window, self.viewport);
    }

    pub fn em_key_handler(event_type: c_int, event: ?*const emcc.EmsdkWrapper.EmscriptenKeyboardEvent, ctx: ?*anyopaque) callconv(.C) bool {
        GAME_LOG.info("event_type {any}\n", .{event_type});
        GAME_LOG.info("event {any}\n", .{event});
        const self: *Self = @ptrCast(@alignCast(ctx));
        self.on_key_down(@enumFromInt(event.?.which));
        return true;
    }

    pub fn update(_: *Self) !void {}

    pub fn run(self: *Self) !void {
        //try day1.day1(self);
        //try day2.day2_p1(self);
        //try day2.day2_p2(self);
        //try day3.day3_p2(self);
        //try day4.day4_p1(self);
        //try day4.day4_p2(self);
        //try day5.day5_p1(self);
        //try day5.day5_p2(self);
        //try day6.day6_p1(self);
        //try day6.day6_p2(self);
        //try day7.day7_p1(self);
        //try day7.day7_p2(self);
        //try day8.day8_p1(self);
        //try day8.day8_p2(self);
        //try day9.day9_p1(self);

        try day10.day10_p1(self);
        self.lock = std.Thread.Mutex{};
        engine.set_wasm_terminal_size(35, 150);
        self.e = try Engine.init(self.allocator, TERMINAL_WIDTH_OFFSET, TERMINAL_HEIGHT_OFFSET, .ascii, ._2d, .color_true, if (builtin.os.tag == .emscripten) .wasm else .native, if (builtin.os.tag == .emscripten) .single else .multi);
        GAME_LOG.info("starting height {d}\n", .{self.e.renderer.ascii.terminal.size.height});
        self.window.is_ascii = true;
        try self.window.rect(@intCast(self.e.renderer.ascii.terminal.size.width), @intCast(self.e.renderer.ascii.terminal.size.height), 0, 0, 0, 255);
        self.viewport = common.Rectangle{
            .x = 0,
            .y = 0,
            .width = @intCast(self.e.renderer.ascii.terminal.size.width),
            .height = @intCast(self.e.renderer.ascii.terminal.size.height),
        };
        self.e.on_key_down(Self, on_key_down, self);
        self.e.on_render(Self, on_render, self);
        self.e.on_mouse_change(Self, on_mouse_change, self);
        self.e.on_window_change(Self, on_window_change, self);
        try self.tui.add_button(self.e.renderer.ascii.terminal.size.width / 2, self.e.renderer.ascii.terminal.size.height / 2, null, null, common.Colors.WHITE, common.Colors.BLUE, common.Colors.MAGENTA, "Start", .start);
        self.tui.items.items[self.tui.items.items.len - 1].set_on_click(Self, on_start_clicked, self);
        try self.tui.add_button(self.e.renderer.ascii.terminal.size.width / 2, self.e.renderer.ascii.terminal.size.height / 2, null, null, common.Colors.WHITE, common.Colors.BLUE, common.Colors.MAGENTA, "Pause", .pause);
        self.e.set_fps(60);
        try common.gen_rand();
        // try day9.day9_p2(self);
        // if (day9.part2) return;
        self.state = .game;
        try self.e.start();

        if (builtin.os.tag == .emscripten) {
            const res = emcc.EmsdkWrapper.emscripten_set_keydown_callback("body", self, true, em_key_handler);
            GAME_LOG.info("handler set {d}\n", .{res});
        }

        var timer: std.time.Timer = try std.time.Timer.start();
        var delta: u64 = 0;
        while (self.running) {
            delta = timer.read();
            timer.reset();
            self.lock.lock();

            self.lock.unlock();
            delta = timer.read();
            timer.reset();
            if (builtin.os.tag == .emscripten) {
                try self.on_render(delta);
                emcc.EmsdkWrapper.emscripten_sleep(16);
            } else {
                const time_to_sleep: i64 = @as(i64, @bitCast(self.frame_limit)) - @as(i64, @bitCast(delta));
                if (time_to_sleep > 0) {
                    std.time.sleep(@as(u64, @bitCast(time_to_sleep)));
                }
            }
        }
    }
};
