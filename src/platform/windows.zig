const std = @import("std");
const gpu = @import("../gpu.zig");
const c = gpu.c;
const Input = @import("../input.zig").Input;
const Key = @import("../input.zig").Key;

const win32 = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
});

const HWND = win32.HWND;
const HINSTANCE = win32.HINSTANCE;
const MSG = win32.MSG;

pub const Window = struct {
    hwnd: HWND,
    hinstance: HINSTANCE,
    should_close: bool,
    input: Input = .{},

    pub const Config = struct {
        title: [*:0]const u8 = "zig-webgpu",
        width: u32 = 800,
        height: u32 = 600,
    };

    pub fn init(config: Config) !Window {
        const hinstance = win32.GetModuleHandleW(null);

        const class_name = std.unicode.utf8ToUtf16LeStringLiteral("zig_webgpu_window");

        const wc: win32.WNDCLASSEXW = .{
            .cbSize = @sizeOf(win32.WNDCLASSEXW),
            .style = win32.CS_HREDRAW | win32.CS_VREDRAW,
            .lpfnWndProc = wndProc,
            .cbClsExtra = 0,
            .cbWndExtra = 0,
            .hInstance = hinstance,
            .hIcon = null,
            .hCursor = win32.LoadCursorW(null, win32.IDC_ARROW),
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = class_name,
            .hIconSm = null,
        };
        _ = win32.RegisterClassExW(&wc);

        var rect: win32.RECT = .{
            .left = 0,
            .top = 0,
            .right = @intCast(config.width),
            .bottom = @intCast(config.height),
        };
        const style = win32.WS_OVERLAPPEDWINDOW;
        _ = win32.AdjustWindowRect(&rect, style, 0);

        const title_wide = blk: {
            var buf: [256]u16 = undefined;
            const len = std.unicode.utf8ToUtf16Le(&buf, std.mem.span(config.title)) catch 0;
            buf[len] = 0;
            break :blk buf;
        };

        const hwnd = win32.CreateWindowExW(
            0,
            class_name,
            &title_wide,
            style,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            rect.right - rect.left,
            rect.bottom - rect.top,
            null,
            null,
            hinstance,
            null,
        ) orelse return error.WindowCreationFailed;

        _ = win32.ShowWindow(hwnd, win32.SW_SHOW);
        _ = win32.UpdateWindow(hwnd);

        return .{
            .hwnd = hwnd,
            .hinstance = hinstance,
            .should_close = false,
        };
    }

    pub fn deinit(self: *Window) void {
        _ = win32.DestroyWindow(self.hwnd);
        self.* = undefined;
    }

    pub fn pollEvents(self: *Window) void {
        self.input.beginFrame();
        var message: MSG = undefined;
        while (win32.PeekMessageW(&message, self.hwnd, 0, 0, win32.PM_REMOVE) != 0) {
            if (message.message == win32.WM_CLOSE or message.message == win32.WM_QUIT) {
                self.should_close = true;
                return;
            }
            self.handleMessage(&message);
            _ = win32.TranslateMessage(&message);
            _ = win32.DispatchMessageW(&message);
        }
        if (win32.IsWindow(self.hwnd) == 0) {
            self.should_close = true;
        }
    }

    fn handleMessage(self: *Window, message: *const MSG) void {
        switch (message.message) {
            win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN => {
                if (mapVirtualKey(@intCast(message.wParam))) |key|
                    self.input.handleKeyDown(key);
            },
            win32.WM_KEYUP, win32.WM_SYSKEYUP => {
                if (mapVirtualKey(@intCast(message.wParam))) |key|
                    self.input.handleKeyUp(key);
            },
            win32.WM_LBUTTONDOWN => {
                self.input.mouse_left = true;
                self.input.mouse_left_pressed = true;
            },
            win32.WM_LBUTTONUP => {
                self.input.mouse_left = false;
                self.input.mouse_left_released = true;
            },
            win32.WM_RBUTTONDOWN => {
                self.input.mouse_right = true;
                self.input.mouse_right_pressed = true;
            },
            win32.WM_RBUTTONUP => {
                self.input.mouse_right = false;
                self.input.mouse_right_released = true;
            },
            win32.WM_MBUTTONDOWN => {
                self.input.mouse_middle = true;
                self.input.mouse_middle_pressed = true;
            },
            win32.WM_MBUTTONUP => {
                self.input.mouse_middle = false;
                self.input.mouse_middle_released = true;
            },
            win32.WM_MOUSEMOVE => {
                const x: f32 = @floatFromInt(@as(i16, @truncate(message.lParam & 0xFFFF)));
                const y: f32 = @floatFromInt(@as(i16, @truncate((message.lParam >> 16) & 0xFFFF)));
                self.input.mouse_dx += x - self.input.mouse_x;
                self.input.mouse_dy += y - self.input.mouse_y;
                self.input.mouse_x = x;
                self.input.mouse_y = y;
            },
            win32.WM_MOUSEWHEEL => {
                const delta: i16 = @truncate((message.wParam >> 16) & 0xFFFF);
                self.input.scroll_y += @as(f32, @floatFromInt(delta)) / 120.0;
            },
            else => {},
        }
    }

    pub fn createSurface(self: Window, instance: gpu.Instance) ?gpu.Surface {
        var source: c.WGPUSurfaceSourceWindowsHWND = .{
            .chain = .{
                .next = null,
                .sType = c.WGPUSType_SurfaceSourceWindowsHWND,
            },
            .hinstance = self.hinstance,
            .hwnd = self.hwnd,
        };
        const descriptor: c.WGPUSurfaceDescriptor = .{
            .nextInChain = @ptrCast(&source.chain),
            .label = gpu.stringView("windows surface"),
        };
        return instance.createSurface(&descriptor);
    }

    pub fn getSize(self: Window) [2]u32 {
        var rect: win32.RECT = undefined;
        _ = win32.GetClientRect(self.hwnd, &rect);
        return .{
            @intCast(rect.right - rect.left),
            @intCast(rect.bottom - rect.top),
        };
    }

    fn wndProc(hwnd: HWND, message: u32, wparam: win32.WPARAM, lparam: win32.LPARAM) callconv(.c) win32.LRESULT {
        return win32.DefWindowProcW(hwnd, message, wparam, lparam);
    }
};

fn mapVirtualKey(vk: u32) ?Key {
    return switch (vk) {
        0x57 => .w,
        0x41 => .a,
        0x53 => .s,
        0x44 => .d,
        0x51 => .q,
        0x45 => .e,
        0x52 => .r,
        0x46 => .f,
        0x20 => .space,
        0x10 => .left_shift,
        0x11 => .left_ctrl,
        0x1B => .escape,
        0x09 => .tab,
        0x26 => .up,
        0x28 => .down,
        0x25 => .left,
        0x27 => .right,
        else => null,
    };
}
