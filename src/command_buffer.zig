const gpu = @import("gpu.zig");
const c = gpu.c;

/// `extern struct` so that `[]const CommandBuffer` has the same array stride
/// as `[*]const c.WGPUCommandBuffer`. `Queue.submit` relies on this layout
/// equivalence to pass the slice through to the C ABI without copying.
pub const CommandBuffer = extern struct {
    handle: c.WGPUCommandBuffer,

    pub fn setLabel(self: CommandBuffer, label: gpu.StringView) void {
        c.wgpuCommandBufferSetLabel(self.handle, label);
    }

    pub fn release(self: CommandBuffer) void {
        c.wgpuCommandBufferRelease(self.handle);
    }
};
