const gpu = @import("gpu.zig");
const c = gpu.c;

pub const ShaderModule = struct {
    handle: c.WGPUShaderModule,

    pub fn setLabel(self: ShaderModule, label: gpu.StringView) void {
        c.wgpuShaderModuleSetLabel(self.handle, label);
    }

    pub fn release(self: ShaderModule) void {
        c.wgpuShaderModuleRelease(self.handle);
    }
};
