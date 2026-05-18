const std = @import("std");

pub const ShaderStage = enum {
    vertex,
    fragment,
    compute,

    pub fn flag(self: ShaderStage) []const u8 {
        return switch (self) {
            .vertex => "-fshader-stage=vertex",
            .fragment => "-fshader-stage=fragment",
            .compute => "-fshader-stage=compute",
        };
    }
};

pub const ShaderSource = struct {
    path: std.Build.LazyPath,
    stage: ShaderStage,
    entry: []const u8 = "main",
};

/// Compiles a GLSL source file to SPIR-V bytecode using glslc (from the
/// Vulkan SDK). Returns a LazyPath to the generated .spv file.
pub fn compile(b: *std.Build, source: ShaderSource) std.Build.LazyPath {
    const run = b.addSystemCommand(&.{"glslc"});
    run.addArg(source.stage.flag());
    run.addArg(b.fmt("-fentry-point={s}", .{source.entry}));
    run.addArg("-o");
    const spv_name = spvName(b, source.path);
    const output = run.addOutputFileArg(spv_name);
    run.addFileArg(source.path);
    return output;
}

/// Compiles a GLSL source to SPIR-V and makes it available as a Zig module.
/// Use `@import("name").bytes` to access the raw SPIR-V bytecode.
pub fn add(module: *std.Build.Module, name: []const u8, source: ShaderSource) void {
    const b = module.owner;
    const spv = compile(b, source);
    const spv_filename = spvName(b, source.path);

    const wf = b.addWriteFiles();
    _ = wf.addCopyFile(spv, spv_filename);
    const zig_src = wf.add(
        b.fmt("{s}.zig", .{name}),
        b.fmt(
            \\pub const bytes = @embedFile("{s}");
            \\
        , .{spv_filename}),
    );

    module.addImport(name, b.createModule(.{ .root_source_file = zig_src }));
}

fn spvName(b: *std.Build, path: std.Build.LazyPath) []const u8 {
    const src_path = switch (path) {
        .src_path => |sp| sp.sub_path,
        .cwd_relative => |rel| rel,
        else => return "shader.spv",
    };
    const basename = std.fs.path.stem(src_path);
    return b.fmt("{s}.spv", .{basename});
}
