const std = @import("std");
const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Surface = struct {
    handle: c.WGPUSurface,

    pub fn configure(self: Surface, config: *const c.WGPUSurfaceConfiguration) void {
        c.wgpuSurfaceConfigure(self.handle, config);
    }

    pub fn unconfigure(self: Surface) void {
        c.wgpuSurfaceUnconfigure(self.handle);
    }

    /// Acquires the next swapchain image. The returned `SurfaceTexture` owns
    /// a texture handle that the caller must `release()` after the frame is
    /// submitted (and after `present()` if presenting).
    pub fn getCurrentTexture(self: Surface) !SurfaceTexture {
        var surface_texture: c.WGPUSurfaceTexture = .{
            .nextInChain = null,
            .texture = null,
            .status = 0,
        };
        c.wgpuSurfaceGetCurrentTexture(self.handle, &surface_texture);

        if (surface_texture.status != c.WGPUSurfaceGetCurrentTextureStatus_SuccessOptimal and
            surface_texture.status != c.WGPUSurfaceGetCurrentTextureStatus_SuccessSuboptimal)
        {
            return error.SurfaceTextureError;
        }

        return .{
            .texture = .{ .handle = surface_texture.texture },
            .suboptimal = surface_texture.status == c.WGPUSurfaceGetCurrentTextureStatus_SuccessSuboptimal,
        };
    }

    pub fn present(self: Surface) !void {
        if (c.wgpuSurfacePresent(self.handle) != c.WGPUStatus_Success) return error.PresentFailed;
    }

    /// Populates a `SurfaceCapabilities` with format/present-mode arrays owned
    /// by wgpu-native. The caller must free them with `freeCapabilities`.
    pub fn getCapabilities(self: Surface, adapter: gpu.Adapter) ?c.WGPUSurfaceCapabilities {
        var caps: c.WGPUSurfaceCapabilities = std.mem.zeroes(c.WGPUSurfaceCapabilities);
        if (c.wgpuSurfaceGetCapabilities(self.handle, adapter.handle, &caps) != c.WGPUStatus_Success) return null;
        return caps;
    }

    /// Releases the internal arrays populated by `getCapabilities`. Safe to
    /// call on a zero-initialized struct.
    pub fn freeCapabilities(caps: *c.WGPUSurfaceCapabilities) void {
        c.wgpuSurfaceCapabilitiesFreeMembers(caps.*);
    }

    pub fn setLabel(self: Surface, label: gpu.StringView) void {
        c.wgpuSurfaceSetLabel(self.handle, label);
    }

    pub fn release(self: Surface) void {
        c.wgpuSurfaceRelease(self.handle);
    }
};

pub const SurfaceTexture = struct {
    texture: gpu.Texture,
    /// True when the swapchain configuration drifted (e.g. window resize) but
    /// the texture is still usable for this frame. Reconfigure the surface
    /// before the next acquire.
    suboptimal: bool,

    /// Releases the underlying texture handle. Call after the frame's command
    /// buffer is submitted (and after `Surface.present` if presenting).
    pub fn release(self: SurfaceTexture) void {
        self.texture.release();
    }
};
