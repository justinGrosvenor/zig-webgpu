const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const headless = b.option(bool, "headless", "Build without native windowing (server/scripting mode)") orelse false;

    const wgpu_dep = resolveWgpuNative(b, target);

    const gpu_module = b.addModule("gpu", .{
        .root_source_file = b.path("src/gpu.zig"),
        .target = target,
        .optimize = optimize,
    });
    addWgpuToModule(gpu_module, wgpu_dep);
    addOptions(gpu_module, headless);
    if (!headless) linkPlatform(gpu_module, target);

    // --- tests ---
    const test_module = b.createModule(.{
        .root_source_file = b.path("src/gpu.zig"),
        .target = target,
        .optimize = optimize,
    });
    addWgpuToModule(test_module, wgpu_dep);
    addOptions(test_module, headless);
    if (!headless) linkPlatform(test_module, target);

    const tests = b.addTest(.{ .root_module = test_module });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);

    // --- triangle example ---
    const example_module = b.createModule(.{
        .root_source_file = b.path("examples/triangle.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_module.addImport("gpu", gpu_module);
    addWgpuToModule(example_module, wgpu_dep);
    addOptions(example_module, headless);
    if (!headless) linkPlatform(example_module, target);
    const example = b.addExecutable(.{
        .name = "example",
        .root_module = example_module,
    });

    const run_example = b.addRunArtifact(example);
    const example_step = b.step("example", "Run triangle example");
    example_step.dependOn(&run_example.step);

    // --- headless compute example ---
    const compute_module = b.createModule(.{
        .root_source_file = b.path("examples/headless_compute.zig"),
        .target = target,
        .optimize = optimize,
    });
    compute_module.addImport("gpu", gpu_module);
    addWgpuToModule(compute_module, wgpu_dep);
    const compute_example = b.addExecutable(.{
        .name = "headless_compute",
        .root_module = compute_module,
    });

    const run_compute = b.addRunArtifact(compute_example);
    const compute_step = b.step("compute", "Run headless compute example");
    compute_step.dependOn(&run_compute.step);
}

fn addOptions(module: *std.Build.Module, headless: bool) void {
    const options = module.owner.addOptions();
    options.addOption(bool, "headless", headless);
    module.addImport("build_options", options.createModule());
}

fn linkPlatform(module: *std.Build.Module, target: std.Build.ResolvedTarget) void {
    const os = target.result.os.tag;
    switch (os) {
        .macos => {
            module.linkFramework("Metal", .{});
            module.linkFramework("QuartzCore", .{});
            module.linkFramework("CoreFoundation", .{});
            module.linkFramework("AppKit", .{});
        },
        .windows => {
            module.linkSystemLibrary("user32", .{});
            module.linkSystemLibrary("gdi32", .{});
            module.linkSystemLibrary("kernel32", .{});
        },
        .linux => {
            module.linkSystemLibrary("X11", .{});
        },
        else => {},
    }
}

/// Resolves the prebuilt wgpu-native package for the given target. Returns null
/// for unsupported targets or when the lazy dependency has not yet been fetched
/// (the build system will re-invoke build() after fetching).
fn resolveWgpuNative(b: *std.Build, target: std.Build.ResolvedTarget) ?*std.Build.Dependency {
    const t = target.result;
    const name: ?[]const u8 = switch (t.os.tag) {
        .macos => switch (t.cpu.arch) {
            .aarch64 => "wgpu_native_macos_aarch64",
            .x86_64 => "wgpu_native_macos_x86_64",
            else => null,
        },
        .linux => switch (t.cpu.arch) {
            .x86_64 => "wgpu_native_linux_x86_64",
            .aarch64 => "wgpu_native_linux_aarch64",
            else => null,
        },
        .windows => switch (t.cpu.arch) {
            .x86_64 => "wgpu_native_windows_x86_64",
            else => null,
        },
        else => null,
    };

    if (name) |n| return b.lazyDependency(n, .{});

    std.debug.print(
        "zig-webgpu: no prebuilt wgpu-native for {s}-{s}; supply your own via -fsys or extend build.zig.zon.\n",
        .{ @tagName(t.os.tag), @tagName(t.cpu.arch) },
    );
    return null;
}

fn addWgpuToModule(module: *std.Build.Module, wgpu_dep: ?*std.Build.Dependency) void {
    const dep = wgpu_dep orelse return;
    // wgpu-native release zips lay out headers under include/webgpu/*.h;
    // adding include/webgpu lets gpu.zig do @cInclude("webgpu.h") unchanged.
    module.addIncludePath(dep.path("include/webgpu"));
    module.addLibraryPath(dep.path("lib"));
    module.linkSystemLibrary("wgpu_native", .{});
}
