const gpu = @import("gpu.zig");
const c = gpu.c;

pub const BindGroup = struct {
    handle: c.WGPUBindGroup,

    pub fn setLabel(self: BindGroup, label: gpu.StringView) void {
        c.wgpuBindGroupSetLabel(self.handle, label);
    }

    pub fn release(self: BindGroup) void {
        c.wgpuBindGroupRelease(self.handle);
    }
};
