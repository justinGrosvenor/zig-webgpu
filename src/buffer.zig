const std = @import("std");
const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Buffer = struct {
    handle: c.WGPUBuffer,

    pub fn getMappedRange(self: Buffer, offset: usize, size: usize) ?[*]u8 {
        return @ptrCast(c.wgpuBufferGetMappedRange(self.handle, offset, size));
    }

    pub fn getConstMappedRange(self: Buffer, offset: usize, size: usize) ?[*]const u8 {
        return @ptrCast(c.wgpuBufferGetConstMappedRange(self.handle, offset, size));
    }

    /// Blocks the calling thread by spinning `wgpuInstanceProcessEvents` until
    /// the map operation completes. Not suitable for use from inside a frame
    /// callback or anywhere the caller cannot afford to stall.
    pub fn mapAsync(self: Buffer, instance: gpu.Instance, mode: gpu.MapMode, offset: usize, size: usize) !void {
        const Response = struct {
            status: c.WGPUMapAsyncStatus = 0,
            completed: bool = false,
        };
        var response: Response = .{};

        _ = c.wgpuBufferMapAsync(self.handle, mode, offset, size, .{
            .nextInChain = null,
            .mode = c.WGPUCallbackMode_AllowProcessEvents,
            .callback = &struct {
                fn cb(status: c.WGPUMapAsyncStatus, _: c.WGPUStringView, userdata1: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
                    const resp: *Response = @ptrCast(@alignCast(userdata1));
                    resp.status = status;
                    resp.completed = true;
                }
            }.cb,
            .userdata1 = @ptrCast(&response),
            .userdata2 = null,
        });

        while (!response.completed) {
            c.wgpuInstanceProcessEvents(instance.handle);
        }

        if (response.status != c.WGPUMapAsyncStatus_Success) return error.MapFailed;
    }

    pub fn unmap(self: Buffer) void {
        c.wgpuBufferUnmap(self.handle);
    }

    pub fn getSize(self: Buffer) u64 {
        return c.wgpuBufferGetSize(self.handle);
    }

    pub fn getUsage(self: Buffer) gpu.BufferUsage {
        return c.wgpuBufferGetUsage(self.handle);
    }

    pub fn getMapState(self: Buffer) c.WGPUBufferMapState {
        return c.wgpuBufferGetMapState(self.handle);
    }

    pub fn readMappedRange(self: Buffer, offset: usize, data: []u8) !void {
        if (c.wgpuBufferReadMappedRange(self.handle, offset, data.ptr, data.len) != c.WGPUStatus_Success)
            return error.ReadFailed;
    }

    pub fn writeMappedRange(self: Buffer, offset: usize, data: []const u8) !void {
        if (c.wgpuBufferWriteMappedRange(self.handle, offset, data.ptr, data.len) != c.WGPUStatus_Success)
            return error.WriteFailed;
    }

    pub fn setLabel(self: Buffer, label: gpu.StringView) void {
        c.wgpuBufferSetLabel(self.handle, label);
    }

    /// Frees the GPU-side allocation immediately while leaving the handle
    /// valid for cleanup. Pair with `release` to drop the handle itself.
    pub fn destroy(self: Buffer) void {
        c.wgpuBufferDestroy(self.handle);
    }

    /// Decrements the refcount on the handle. Use `destroy` first to also
    /// free the GPU memory, otherwise the allocation lives until the last
    /// outstanding reference is released.
    pub fn release(self: Buffer) void {
        c.wgpuBufferRelease(self.handle);
    }
};
