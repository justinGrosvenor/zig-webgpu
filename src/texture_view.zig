const gpu = @import("gpu.zig");
const c = gpu.c;

pub const TextureView = struct {
    handle: c.WGPUTextureView,

    pub fn setLabel(self: TextureView, label: gpu.StringView) void {
        c.wgpuTextureViewSetLabel(self.handle, label);
    }

    pub fn release(self: TextureView) void {
        c.wgpuTextureViewRelease(self.handle);
    }
};
