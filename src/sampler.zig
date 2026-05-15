const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Sampler = struct {
    handle: c.WGPUSampler,

    pub fn setLabel(self: Sampler, label: gpu.StringView) void {
        c.wgpuSamplerSetLabel(self.handle, label);
    }

    pub fn release(self: Sampler) void {
        c.wgpuSamplerRelease(self.handle);
    }
};
