const gpu = @import("gpu.zig");
const c = gpu.c;

pub const BindGroupLayout = struct {
    handle: c.WGPUBindGroupLayout,

    pub fn setLabel(self: BindGroupLayout, label: gpu.StringView) void {
        c.wgpuBindGroupLayoutSetLabel(self.handle, label);
    }

    pub fn release(self: BindGroupLayout) void {
        c.wgpuBindGroupLayoutRelease(self.handle);
    }
};
