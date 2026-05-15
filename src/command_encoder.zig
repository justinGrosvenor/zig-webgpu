const gpu = @import("gpu.zig");
const c = gpu.c;

pub const CommandEncoder = struct {
    handle: c.WGPUCommandEncoder,

    pub fn beginRenderPass(self: CommandEncoder, descriptor: *const c.WGPURenderPassDescriptor) gpu.RenderPassEncoder {
        return .{ .handle = c.wgpuCommandEncoderBeginRenderPass(self.handle, descriptor) };
    }

    pub fn beginComputePass(self: CommandEncoder, descriptor: ?*const c.WGPUComputePassDescriptor) gpu.ComputePassEncoder {
        return .{ .handle = c.wgpuCommandEncoderBeginComputePass(self.handle, descriptor) };
    }

    pub fn finish(self: CommandEncoder, descriptor: ?*const c.WGPUCommandBufferDescriptor) gpu.CommandBuffer {
        return .{ .handle = c.wgpuCommandEncoderFinish(self.handle, descriptor) };
    }

    pub fn copyBufferToBuffer(self: CommandEncoder, source: gpu.Buffer, source_offset: u64, destination: gpu.Buffer, destination_offset: u64, size: u64) void {
        c.wgpuCommandEncoderCopyBufferToBuffer(self.handle, source.handle, source_offset, destination.handle, destination_offset, size);
    }

    pub fn copyBufferToTexture(self: CommandEncoder, source: *const c.WGPUTexelCopyBufferInfo, destination: *const c.WGPUTexelCopyTextureInfo, copy_size: *const gpu.Extent3D) void {
        c.wgpuCommandEncoderCopyBufferToTexture(self.handle, source, destination, copy_size);
    }

    pub fn copyTextureToBuffer(self: CommandEncoder, source: *const c.WGPUTexelCopyTextureInfo, destination: *const c.WGPUTexelCopyBufferInfo, copy_size: *const gpu.Extent3D) void {
        c.wgpuCommandEncoderCopyTextureToBuffer(self.handle, source, destination, copy_size);
    }

    pub fn copyTextureToTexture(self: CommandEncoder, source: *const c.WGPUTexelCopyTextureInfo, destination: *const c.WGPUTexelCopyTextureInfo, copy_size: *const gpu.Extent3D) void {
        c.wgpuCommandEncoderCopyTextureToTexture(self.handle, source, destination, copy_size);
    }

    pub fn clearBuffer(self: CommandEncoder, buffer: gpu.Buffer, offset: u64, size: u64) void {
        c.wgpuCommandEncoderClearBuffer(self.handle, buffer.handle, offset, size);
    }

    pub fn resolveQuerySet(self: CommandEncoder, query_set: gpu.QuerySet, first_query: u32, query_count: u32, destination: gpu.Buffer, destination_offset: u64) void {
        c.wgpuCommandEncoderResolveQuerySet(self.handle, query_set.handle, first_query, query_count, destination.handle, destination_offset);
    }

    pub fn writeTimestamp(self: CommandEncoder, query_set: gpu.QuerySet, query_index: u32) void {
        c.wgpuCommandEncoderWriteTimestamp(self.handle, query_set.handle, query_index);
    }

    pub fn insertDebugMarker(self: CommandEncoder, label: gpu.StringView) void {
        c.wgpuCommandEncoderInsertDebugMarker(self.handle, label);
    }

    pub fn pushDebugGroup(self: CommandEncoder, label: gpu.StringView) void {
        c.wgpuCommandEncoderPushDebugGroup(self.handle, label);
    }

    pub fn popDebugGroup(self: CommandEncoder) void {
        c.wgpuCommandEncoderPopDebugGroup(self.handle);
    }

    pub fn setLabel(self: CommandEncoder, label: gpu.StringView) void {
        c.wgpuCommandEncoderSetLabel(self.handle, label);
    }

    pub fn release(self: CommandEncoder) void {
        c.wgpuCommandEncoderRelease(self.handle);
    }
};
