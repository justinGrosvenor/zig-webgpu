pub const c = @cImport({
    @cInclude("webgpu.h");
    @cInclude("wgpu.h");
});

// Object types
pub const Instance = @import("instance.zig").Instance;
pub const Adapter = @import("adapter.zig").Adapter;
pub const Device = @import("device.zig").Device;
pub const Queue = @import("queue.zig").Queue;
pub const Surface = @import("surface.zig").Surface;
pub const CommandEncoder = @import("command_encoder.zig").CommandEncoder;
pub const CommandBuffer = @import("command_buffer.zig").CommandBuffer;
pub const RenderPassEncoder = @import("render_pass_encoder.zig").RenderPassEncoder;
pub const RenderPipeline = @import("render_pipeline.zig").RenderPipeline;
pub const ComputePassEncoder = @import("compute_pass_encoder.zig").ComputePassEncoder;
pub const ComputePipeline = @import("compute_pipeline.zig").ComputePipeline;
pub const ShaderModule = @import("shader_module.zig").ShaderModule;
pub const Buffer = @import("buffer.zig").Buffer;
pub const Texture = @import("texture.zig").Texture;
pub const TextureView = @import("texture_view.zig").TextureView;
pub const BindGroup = @import("bind_group.zig").BindGroup;
pub const BindGroupLayout = @import("bind_group_layout.zig").BindGroupLayout;
pub const PipelineLayout = @import("pipeline_layout.zig").PipelineLayout;
pub const Sampler = @import("sampler.zig").Sampler;
pub const QuerySet = @import("query_set.zig").QuerySet;
pub const RenderBundle = @import("render_bundle.zig").RenderBundle;
pub const RenderBundleEncoder = @import("render_bundle_encoder.zig").RenderBundleEncoder;
pub const SurfaceTexture = @import("surface.zig").SurfaceTexture;
pub const Window = @import("window.zig").Window;
pub const Input = @import("input.zig").Input;
pub const Key = @import("input.zig").Key;
pub const spirv = @import("spirv.zig");

// Struct types
pub const Color = c.WGPUColor;
pub const Extent3D = c.WGPUExtent3D;
pub const Origin3D = c.WGPUOrigin3D;
pub const Limits = c.WGPULimits;
pub const StringView = c.WGPUStringView;
pub const BlendState = c.WGPUBlendState;
pub const BlendComponent = c.WGPUBlendComponent;
pub const StencilFaceState = c.WGPUStencilFaceState;
pub const VertexAttribute = c.WGPUVertexAttribute;

// Enum types
pub const TextureFormat = c.WGPUTextureFormat;
pub const TextureDimension = c.WGPUTextureDimension;
pub const TextureViewDimension = c.WGPUTextureViewDimension;
pub const TextureAspect = c.WGPUTextureAspect;
pub const PresentMode = c.WGPUPresentMode;
pub const CompositeAlphaMode = c.WGPUCompositeAlphaMode;
pub const TextureUsage = c.WGPUTextureUsage;
pub const LoadOp = c.WGPULoadOp;
pub const StoreOp = c.WGPUStoreOp;
pub const PrimitiveTopology = c.WGPUPrimitiveTopology;
pub const FrontFace = c.WGPUFrontFace;
pub const CullMode = c.WGPUCullMode;
pub const IndexFormat = c.WGPUIndexFormat;
pub const VertexFormat = c.WGPUVertexFormat;
pub const VertexStepMode = c.WGPUVertexStepMode;
pub const BlendFactor = c.WGPUBlendFactor;
pub const BlendOperation = c.WGPUBlendOperation;
pub const ColorWriteMask = c.WGPUColorWriteMask;
pub const CompareFunction = c.WGPUCompareFunction;
pub const StencilOperation = c.WGPUStencilOperation;
pub const BufferUsage = c.WGPUBufferUsage;
pub const BufferMapState = c.WGPUBufferMapState;
pub const MapMode = c.WGPUMapMode;
pub const ShaderStage = c.WGPUShaderStage;
pub const FeatureLevel = c.WGPUFeatureLevel;
pub const FeatureName = c.WGPUFeatureName;
pub const PowerPreference = c.WGPUPowerPreference;
pub const BackendType = c.WGPUBackendType;
pub const Status = c.WGPUStatus;
pub const RequestDeviceStatus = c.WGPURequestDeviceStatus;
pub const RequestAdapterStatus = c.WGPURequestAdapterStatus;
pub const WaitStatus = c.WGPUWaitStatus;
pub const SurfaceGetCurrentTextureStatus = c.WGPUSurfaceGetCurrentTextureStatus;
pub const ErrorFilter = c.WGPUErrorFilter;
pub const ErrorType = c.WGPUErrorType;
pub const QueryType = c.WGPUQueryType;
pub const SamplerBindingType = c.WGPUSamplerBindingType;
pub const TextureSampleType = c.WGPUTextureSampleType;
pub const StorageTextureAccess = c.WGPUStorageTextureAccess;
pub const BufferBindingType = c.WGPUBufferBindingType;
pub const FilterMode = c.WGPUFilterMode;
pub const MipmapFilterMode = c.WGPUMipmapFilterMode;
pub const AddressMode = c.WGPUAddressMode;
pub const InstanceFeatureName = c.WGPUInstanceFeatureName;
pub const WGSLLanguageFeatureName = c.WGPUWGSLLanguageFeatureName;
pub const DeviceLostReason = c.WGPUDeviceLostReason;
pub const MapAsyncStatus = c.WGPUMapAsyncStatus;
pub const CallbackMode = c.WGPUCallbackMode;

