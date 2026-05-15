const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Instance = struct {
    handle: c.WGPUInstance,

    pub fn create(descriptor: ?*const c.WGPUInstanceDescriptor) ?Instance {
        const handle = c.wgpuCreateInstance(descriptor);
        if (handle == null) return null;
        return .{ .handle = handle };
    }

    /// Blocks the calling thread until adapter selection completes. Returns
    /// null on timeout or platform refusal.
    pub fn requestAdapter(self: Instance, options: ?*const c.WGPURequestAdapterOptions) ?gpu.Adapter {
        const Response = struct {
            status: c.WGPURequestAdapterStatus = 0,
            adapter: c.WGPUAdapter = null,
            completed: bool = false,
        };
        var response: Response = .{};

        _ = c.wgpuInstanceRequestAdapter(self.handle, options, .{
            .nextInChain = null,
            .mode = c.WGPUCallbackMode_AllowProcessEvents,
            .callback = &struct {
                fn cb(status: c.WGPURequestAdapterStatus, adapter: c.WGPUAdapter, _: c.WGPUStringView, userdata1: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
                    const resp: *Response = @ptrCast(@alignCast(userdata1));
                    resp.status = status;
                    resp.adapter = adapter;
                    resp.completed = true;
                }
            }.cb,
            .userdata1 = @ptrCast(&response),
            .userdata2 = null,
        });

        while (!response.completed) {
            c.wgpuInstanceProcessEvents(self.handle);
        }

        if (response.status != c.WGPURequestAdapterStatus_Success) return null;
        return .{ .handle = response.adapter };
    }

    pub fn createSurface(self: Instance, descriptor: *const c.WGPUSurfaceDescriptor) ?gpu.Surface {
        const handle = c.wgpuInstanceCreateSurface(self.handle, descriptor);
        if (handle == null) return null;
        return .{ .handle = handle };
    }

    pub fn hasWGSLLanguageFeature(self: Instance, feature: c.WGPUWGSLLanguageFeatureName) bool {
        return c.wgpuInstanceHasWGSLLanguageFeature(self.handle, feature) != 0;
    }

    pub fn processEvents(self: Instance) void {
        c.wgpuInstanceProcessEvents(self.handle);
    }

    pub fn release(self: Instance) void {
        c.wgpuInstanceRelease(self.handle);
    }
};
