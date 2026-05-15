const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Texture = struct {
    handle: c.WGPUTexture,

    pub fn createView(self: Texture, descriptor: ?*const c.WGPUTextureViewDescriptor) gpu.TextureView {
        return .{ .handle = c.wgpuTextureCreateView(self.handle, descriptor) };
    }

    pub fn getWidth(self: Texture) u32 {
        return c.wgpuTextureGetWidth(self.handle);
    }

    pub fn getHeight(self: Texture) u32 {
        return c.wgpuTextureGetHeight(self.handle);
    }

    pub fn getFormat(self: Texture) gpu.TextureFormat {
        return c.wgpuTextureGetFormat(self.handle);
    }

    pub fn getDimension(self: Texture) c.WGPUTextureDimension {
        return c.wgpuTextureGetDimension(self.handle);
    }

    pub fn getDepthOrArrayLayers(self: Texture) u32 {
        return c.wgpuTextureGetDepthOrArrayLayers(self.handle);
    }

    pub fn getMipLevelCount(self: Texture) u32 {
        return c.wgpuTextureGetMipLevelCount(self.handle);
    }

    pub fn getSampleCount(self: Texture) u32 {
        return c.wgpuTextureGetSampleCount(self.handle);
    }

    pub fn getTextureBindingViewDimension(self: Texture) c.WGPUTextureViewDimension {
        return c.wgpuTextureGetTextureBindingViewDimension(self.handle);
    }

    pub fn getUsage(self: Texture) gpu.TextureUsage {
        return c.wgpuTextureGetUsage(self.handle);
    }

    pub fn setLabel(self: Texture, label: gpu.StringView) void {
        c.wgpuTextureSetLabel(self.handle, label);
    }

    /// Frees the GPU-side texture memory immediately while leaving the handle
    /// valid for cleanup. Pair with `release` to drop the handle itself.
    pub fn destroy(self: Texture) void {
        c.wgpuTextureDestroy(self.handle);
    }

    /// Decrements the refcount on the handle. Use `destroy` first to also
    /// free the GPU memory, otherwise the allocation lives until the last
    /// outstanding reference is released.
    pub fn release(self: Texture) void {
        c.wgpuTextureRelease(self.handle);
    }
};
