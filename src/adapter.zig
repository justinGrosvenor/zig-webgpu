const std = @import("std");
const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Adapter = struct {
    handle: c.WGPUAdapter,

    /// Blocks the calling thread until device creation completes. Returns
    /// null on timeout or if the requested features/limits cannot be honored.
    pub fn requestDevice(self: Adapter, instance: gpu.Instance, descriptor: ?*const c.WGPUDeviceDescriptor) ?gpu.Device {
        const Response = struct {
            status: c.WGPURequestDeviceStatus = 0,
            device: c.WGPUDevice = null,
            completed: bool = false,
        };
        var response: Response = .{};

        _ = c.wgpuAdapterRequestDevice(self.handle, descriptor, .{
            .nextInChain = null,
            .mode = c.WGPUCallbackMode_AllowProcessEvents,
            .callback = &struct {
                fn cb(status: c.WGPURequestDeviceStatus, device: c.WGPUDevice, _: c.WGPUStringView, userdata1: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
                    const resp: *Response = @ptrCast(@alignCast(userdata1));
                    resp.status = status;
                    resp.device = device;
                    resp.completed = true;
                }
            }.cb,
            .userdata1 = @ptrCast(&response),
            .userdata2 = null,
        });

        while (!response.completed) {
            c.wgpuInstanceProcessEvents(instance.handle);
        }

        if (response.status != c.WGPURequestDeviceStatus_Success) return null;
        return .{ .handle = response.device };
    }

    pub fn getLimits(self: Adapter) ?gpu.Limits {
        var limits: gpu.Limits = std.mem.zeroes(gpu.Limits);
        if (c.wgpuAdapterGetLimits(self.handle, &limits) != c.WGPUStatus_Success) return null;
        return limits;
    }

    /// Populates an `AdapterInfo` with vendor/architecture strings owned by
    /// wgpu-native. The caller must free them with `freeInfo` when finished.
    pub fn getInfo(self: Adapter) ?c.WGPUAdapterInfo {
        var info: c.WGPUAdapterInfo = std.mem.zeroes(c.WGPUAdapterInfo);
        if (c.wgpuAdapterGetInfo(self.handle, &info) != c.WGPUStatus_Success) return null;
        return info;
    }

    /// Releases the internal string buffers populated by `getInfo`. Safe to
    /// call on a zero-initialized struct.
    pub fn freeInfo(info: *c.WGPUAdapterInfo) void {
        c.wgpuAdapterInfoFreeMembers(info.*);
    }

    pub fn hasFeature(self: Adapter, feature: c.WGPUFeatureName) bool {
        return c.wgpuAdapterHasFeature(self.handle, feature) != 0;
    }

    pub fn release(self: Adapter) void {
        c.wgpuAdapterRelease(self.handle);
    }
};
