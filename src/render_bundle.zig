const gpu = @import("gpu.zig");
const c = gpu.c;

/// `extern struct` so that `[]const RenderBundle` has the same array stride
/// as `[*]const c.WGPURenderBundle`. `RenderPassEncoder.executeBundles`
/// relies on this layout equivalence to pass the slice through to the C ABI.
pub const RenderBundle = extern struct {
    handle: c.WGPURenderBundle,

    pub fn setLabel(self: RenderBundle, label: gpu.StringView) void {
        c.wgpuRenderBundleSetLabel(self.handle, label);
    }

    pub fn release(self: RenderBundle) void {
        c.wgpuRenderBundleRelease(self.handle);
    }
};
