const gpu = @import("gpu.zig");
const c = gpu.c;

pub const RenderPassEncoder = struct {
    handle: c.WGPURenderPassEncoder,

    pub fn setPipeline(self: RenderPassEncoder, pipeline: gpu.RenderPipeline) void {
        c.wgpuRenderPassEncoderSetPipeline(self.handle, pipeline.handle);
    }

    pub fn draw(self: RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        c.wgpuRenderPassEncoderDraw(self.handle, vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn drawIndexed(self: RenderPassEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        c.wgpuRenderPassEncoderDrawIndexed(self.handle, index_count, instance_count, first_index, base_vertex, first_instance);
    }

    pub fn drawIndirect(self: RenderPassEncoder, buffer: gpu.Buffer, offset: u64) void {
        c.wgpuRenderPassEncoderDrawIndirect(self.handle, buffer.handle, offset);
    }

    pub fn drawIndexedIndirect(self: RenderPassEncoder, buffer: gpu.Buffer, offset: u64) void {
        c.wgpuRenderPassEncoderDrawIndexedIndirect(self.handle, buffer.handle, offset);
    }

    pub fn setVertexBuffer(self: RenderPassEncoder, slot: u32, buffer: ?gpu.Buffer, offset: u64, size: u64) void {
        c.wgpuRenderPassEncoderSetVertexBuffer(self.handle, slot, if (buffer) |b| b.handle else null, offset, size);
    }

    pub fn setIndexBuffer(self: RenderPassEncoder, buffer: gpu.Buffer, format: gpu.IndexFormat, offset: u64, size: u64) void {
        c.wgpuRenderPassEncoderSetIndexBuffer(self.handle, buffer.handle, format, offset, size);
    }

    pub fn setBindGroup(self: RenderPassEncoder, group_index: u32, group: gpu.BindGroup, dynamic_offsets: ?[]const u32) void {
        const count: usize = if (dynamic_offsets) |d| d.len else 0;
        const ptr: ?[*]const u32 = if (dynamic_offsets) |d| d.ptr else null;
        c.wgpuRenderPassEncoderSetBindGroup(self.handle, group_index, group.handle, count, ptr);
    }

    pub fn setViewport(self: RenderPassEncoder, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
        c.wgpuRenderPassEncoderSetViewport(self.handle, x, y, width, height, min_depth, max_depth);
    }

    pub fn setScissorRect(self: RenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void {
        c.wgpuRenderPassEncoderSetScissorRect(self.handle, x, y, width, height);
    }

    pub fn setBlendConstant(self: RenderPassEncoder, color: *const gpu.Color) void {
        c.wgpuRenderPassEncoderSetBlendConstant(self.handle, color);
    }

    pub fn setStencilReference(self: RenderPassEncoder, reference: u32) void {
        c.wgpuRenderPassEncoderSetStencilReference(self.handle, reference);
    }

    pub fn beginOcclusionQuery(self: RenderPassEncoder, query_index: u32) void {
        c.wgpuRenderPassEncoderBeginOcclusionQuery(self.handle, query_index);
    }

    pub fn endOcclusionQuery(self: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderEndOcclusionQuery(self.handle);
    }

    pub fn executeBundles(self: RenderPassEncoder, bundles: []const gpu.RenderBundle) void {
        c.wgpuRenderPassEncoderExecuteBundles(self.handle, bundles.len, @ptrCast(bundles.ptr));
    }

    pub fn insertDebugMarker(self: RenderPassEncoder, label: gpu.StringView) void {
        c.wgpuRenderPassEncoderInsertDebugMarker(self.handle, label);
    }

    pub fn pushDebugGroup(self: RenderPassEncoder, label: gpu.StringView) void {
        c.wgpuRenderPassEncoderPushDebugGroup(self.handle, label);
    }

    pub fn popDebugGroup(self: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderPopDebugGroup(self.handle);
    }

    pub fn setLabel(self: RenderPassEncoder, label: gpu.StringView) void {
        c.wgpuRenderPassEncoderSetLabel(self.handle, label);
    }

    pub fn end(self: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderEnd(self.handle);
    }

    pub fn release(self: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderRelease(self.handle);
    }
};
