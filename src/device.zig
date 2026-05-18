const std = @import("std");
const gpu = @import("gpu.zig");
const c = gpu.c;

pub const Device = struct {
    handle: c.WGPUDevice,

    pub fn getQueue(self: Device) gpu.Queue {
        return .{ .handle = c.wgpuDeviceGetQueue(self.handle) };
    }

    pub fn createShaderModule(self: Device, descriptor: *const c.WGPUShaderModuleDescriptor) gpu.ShaderModule {
        return .{ .handle = c.wgpuDeviceCreateShaderModule(self.handle, descriptor) };
    }

    pub fn createShaderModuleWGSL(self: Device, label: []const u8, code: []const u8) gpu.ShaderModule {
        var source = gpu.ShaderSourceWGSL{
            .chain = .{ .next = null, .sType = c.WGPUSType_ShaderSourceWGSL },
            .code = gpu.stringView(code),
        };
        return self.createShaderModule(&.{
            .nextInChain = @ptrCast(&source.chain),
            .label = gpu.stringView(label),
        });
    }

    pub fn createShaderModuleSPIRV(self: Device, label: []const u8, code: []const u32) gpu.ShaderModule {
        var source = gpu.ShaderSourceSPIRV{
            .chain = .{ .next = null, .sType = c.WGPUSType_ShaderSourceSPIRV },
            .codeSize = @intCast(code.len),
            .code = code.ptr,
        };
        return self.createShaderModule(&.{
            .nextInChain = @ptrCast(&source.chain),
            .label = gpu.stringView(label),
        });
    }

    pub fn createShaderModuleGLSL(self: Device, label: []const u8, stage: c.WGPUShaderStage, code: []const u8) gpu.ShaderModule {
        var source = gpu.ShaderSourceGLSL{
            .chain = .{ .next = null, .sType = @intCast(c.WGPUNativeSType_ShaderSourceGLSL) },
            .stage = stage,
            .code = gpu.stringView(code),
            .defineCount = 0,
            .defines = null,
        };
        return self.createShaderModule(&.{
            .nextInChain = @ptrCast(&source.chain),
            .label = gpu.stringView(label),
        });
    }

    pub fn createRenderPipeline(self: Device, descriptor: *const c.WGPURenderPipelineDescriptor) gpu.RenderPipeline {
        return .{ .handle = c.wgpuDeviceCreateRenderPipeline(self.handle, descriptor) };
    }

    pub fn createComputePipeline(self: Device, descriptor: *const c.WGPUComputePipelineDescriptor) gpu.ComputePipeline {
        return .{ .handle = c.wgpuDeviceCreateComputePipeline(self.handle, descriptor) };
    }

    pub fn createCommandEncoder(self: Device, descriptor: ?*const c.WGPUCommandEncoderDescriptor) gpu.CommandEncoder {
        return .{ .handle = c.wgpuDeviceCreateCommandEncoder(self.handle, descriptor) };
    }

    pub fn createBuffer(self: Device, descriptor: *const c.WGPUBufferDescriptor) ?gpu.Buffer {
        const handle = c.wgpuDeviceCreateBuffer(self.handle, descriptor);
        if (handle == null) return null;
        return .{ .handle = handle };
    }

    pub fn createTexture(self: Device, descriptor: *const c.WGPUTextureDescriptor) gpu.Texture {
        return .{ .handle = c.wgpuDeviceCreateTexture(self.handle, descriptor) };
    }

    pub fn createBindGroup(self: Device, descriptor: *const c.WGPUBindGroupDescriptor) gpu.BindGroup {
        return .{ .handle = c.wgpuDeviceCreateBindGroup(self.handle, descriptor) };
    }

    pub fn createBindGroupLayout(self: Device, descriptor: *const c.WGPUBindGroupLayoutDescriptor) gpu.BindGroupLayout {
        return .{ .handle = c.wgpuDeviceCreateBindGroupLayout(self.handle, descriptor) };
    }

    pub fn createPipelineLayout(self: Device, descriptor: *const c.WGPUPipelineLayoutDescriptor) gpu.PipelineLayout {
        return .{ .handle = c.wgpuDeviceCreatePipelineLayout(self.handle, descriptor) };
    }

    pub fn createSampler(self: Device, descriptor: ?*const c.WGPUSamplerDescriptor) gpu.Sampler {
        return .{ .handle = c.wgpuDeviceCreateSampler(self.handle, descriptor) };
    }

    pub fn createQuerySet(self: Device, descriptor: *const c.WGPUQuerySetDescriptor) gpu.QuerySet {
        return .{ .handle = c.wgpuDeviceCreateQuerySet(self.handle, descriptor) };
    }

    pub fn createRenderBundleEncoder(self: Device, descriptor: *const c.WGPURenderBundleEncoderDescriptor) gpu.RenderBundleEncoder {
        return .{ .handle = c.wgpuDeviceCreateRenderBundleEncoder(self.handle, descriptor) };
    }

    pub fn getLimits(self: Device) ?gpu.Limits {
        var limits: gpu.Limits = std.mem.zeroes(gpu.Limits);
        if (c.wgpuDeviceGetLimits(self.handle, &limits) != c.WGPUStatus_Success) return null;
        return limits;
    }

    pub fn hasFeature(self: Device, feature: c.WGPUFeatureName) bool {
        return c.wgpuDeviceHasFeature(self.handle, feature) != 0;
    }

    pub fn getAdapterInfo(self: Device) ?c.WGPUAdapterInfo {
        var info: c.WGPUAdapterInfo = std.mem.zeroes(c.WGPUAdapterInfo);
        if (c.wgpuDeviceGetAdapterInfo(self.handle, &info) != c.WGPUStatus_Success) return null;
        return info;
    }

    pub fn pushErrorScope(self: Device, filter: c.WGPUErrorFilter) void {
        c.wgpuDevicePushErrorScope(self.handle, filter);
    }

    pub fn setLabel(self: Device, label: gpu.StringView) void {
        c.wgpuDeviceSetLabel(self.handle, label);
    }

    pub fn poll(self: Device, wait: bool, submission_index: ?*const c.WGPUSubmissionIndex) bool {
        return c.wgpuDevicePoll(self.handle, @intFromBool(wait), submission_index) != 0;
    }

    /// Tears down the device's GPU resources. Outstanding objects become
    /// invalid; the handle remains valid for `release`.
    pub fn destroy(self: Device) void {
        c.wgpuDeviceDestroy(self.handle);
    }

    /// Drops the refcount on the device handle. Call `destroy` first if you
    /// want to guarantee GPU resources are torn down at this point.
    pub fn release(self: Device) void {
        c.wgpuDeviceRelease(self.handle);
    }
};
