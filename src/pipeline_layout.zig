const gpu = @import("gpu.zig");
const c = gpu.c;

pub const PipelineLayout = struct {
    handle: c.WGPUPipelineLayout,

    pub fn setLabel(self: PipelineLayout, label: gpu.StringView) void {
        c.wgpuPipelineLayoutSetLabel(self.handle, label);
    }

    pub fn release(self: PipelineLayout) void {
        c.wgpuPipelineLayoutRelease(self.handle);
    }
};
