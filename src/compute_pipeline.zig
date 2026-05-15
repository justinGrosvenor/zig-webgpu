const gpu = @import("gpu.zig");
const c = gpu.c;

pub const ComputePipeline = struct {
    handle: c.WGPUComputePipeline,

    pub fn getBindGroupLayout(self: ComputePipeline, group_index: u32) gpu.BindGroupLayout {
        return .{ .handle = c.wgpuComputePipelineGetBindGroupLayout(self.handle, group_index) };
    }

    pub fn setLabel(self: ComputePipeline, label: gpu.StringView) void {
        c.wgpuComputePipelineSetLabel(self.handle, label);
    }

    pub fn release(self: ComputePipeline) void {
        c.wgpuComputePipelineRelease(self.handle);
    }
};
