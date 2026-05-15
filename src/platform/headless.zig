const gpu = @import("../gpu.zig");
const c = gpu.c;
const Input = @import("../input.zig").Input;

pub const Window = struct {
    width: u32,
    height: u32,
    should_close: bool,
    input: Input = .{},

    pub const Config = struct {
        title: [*:0]const u8 = "zig-webgpu",
        width: u32 = 800,
        height: u32 = 600,
    };

    pub fn init(config: Config) !Window {
        return .{
            .width = config.width,
            .height = config.height,
            .should_close = false,
        };
    }

    pub fn deinit(self: *Window) void {
        self.* = undefined;
    }

    pub fn pollEvents(_: *Window) void {}

    pub fn createSurface(_: Window, _: gpu.Instance) ?gpu.Surface {
        return null;
    }

    pub fn getSize(self: Window) [2]u32 {
        return .{ self.width, self.height };
    }
};
