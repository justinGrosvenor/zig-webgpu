const gpu = @import("gpu.zig");
const c = gpu.c;

pub const RenderBundleEncoder = struct {
    handle: c.WGPURenderBundleEncoder,

    pub fn draw(self: RenderBundleEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        c.wgpuRenderBundleEncoderDraw(self.handle, vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn drawIndexed(self: RenderBundleEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        c.wgpuRenderBundleEncoderDrawIndexed(self.handle, index_count, instance_count, first_index, base_vertex, first_instance);
    }

    pub fn drawIndirect(self: RenderBundleEncoder, buffer: gpu.Buffer, offset: u64) void {
        c.wgpuRenderBundleEncoderDrawIndirect(self.handle, buffer.handle, offset);
    }

    pub fn drawIndexedIndirect(self: RenderBundleEncoder, buffer: gpu.Buffer, offset: u64) void {
        c.wgpuRenderBundleEncoderDrawIndexedIndirect(self.handle, buffer.handle, offset);
    }

    pub fn setPipeline(self: RenderBundleEncoder, pipeline: gpu.RenderPipeline) void {
        c.wgpuRenderBundleEncoderSetPipeline(self.handle, pipeline.handle);
    }

    pub fn setBindGroup(self: RenderBundleEncoder, group_index: u32, group: gpu.BindGroup, dynamic_offsets: ?[]const u32) void {
        const count: usize = if (dynamic_offsets) |d| d.len else 0;
        const ptr: ?[*]const u32 = if (dynamic_offsets) |d| d.ptr else null;
        c.wgpuRenderBundleEncoderSetBindGroup(self.handle, group_index, group.handle, count, ptr);
    }

    pub fn setVertexBuffer(self: RenderBundleEncoder, slot: u32, buffer: ?gpu.Buffer, offset: u64, size: u64) void {
        c.wgpuRenderBundleEncoderSetVertexBuffer(self.handle, slot, if (buffer) |b| b.handle else null, offset, size);
    }

    pub fn setIndexBuffer(self: RenderBundleEncoder, buffer: gpu.Buffer, format: gpu.IndexFormat, offset: u64, size: u64) void {
        c.wgpuRenderBundleEncoderSetIndexBuffer(self.handle, buffer.handle, format, offset, size);
    }

    pub fn insertDebugMarker(self: RenderBundleEncoder, label: gpu.StringView) void {
        c.wgpuRenderBundleEncoderInsertDebugMarker(self.handle, label);
    }

    pub fn pushDebugGroup(self: RenderBundleEncoder, label: gpu.StringView) void {
        c.wgpuRenderBundleEncoderPushDebugGroup(self.handle, label);
    }

    pub fn popDebugGroup(self: RenderBundleEncoder) void {
        c.wgpuRenderBundleEncoderPopDebugGroup(self.handle);
    }

    pub fn setLabel(self: RenderBundleEncoder, label: gpu.StringView) void {
        c.wgpuRenderBundleEncoderSetLabel(self.handle, label);
    }

    pub fn finish(self: RenderBundleEncoder, descriptor: ?*const c.WGPURenderBundleDescriptor) gpu.RenderBundle {
        return .{ .handle = c.wgpuRenderBundleEncoderFinish(self.handle, descriptor) };
    }

    pub fn release(self: RenderBundleEncoder) void {
        c.wgpuRenderBundleEncoderRelease(self.handle);
    }
};
