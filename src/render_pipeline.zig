const gpu = @import("gpu.zig");
const c = gpu.c;

pub const RenderPipeline = struct {
    handle: c.WGPURenderPipeline,

    pub fn getBindGroupLayout(self: RenderPipeline, group_index: u32) gpu.BindGroupLayout {
        return .{ .handle = c.wgpuRenderPipelineGetBindGroupLayout(self.handle, group_index) };
    }

    pub fn setLabel(self: RenderPipeline, label: gpu.StringView) void {
        c.wgpuRenderPipelineSetLabel(self.handle, label);
    }

    pub fn release(self: RenderPipeline) void {
        c.wgpuRenderPipelineRelease(self.handle);
    }
};
