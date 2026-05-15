const std = @import("std");
const gpu = @import("gpu");

const shader_code =
    \\@group(0) @binding(0) var<storage, read> input: array<f32>;
    \\@group(0) @binding(1) var<storage, read_write> output: array<f32>;
    \\
    \\@compute @workgroup_size(64)
    \\fn main(@builtin(global_invocation_id) id: vec3u) {
    \\    let i = id.x;
    \\    if (i < arrayLength(&input)) {
    \\        output[i] = input[i] * input[i];
    \\    }
    \\}
;

pub fn main() !void {

    const instance = gpu.Instance.create(null) orelse return error.NoInstance;
    defer instance.release();

    const adapter = instance.requestAdapter(null) orelse return error.NoAdapter;
    defer adapter.release();

    const device = adapter.requestDevice(instance, null) orelse return error.NoDevice;
    defer device.release();

    const queue = device.getQueue();
    defer queue.release();

    var wgsl_source = gpu.ShaderSourceWGSL{
        .chain = .{ .next = null, .sType = gpu.c.WGPUSType_ShaderSourceWGSL },
        .code = gpu.stringView(shader_code),
    };
    const shader = device.createShaderModule(&.{
        .nextInChain = @ptrCast(&wgsl_source.chain),
        .label = gpu.stringView("compute shader"),
    });
    defer shader.release();

    const pipeline = device.createComputePipeline(&.{
        .nextInChain = null,
        .label = gpu.stringView("square pipeline"),
        .layout = null,
        .compute = .{
            .module = shader.handle,
            .entryPoint = gpu.stringView("main"),
            .constantCount = 0,
            .constants = null,
            .nextInChain = null,
        },
    });
    defer pipeline.release();

    const n: u32 = 256;
    const buf_size: u64 = n * @sizeOf(f32);

    // Input data: 0.0, 1.0, 2.0, ...
    var input_data: [n]f32 = undefined;
    for (0..n) |i| input_data[i] = @floatFromInt(i);

    const input_buf = device.createBuffer(&.{
        .nextInChain = null,
        .label = gpu.stringView("input"),
        .usage = gpu.c.WGPUBufferUsage_Storage | gpu.c.WGPUBufferUsage_CopyDst,
        .size = buf_size,
        .mappedAtCreation = 0,
    }) orelse return error.NoBuffer;
    defer input_buf.release();

    const output_buf = device.createBuffer(&.{
        .nextInChain = null,
        .label = gpu.stringView("output"),
        .usage = gpu.c.WGPUBufferUsage_Storage | gpu.c.WGPUBufferUsage_CopySrc,
        .size = buf_size,
        .mappedAtCreation = 0,
    }) orelse return error.NoBuffer;
    defer output_buf.release();

    const readback_buf = device.createBuffer(&.{
        .nextInChain = null,
        .label = gpu.stringView("readback"),
        .usage = gpu.c.WGPUBufferUsage_MapRead | gpu.c.WGPUBufferUsage_CopyDst,
        .size = buf_size,
        .mappedAtCreation = 0,
    }) orelse return error.NoBuffer;
    defer readback_buf.release();

    queue.writeBuffer(input_buf, 0, std.mem.sliceAsBytes(&input_data));

    const bind_group_layout = pipeline.getBindGroupLayout(0);
    defer bind_group_layout.release();

    const entries = [_]gpu.BindGroupEntry{
        .{
            .nextInChain = null,
            .binding = 0,
            .buffer = input_buf.handle,
            .offset = 0,
            .size = buf_size,
            .sampler = null,
            .textureView = null,
        },
        .{
            .nextInChain = null,
            .binding = 1,
            .buffer = output_buf.handle,
            .offset = 0,
            .size = buf_size,
            .sampler = null,
            .textureView = null,
        },
    };
    const bind_group = device.createBindGroup(&.{
        .nextInChain = null,
        .label = gpu.stringView("compute bind group"),
        .layout = bind_group_layout.handle,
        .entryCount = entries.len,
        .entries = &entries,
    });
    defer bind_group.release();

    const encoder = device.createCommandEncoder(&.{
        .nextInChain = null,
        .label = gpu.stringView("compute encoder"),
    });

    const pass = encoder.beginComputePass(&std.mem.zeroes(gpu.ComputePassDescriptor));
    pass.setPipeline(pipeline);
    pass.setBindGroup(0, bind_group, &.{});
    pass.dispatchWorkgroups(n / 64, 1, 1);
    pass.end();
    pass.release();

    encoder.copyBufferToBuffer(output_buf, 0, readback_buf, 0, buf_size);

    const cmd = encoder.finish(null);
    encoder.release();

    queue.submit(&.{cmd});
    cmd.release();

    try readback_buf.mapAsync(instance, gpu.c.WGPUMapMode_Read, 0, buf_size);
    const mapped = readback_buf.getConstMappedRange(0, buf_size) orelse return error.MapFailed;
    const results: *const [n]f32 = @ptrCast(@alignCast(mapped));

    var correct: u32 = 0;
    for (0..n) |i| {
        const expected = input_data[i] * input_data[i];
        if (results[i] == expected) correct += 1;
    }

    readback_buf.unmap();

    std.debug.print("headless compute: {d}/{d} correct (squared {d} floats on GPU)\n", .{ correct, n, n });
    if (correct != n) return error.ComputeMismatch;
}
