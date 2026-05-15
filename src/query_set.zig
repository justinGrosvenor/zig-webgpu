const gpu = @import("gpu.zig");
const c = gpu.c;

pub const QuerySet = struct {
    handle: c.WGPUQuerySet,

    pub fn getCount(self: QuerySet) u32 {
        return c.wgpuQuerySetGetCount(self.handle);
    }

    pub fn getType(self: QuerySet) c.WGPUQueryType {
        return c.wgpuQuerySetGetType(self.handle);
    }

    pub fn setLabel(self: QuerySet, label: gpu.StringView) void {
        c.wgpuQuerySetSetLabel(self.handle, label);
    }

    pub fn destroy(self: QuerySet) void {
        c.wgpuQuerySetDestroy(self.handle);
    }

    pub fn release(self: QuerySet) void {
        c.wgpuQuerySetRelease(self.handle);
    }
};
