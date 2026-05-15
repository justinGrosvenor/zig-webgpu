const gpu = @import("gpu.zig");
const c = gpu.c;

pub const ComputePassEncoder = struct {
    handle: c.WGPUComputePassEncoder,

    pub fn dispatchWorkgroups(self: ComputePassEncoder, x: u32, y: u32, z: u32) void {
        c.wgpuComputePassEncoderDispatchWorkgroups(self.handle, x, y, z);
    }

    pub fn dispatchWorkgroupsIndirect(self: ComputePassEncoder, buffer: gpu.Buffer, offset: u64) void {
        c.wgpuComputePassEncoderDispatchWorkgroupsIndirect(self.handle, buffer.handle, offset);
    }

    pub fn setPipeline(self: ComputePassEncoder, pipeline: gpu.ComputePipeline) void {
        c.wgpuComputePassEncoderSetPipeline(self.handle, pipeline.handle);
    }

    pub fn setBindGroup(self: ComputePassEncoder, group_index: u32, group: gpu.BindGroup, dynamic_offsets: ?[]const u32) void {
        const count: usize = if (dynamic_offsets) |d| d.len else 0;
        const ptr: ?[*]const u32 = if (dynamic_offsets) |d| d.ptr else null;
        c.wgpuComputePassEncoderSetBindGroup(self.handle, group_index, group.handle, count, ptr);
    }

    pub fn insertDebugMarker(self: ComputePassEncoder, label: gpu.StringView) void {
        c.wgpuComputePassEncoderInsertDebugMarker(self.handle, label);
    }

    pub fn pushDebugGroup(self: ComputePassEncoder, label: gpu.StringView) void {
        c.wgpuComputePassEncoderPushDebugGroup(self.handle, label);
    }

    pub fn popDebugGroup(self: ComputePassEncoder) void {
        c.wgpuComputePassEncoderPopDebugGroup(self.handle);
    }

    pub fn setLabel(self: ComputePassEncoder, label: gpu.StringView) void {
        c.wgpuComputePassEncoderSetLabel(self.handle, label);
    }

    pub fn end(self: ComputePassEncoder) void {
        c.wgpuComputePassEncoderEnd(self.handle);
    }

    pub fn release(self: ComputePassEncoder) void {
        c.wgpuComputePassEncoderRelease(self.handle);
    }
};