// Descriptor types (pass-through to C)
pub const SurfaceConfiguration = c.WGPUSurfaceConfiguration;
pub const SurfaceCapabilities = c.WGPUSurfaceCapabilities;
pub const RenderPassDescriptor = c.WGPURenderPassDescriptor;
pub const RenderPassColorAttachment = c.WGPURenderPassColorAttachment;
pub const RenderPassDepthStencilAttachment = c.WGPURenderPassDepthStencilAttachment;
pub const RenderPipelineDescriptor = c.WGPURenderPipelineDescriptor;
pub const ComputePipelineDescriptor = c.WGPUComputePipelineDescriptor;
pub const ShaderModuleDescriptor = c.WGPUShaderModuleDescriptor;
pub const BufferDescriptor = c.WGPUBufferDescriptor;
pub const TextureDescriptor = c.WGPUTextureDescriptor;
pub const TextureViewDescriptor = c.WGPUTextureViewDescriptor;
pub const SamplerDescriptor = c.WGPUSamplerDescriptor;
pub const BindGroupDescriptor = c.WGPUBindGroupDescriptor;
pub const BindGroupEntry = c.WGPUBindGroupEntry;
pub const BindGroupLayoutDescriptor = c.WGPUBindGroupLayoutDescriptor;
pub const BindGroupLayoutEntry = c.WGPUBindGroupLayoutEntry;
pub const PipelineLayoutDescriptor = c.WGPUPipelineLayoutDescriptor;
pub const VertexState = c.WGPUVertexState;
pub const VertexBufferLayout = c.WGPUVertexBufferLayout;
pub const FragmentState = c.WGPUFragmentState;
pub const PrimitiveState = c.WGPUPrimitiveState;
pub const DepthStencilState = c.WGPUDepthStencilState;
pub const MultisampleState = c.WGPUMultisampleState;
pub const ColorTargetState = c.WGPUColorTargetState;
pub const ComputeState = c.WGPUComputeState;
pub const CommandEncoderDescriptor = c.WGPUCommandEncoderDescriptor;
pub const CommandBufferDescriptor = c.WGPUCommandBufferDescriptor;
pub const QuerySetDescriptor = c.WGPUQuerySetDescriptor;
pub const RenderBundleEncoderDescriptor = c.WGPURenderBundleEncoderDescriptor;
pub const RenderBundleDescriptor = c.WGPURenderBundleDescriptor;
pub const ComputePassDescriptor = c.WGPUComputePassDescriptor;
pub const RequestAdapterOptions = c.WGPURequestAdapterOptions;
pub const DeviceDescriptor = c.WGPUDeviceDescriptor;
pub const InstanceDescriptor = c.WGPUInstanceDescriptor;
pub const SurfaceDescriptor = c.WGPUSurfaceDescriptor;
pub const AdapterInfo = c.WGPUAdapterInfo;
pub const TexelCopyBufferInfo = c.WGPUTexelCopyBufferInfo;
pub const TexelCopyTextureInfo = c.WGPUTexelCopyTextureInfo;
pub const TexelCopyBufferLayout = c.WGPUTexelCopyBufferLayout;

// wgpu-native extension types
pub const InstanceLimits = c.WGPUInstanceLimits;
pub const SubmissionIndex = c.WGPUSubmissionIndex;
pub const LogLevel = c.WGPULogLevel;

// Chained struct types
pub const ShaderSourceWGSL = c.WGPUShaderSourceWGSL;
pub const ShaderSourceSPIRV = c.WGPUShaderSourceSPIRV;
pub const ShaderSourceGLSL = c.WGPUShaderSourceGLSL;
pub const ShaderDefine = c.WGPUShaderDefine;
pub const NativeSType = c.WGPUNativeSType;
pub const SurfaceSourceMetalLayer = c.WGPUSurfaceSourceMetalLayer;
pub const SurfaceSourceWindowsHWND = c.WGPUSurfaceSourceWindowsHWND;
pub const SurfaceSourceXlibWindow = c.WGPUSurfaceSourceXlibWindow;
pub const SurfaceSourceXCBWindow = c.WGPUSurfaceSourceXCBWindow;
pub const SurfaceSourceWaylandSurface = c.WGPUSurfaceSourceWaylandSurface;
pub const SurfaceSourceAndroidNativeWindow = c.WGPUSurfaceSourceAndroidNativeWindow;
pub const ChainedStruct = c.WGPUChainedStruct;
pub const SType = c.WGPUSType;

