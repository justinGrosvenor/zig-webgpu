# zig-webgpu

Thin Zig binding for [wgpu-native](https://github.com/gfx-rs/wgpu-native), with
optional native windowing for macOS, Windows, and X11/Linux. Pins to
[wgpu-native v29.0.0.0](https://github.com/gfx-rs/wgpu-native/releases/tag/v29.0.0.0).

## Status

Early package. The Zig wrapper layer is small and intentionally close to the C
API — descriptor types are direct re-exports of `WGPU*` C structs so you can
read the WebGPU spec and the wgpu-native headers without translating. The
public surface may tighten before 1.0; treat naming changes as breaking.

Targets Zig `0.16`.

## Platforms

Prebuilt wgpu-native binaries are lazily fetched for the target you build for:

| OS      | Architectures   |
| ------- | --------------- |
| macOS   | arm64, x86_64   |
| Linux   | x86_64, aarch64 |
| Windows | x86_64 (MSVC)   |

Other targets compile with `-Dheadless=true` if you supply wgpu-native yourself.

## Install

`build.zig.zon`:

```zig
.dependencies = .{
    .zig_webgpu = .{
        .url = "https://example.com/zig-webgpu/archive/<tag>.tar.gz",
        .hash = "...",
    },
},
```

`build.zig`:

```zig
const gpu_dep = b.dependency("zig_webgpu", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("gpu", gpu_dep.module("gpu"));
```

The `gpu` module carries its library path and `linkSystemLibrary("wgpu_native")`
internally — anything that imports it inherits the link transitively. No
separate `addLibraryPath` call is needed.

For server-side or test environments without a window system:

```zig
const gpu_dep = b.dependency("zig_webgpu", .{
    .target = target,
    .optimize = optimize,
    .headless = true,
});
```

## Example

```zig
const std = @import("std");
const gpu = @import("gpu");

pub fn main() !void {
    const instance = gpu.Instance.create(null) orelse return error.NoInstance;
    defer instance.release();

    const adapter = instance.requestAdapter(null) orelse return error.NoAdapter;
    defer adapter.release();

    const device = adapter.requestDevice(instance, null) orelse return error.NoDevice;
    defer device.release();

    const queue = device.getQueue();
    defer queue.release();

    const buffer = device.createBuffer(&.{
        .label = gpu.stringView("scratch"),
        .usage = gpu.c.WGPUBufferUsage_Vertex | gpu.c.WGPUBufferUsage_CopyDst,
        .size = 4096,
        .mappedAtCreation = 0,
    }) orelse return error.BufferAlloc;
    defer buffer.release();
}
```

Two runnable examples are in `examples/`:

- `zig build example` — windowed triangle (macOS / Windows / Linux)
- `zig build compute` — headless compute pass

## Conventions

- `Instance.create`, `requestAdapter`, `requestDevice`, `createSurface` return
  `?T`; the wrappers spin `wgpuInstanceProcessEvents` until the underlying
  async callback fires, so the call blocks the current thread.
- Resource creation that the C API marks non-nullable returns a plain `T`.
  `createBuffer` is the one exception that returns `?T` (the only `WGPU_NULLABLE`
  return in the `Device.create*` family).
- `destroy` vs `release` — `destroy` frees the GPU-side allocation immediately;
  `release` drops the wrapper's refcount on the handle. For resources that
  expose both, call `destroy` first if you want to be sure GPU memory is
  reclaimed at that point in the program.
- `SurfaceTexture` owns the texture handle from `Surface.getCurrentTexture`.
  Call `.release()` after the frame is submitted.
- Descriptor structs (`WGPUBufferDescriptor`, `WGPURenderPipelineDescriptor`,
  etc.) are re-exported as-is from the C headers. Field names match the spec.

## Layout safety

`gpu.zig` has compile-time `@sizeOf` checks on the wrappers we `@ptrCast`
through (`CommandBuffer`, `RenderBundle`). If wgpu-native ever changes those
layouts, the build fails rather than silently corrupting calls into
`wgpuQueueSubmit` / `wgpuRenderPassEncoderExecuteBundles`.

## License

zlib. See `LICENSE`.
