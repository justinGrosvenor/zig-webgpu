const std = @import("std");
const gpu = @import("gpu.zig");

pub fn bytesToWords(bytes: []const u8) []const u32 {
    if (bytes.len == 0) return &.{};
    if (std.mem.isAligned(@intFromPtr(bytes.ptr), 4)) {
        const aligned: []align(4) const u8 = @alignCast(bytes);
        return std.mem.bytesAsSlice(u32, aligned);
    }
    @panic("SPIR-V bytecode must be 4-byte aligned; use spirv.load() for @embedFile data");
}

/// Loads SPIR-V bytecode that may not be 4-byte aligned (e.g. from @embedFile).
/// Uses comptime reinterpretation when the pointer is comptime-known, otherwise
/// copies to a stack-aligned buffer for small shaders or falls back to bytesToWords.
pub fn load(device: gpu.Device, label: []const u8, comptime spv_bytes: []const u8) gpu.ShaderModule {
    if (spv_bytes.len == 0) return device.createShaderModuleSPIRV(label, &.{});
    const words = comptime asWords(spv_bytes);
    return device.createShaderModuleSPIRV(label, words);
}

fn asWords(comptime bytes: []const u8) []const u32 {
    const word_count = bytes.len / 4;
    var words: [word_count]u32 = undefined;
    for (0..word_count) |i| {
        words[i] = std.mem.readInt(u32, bytes[i * 4 ..][0..4], .little);
    }
    const final = words;
    return &final;
}