comptime {
    if (@sizeOf(CommandBuffer) != @sizeOf(c.WGPUCommandBuffer))
        @compileError("CommandBuffer layout mismatch — @ptrCast in Queue.submit is unsound");
    if (@sizeOf(RenderBundle) != @sizeOf(c.WGPURenderBundle))
        @compileError("RenderBundle layout mismatch — @ptrCast in RenderPassEncoder.executeBundles is unsound");
}

pub fn getInstanceLimits() ?c.WGPUInstanceLimits {
    var limits: c.WGPUInstanceLimits = std.mem.zeroes(c.WGPUInstanceLimits);
    if (c.wgpuGetInstanceLimits(&limits) != c.WGPUStatus_Success) return null;
    return limits;
}

pub fn hasInstanceFeature(feature: c.WGPUInstanceFeatureName) bool {
    return c.wgpuHasInstanceFeature(feature) != 0;
}

pub fn stringView(s: []const u8) StringView {
    return .{ .data = s.ptr, .length = s.len };
}

pub fn stringViewSentinel(s: [*:0]const u8) StringView {
    return .{ .data = s, .length = c.WGPU_STRLEN };
}

test {
    _ = @import("instance.zig");
    _ = @import("adapter.zig");
    _ = @import("device.zig");
    _ = @import("queue.zig");
    _ = @import("surface.zig");
    _ = @import("command_encoder.zig");
    _ = @import("command_buffer.zig");
    _ = @import("render_pass_encoder.zig");
    _ = @import("render_pipeline.zig");
    _ = @import("compute_pass_encoder.zig");
    _ = @import("compute_pipeline.zig");
    _ = @import("shader_module.zig");
    _ = @import("buffer.zig");
    _ = @import("texture.zig");
    _ = @import("texture_view.zig");
    _ = @import("bind_group.zig");
    _ = @import("bind_group_layout.zig");
    _ = @import("pipeline_layout.zig");
    _ = @import("sampler.zig");
    _ = @import("query_set.zig");
    _ = @import("render_bundle.zig");
    _ = @import("render_bundle_encoder.zig");
}

const std = @import("std");

test "create instance and device" {
    const instance = Instance.create(null) orelse return error.SkipZigTest;
    defer instance.release();

    const adapter = instance.requestAdapter(null) orelse return error.SkipZigTest;
    defer adapter.release();

    const device = adapter.requestDevice(instance, null) orelse return error.SkipZigTest;
    defer device.release();

    const queue = device.getQueue();
    defer queue.release();

    const limits = device.getLimits() orelse return error.SkipZigTest;
    try std.testing.expect(limits.maxTextureDimension2D > 0);
}

test "adapter info and limits" {
    const instance = Instance.create(null) orelse return error.SkipZigTest;
    defer instance.release();

    const adapter = instance.requestAdapter(null) orelse return error.SkipZigTest;
    defer adapter.release();

    const limits = adapter.getLimits() orelse return error.SkipZigTest;
    try std.testing.expect(limits.maxTextureDimension2D > 0);
    try std.testing.expect(limits.maxBindGroups > 0);

    const info = adapter.getInfo() orelse return error.SkipZigTest;
    _ = info;
}

test "buffer map and read" {
    const instance = Instance.create(null) orelse return error.SkipZigTest;
    defer instance.release();

    const adapter = instance.requestAdapter(null) orelse return error.SkipZigTest;
    defer adapter.release();

    const device = adapter.requestDevice(instance, null) orelse return error.SkipZigTest;
    defer device.release();

    const buffer = device.createBuffer(&.{
        .nextInChain = null,
        .label = stringView("map test"),
        .usage = c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst,
        .size = 64,
        .mappedAtCreation = 0,
    }) orelse return error.SkipZigTest;
    defer buffer.release();

    try buffer.mapAsync(instance, c.WGPUMapMode_Read, 0, 64);
    const ptr = buffer.getConstMappedRange(0, 64) orelse return error.SkipZigTest;
    _ = ptr;
    buffer.unmap();
}

test "create buffer and query properties" {
    const instance = Instance.create(null) orelse return error.SkipZigTest;
    defer instance.release();

    const adapter = instance.requestAdapter(null) orelse return error.SkipZigTest;
    defer adapter.release();

    const device = adapter.requestDevice(instance, null) orelse return error.SkipZigTest;
    defer device.release();

    const buffer = device.createBuffer(&.{
        .nextInChain = null,
        .label = stringView("test buffer"),
        .usage = c.WGPUBufferUsage_Vertex | c.WGPUBufferUsage_CopyDst,
        .size = 256,
        .mappedAtCreation = 0,
    }) orelse return error.SkipZigTest;
    defer buffer.release();

    try std.testing.expectEqual(@as(u64, 256), buffer.getSize());
}
