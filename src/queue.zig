const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Queue = struct {
    handle: c.WGPUQueue,

    pub fn submit(self: Queue, commands: []const gpu.CommandBuffer) void {
        const raw: [*]const c.WGPUCommandBuffer = @ptrCast(commands.ptr);
        c.wgpuQueueSubmit(self.handle, commands.len, raw);
    }

    pub fn writeBuffer(self: Queue, buffer: gpu.Buffer, offset: u64, data: []const u8) void {
        c.wgpuQueueWriteBuffer(self.handle, buffer.handle, offset, data.ptr, data.len);
    }

    pub fn writeTexture(self: Queue, destination: *const c.WGPUTexelCopyTextureInfo, data: []const u8, data_layout: *const c.WGPUTexelCopyBufferLayout, write_size: *const gpu.Extent3D) void {
        c.wgpuQueueWriteTexture(self.handle, destination, data.ptr, data.len, data_layout, write_size);
    }

    pub fn setLabel(self: Queue, label: gpu.StringView) void {
        c.wgpuQueueSetLabel(self.handle, label);
    }

    pub fn release(self: Queue) void {
        c.wgpuQueueRelease(self.handle);
    }
};
