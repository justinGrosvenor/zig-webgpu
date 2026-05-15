const builtin = @import("builtin");
const build_options = @import("build_options");
const gpu = @import("gpu.zig");
pub const Input = @import("input.zig").Input;
pub const Key = @import("input.zig").Key;

const Platform = if (build_options.headless)
    @import("platform/headless.zig")
else switch (builtin.os.tag) {
    .macos => @import("platform/macos.zig"),
    .windows => @import("platform/windows.zig"),
    .linux => @import("platform/x11.zig"),
    else => @compileError("unsupported platform — use -Dheadless=true for headless mode"),
};

pub const Window = struct {
    pub const Config = Platform.Window.Config;

    inner: Platform.Window,

    pub fn init(config: Config) !Window {
        return .{ .inner = try Platform.Window.init(config) };
    }

    pub fn deinit(self: *Window) void {
        self.inner.deinit();
    }

    pub fn pollEvents(self: *Window) void {
        self.inner.pollEvents();
    }

    pub fn shouldClose(self: Window) bool {
        return self.inner.should_close;
    }

    pub fn createSurface(self: Window, instance: gpu.Instance) ?gpu.Surface {
        return self.inner.createSurface(instance);
    }

    pub fn getSize(self: Window) [2]u32 {
        return self.inner.getSize();
    }

    pub fn input(self: *const Window) *const Input {
        return &self.inner.input;
    }

    pub fn isHeadless() bool {
        return build_options.headless;
    }
};
