const std = @import("std");
const gpu = @import("../gpu.zig");
const c = gpu.c;
const Input = @import("../input.zig").Input;
const Key = @import("../input.zig").Key;

const x11 = @cImport({
    @cInclude("X11/Xlib.h");
    @cInclude("X11/Xutil.h");
    @cInclude("X11/keysym.h");
});

/// X11 display connection is opened lazily on the first window and reused
/// across every subsequent window in the process. Closing it on a per-window
/// `deinit` would break any window that's still alive (and historically did);
/// the OS reclaims the connection at process exit.
var shared_display: ?*x11.Display = null;

fn getDisplay() !*x11.Display {
    if (shared_display) |d| return d;
    const d = x11.XOpenDisplay(null) orelse return error.NoDisplay;
    shared_display = d;
    return d;
}

pub const Window = struct {
    display: *x11.Display,
    window: x11.Window,
    wm_delete: x11.Atom,
    should_close: bool,
    width: u32,
    height: u32,
    input: Input = .{},

    pub const Config = struct {
        title: [*:0]const u8 = "zig-webgpu",
        width: u32 = 800,
        height: u32 = 600,
    };

    pub fn init(config: Config) !Window {
        const display = try getDisplay();

        const screen = x11.XDefaultScreen(display);
        const root = x11.XRootWindow(display, screen);

        const window = x11.XCreateSimpleWindow(
            display,
            root,
            0,
            0,
            config.width,
            config.height,
            0,
            x11.XBlackPixel(display, screen),
            x11.XWhitePixel(display, screen),
        );

        _ = x11.XStoreName(display, window, config.title);
        _ = x11.XMapWindow(display, window);

        // Register interest in WM_DELETE_WINDOW so close button works
        var wm_delete = x11.XInternAtom(display, "WM_DELETE_WINDOW", 0);
        _ = x11.XSetWMProtocols(display, window, &wm_delete, 1);

        _ = x11.XSelectInput(display, window, x11.ExposureMask | x11.StructureNotifyMask | x11.KeyPressMask | x11.KeyReleaseMask | x11.ButtonPressMask | x11.ButtonReleaseMask | x11.PointerMotionMask);

        _ = x11.XFlush(display);

        return .{
            .display = display,
            .window = window,
            .wm_delete = wm_delete,
            .should_close = false,
            .width = config.width,
            .height = config.height,
        };
    }

    pub fn deinit(self: *Window) void {
        _ = x11.XDestroyWindow(self.display, self.window);
        _ = x11.XFlush(self.display);
        self.* = undefined;
    }

    pub fn pollEvents(self: *Window) void {
        self.input.beginFrame();
        while (x11.XPending(self.display) > 0) {
            var event: x11.XEvent = undefined;
            _ = x11.XNextEvent(self.display, &event);

            switch (event.type) {
                x11.ClientMessage => {
                    if (@as(x11.Atom, @intCast(event.xclient.data.l[0])) == self.wm_delete) {
                        self.should_close = true;
                    }
                },
                x11.ConfigureNotify => {
                    self.width = @intCast(event.xconfigure.width);
                    self.height = @intCast(event.xconfigure.height);
                },
                x11.KeyPress => {
                    const keysym = x11.XLookupKeysym(&event.xkey, 0);
                    if (mapKeySym(keysym)) |key| self.input.handleKeyDown(key);
                },
                x11.KeyRelease => {
                    const keysym = x11.XLookupKeysym(&event.xkey, 0);
                    if (mapKeySym(keysym)) |key| self.input.handleKeyUp(key);
                },
                x11.ButtonPress => switch (event.xbutton.button) {
                    1 => {
                        self.input.mouse_left = true;
                        self.input.mouse_left_pressed = true;
                    },
                    2 => {
                        self.input.mouse_middle = true;
                        self.input.mouse_middle_pressed = true;
                    },
                    3 => {
                        self.input.mouse_right = true;
                        self.input.mouse_right_pressed = true;
                    },
                    4 => self.input.scroll_y += 1.0,
                    5 => self.input.scroll_y -= 1.0,
                    else => {},
                },
                x11.ButtonRelease => switch (event.xbutton.button) {
                    1 => {
                        self.input.mouse_left = false;
                        self.input.mouse_left_released = true;
                    },
                    2 => {
                        self.input.mouse_middle = false;
                        self.input.mouse_middle_released = true;
                    },
                    3 => {
                        self.input.mouse_right = false;
                        self.input.mouse_right_released = true;
                    },
                    else => {},
                },
                x11.MotionNotify => {
                    const mx: f32 = @floatFromInt(event.xmotion.x);
                    const my: f32 = @floatFromInt(event.xmotion.y);
                    self.input.mouse_dx += mx - self.input.mouse_x;
                    self.input.mouse_dy += my - self.input.mouse_y;
                    self.input.mouse_x = mx;
                    self.input.mouse_y = my;
                },
                else => {},
            }
        }
    }

    pub fn createSurface(self: Window, instance: gpu.Instance) ?gpu.Surface {
        var source: c.WGPUSurfaceSourceXlibWindow = .{
            .chain = .{
                .next = null,
                .sType = c.WGPUSType_SurfaceSourceXlibWindow,
            },
            .display = self.display,
            .window = @intCast(self.window),
        };
        const descriptor: c.WGPUSurfaceDescriptor = .{
            .nextInChain = @ptrCast(&source.chain),
            .label = gpu.stringView("x11 surface"),
        };
        return instance.createSurface(&descriptor);
    }

    pub fn getSize(self: Window) [2]u32 {
        return .{ self.width, self.height };
    }
};

fn mapKeySym(keysym: c_ulong) ?Key {
    return switch (keysym) {
        x11.XK_w, x11.XK_W => .w,
        x11.XK_a, x11.XK_A => .a,
        x11.XK_s, x11.XK_S => .s,
        x11.XK_d, x11.XK_D => .d,
        x11.XK_q, x11.XK_Q => .q,
        x11.XK_e, x11.XK_E => .e,
        x11.XK_r, x11.XK_R => .r,
        x11.XK_f, x11.XK_F => .f,
        x11.XK_z, x11.XK_Z => .z,
        x11.XK_x, x11.XK_X => .x,
        x11.XK_g, x11.XK_G => .g,
        x11.XK_space => .space,
        x11.XK_Shift_L, x11.XK_Shift_R => .left_shift,
        x11.XK_Control_L, x11.XK_Control_R => .left_ctrl,
        x11.XK_Super_L, x11.XK_Super_R => .left_super,
        x11.XK_Escape => .escape,
        x11.XK_Tab => .tab,
        x11.XK_Delete => .delete,
        x11.XK_BackSpace => .backspace,
        x11.XK_Up => .up,
        x11.XK_Down => .down,
        x11.XK_Left => .left,
        x11.XK_Right => .right,
        else => null,
    };
}
