const std = @import("std");
const gpu = @import("gpu");
const vert_spv = @import("vert_spv");
const frag_spv = @import("frag_spv");

pub fn main() !void {
    var window = try gpu.Window.init(.{
        .title = "zig-webgpu GLSL triangle",
        .width = 800,
        .height = 600,
    });
    defer window.deinit();

    const instance = gpu.Instance.create(null) orelse return error.NoInstance;
    defer instance.release();

    const surface = window.createSurface(instance) orelse return error.NoSurface;
    defer surface.release();

    const adapter = instance.requestAdapter(&.{
        .nextInChain = null,
        .compatibleSurface = surface.handle,
        .powerPreference = gpu.c.WGPUPowerPreference_HighPerformance,
        .backendType = gpu.c.WGPUBackendType_Undefined,
        .forceFallbackAdapter = 0,
    }) orelse return error.NoAdapter;
    defer adapter.release();

    const device = adapter.requestDevice(instance, null) orelse return error.NoDevice;
    defer device.release();

    const queue = device.getQueue();
    defer queue.release();

    const vert_shader = gpu.spirv.load(device, "triangle vert", vert_spv.bytes);
    defer vert_shader.release();
    const frag_shader = gpu.spirv.load(device, "triangle frag", frag_spv.bytes);
    defer frag_shader.release();

    const caps = surface.getCapabilities(adapter) orelse return error.NoCaps;
    const format = caps.formats[0];

    const blend_state = gpu.BlendState{
        .color = .{
            .srcFactor = gpu.c.WGPUBlendFactor_One,
            .dstFactor = gpu.c.WGPUBlendFactor_Zero,
            .operation = gpu.c.WGPUBlendOperation_Add,
        },
        .alpha = .{
            .srcFactor = gpu.c.WGPUBlendFactor_One,
            .dstFactor = gpu.c.WGPUBlendFactor_Zero,
            .operation = gpu.c.WGPUBlendOperation_Add,
        },
    };
    const color_targets = [_]gpu.ColorTargetState{.{
        .format = format,
        .blend = &blend_state,
        .writeMask = gpu.c.WGPUColorWriteMask_All,
        .nextInChain = null,
    }};
    var fragment_state = gpu.FragmentState{
        .module = frag_shader.handle,
        .entryPoint = gpu.stringView("main"),
        .targetCount = 1,
        .targets = &color_targets,
        .constantCount = 0,
        .constants = null,
        .nextInChain = null,
    };

    var pipeline_desc = std.mem.zeroes(gpu.RenderPipelineDescriptor);
    pipeline_desc.label = gpu.stringView("glsl triangle pipeline");
    pipeline_desc.vertex = .{
        .module = vert_shader.handle,
        .entryPoint = gpu.stringView("main"),
        .bufferCount = 0,
        .buffers = null,
        .constantCount = 0,
        .constants = null,
        .nextInChain = null,
    };
    pipeline_desc.fragment = &fragment_state;
    pipeline_desc.primitive = .{
        .topology = gpu.c.WGPUPrimitiveTopology_TriangleList,
        .stripIndexFormat = gpu.c.WGPUIndexFormat_Undefined,
        .frontFace = gpu.c.WGPUFrontFace_CCW,
        .cullMode = gpu.c.WGPUCullMode_None,
        .unclippedDepth = 0,
        .nextInChain = null,
    };
    pipeline_desc.multisample = .{
        .count = 1,
        .mask = 0xFFFFFFFF,
        .alphaToCoverageEnabled = 0,
        .nextInChain = null,
    };

    const pipeline = device.createRenderPipeline(&pipeline_desc);
    defer pipeline.release();

    const size = window.getSize();
    surface.configure(&.{
        .nextInChain = null,
        .device = device.handle,
        .format = format,
        .usage = gpu.c.WGPUTextureUsage_RenderAttachment,
        .width = size[0],
        .height = size[1],
        .presentMode = gpu.c.WGPUPresentMode_Fifo,
        .alphaMode = gpu.c.WGPUCompositeAlphaMode_Auto,
        .viewFormatCount = 0,
        .viewFormats = null,
    });

    while (!window.shouldClose()) {
        window.pollEvents();

        const cur_size = window.getSize();
        if (cur_size[0] == 0 or cur_size[1] == 0) continue;

        const st = surface.getCurrentTexture() catch continue;
        defer st.release();
        const view = st.texture.createView(null);
        defer view.release();

        const encoder = device.createCommandEncoder(&.{
            .nextInChain = null,
            .label = gpu.stringView("frame encoder"),
        });

        const color_attachment = gpu.RenderPassColorAttachment{
            .view = view.handle,
            .resolveTarget = null,
            .loadOp = gpu.c.WGPULoadOp_Clear,
            .storeOp = gpu.c.WGPUStoreOp_Store,
            .clearValue = .{ .r = 0.05, .g = 0.05, .b = 0.05, .a = 1.0 },
            .depthSlice = gpu.c.WGPU_DEPTH_SLICE_UNDEFINED,
            .nextInChain = null,
        };
        const pass = encoder.beginRenderPass(&.{
            .nextInChain = null,
            .label = gpu.stringView("render pass"),
            .colorAttachmentCount = 1,
            .colorAttachments = @ptrCast(&color_attachment),
            .depthStencilAttachment = null,
            .occlusionQuerySet = null,
            .timestampWrites = null,
        });

        pass.setPipeline(pipeline);
        pass.draw(3, 1, 0, 0);
        pass.end();
        pass.release();

        const cmd = encoder.finish(null);
        encoder.release();

        queue.submit(&.{cmd});
        cmd.release();

        try surface.present();
    }
}
