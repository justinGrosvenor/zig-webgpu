pub const Key = enum(u8) {
    w,
    a,
    s,
    d,
    q,
    e,
    r,
    f,
    z,
    x,
    g,
    space,
    left_shift,
    left_ctrl,
    left_super,
    escape,
    tab,
    delete,
    backspace,
    up,
    down,
    left,
    right,
};

const key_count = @typeInfo(Key).@"enum".fields.len;

pub const Input = struct {
    keys_down: [key_count]bool = .{false} ** key_count,
    keys_pressed: [key_count]bool = .{false} ** key_count,
    keys_released: [key_count]bool = .{false} ** key_count,

    mouse_x: f32 = 0,
    mouse_y: f32 = 0,
    mouse_dx: f32 = 0,
    mouse_dy: f32 = 0,
    mouse_left: bool = false,
    mouse_right: bool = false,
    mouse_middle: bool = false,
    mouse_left_pressed: bool = false,
    mouse_left_released: bool = false,
    mouse_right_pressed: bool = false,
    mouse_right_released: bool = false,
    mouse_middle_pressed: bool = false,
    mouse_middle_released: bool = false,
    /// Vertical scroll accumulated this frame. Approximately notches: 1.0 ≈ one
    /// detent of a discrete mouse wheel on Windows (/120) and X11 (±1 per
    /// button-4/5 event). macOS reports `scrollingDeltaY` raw — discrete wheels
    /// deliver ~1.0 per notch, but trackpad inertial scrolls deliver larger
    /// continuous values. Consumers that need a uniform unit should scale this
    /// per platform or accumulate-and-threshold themselves.
    scroll_y: f32 = 0,

    pub fn isDown(self: Input, key: Key) bool {
        return self.keys_down[@intFromEnum(key)];
    }

    pub fn isPressed(self: Input, key: Key) bool {
        return self.keys_pressed[@intFromEnum(key)];
    }

    pub fn isReleased(self: Input, key: Key) bool {
        return self.keys_released[@intFromEnum(key)];
    }

    pub fn beginFrame(self: *Input) void {
        @memset(&self.keys_pressed, false);
        @memset(&self.keys_released, false);
        self.mouse_dx = 0;
        self.mouse_dy = 0;
        self.mouse_left_pressed = false;
        self.mouse_left_released = false;
        self.mouse_right_pressed = false;
        self.mouse_right_released = false;
        self.mouse_middle_pressed = false;
        self.mouse_middle_released = false;
        self.scroll_y = 0;
    }

    pub fn handleKeyDown(self: *Input, key: Key) void {
        const idx = @intFromEnum(key);
        if (!self.keys_down[idx]) self.keys_pressed[idx] = true;
        self.keys_down[idx] = true;
    }

    pub fn handleKeyUp(self: *Input, key: Key) void {
        const idx = @intFromEnum(key);
        self.keys_down[idx] = false;
        self.keys_released[idx] = true;
    }
};
