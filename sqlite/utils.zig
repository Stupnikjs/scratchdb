const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const Params = types.Params;

pub fn u32tobytes(src: u32) [4]u8 {
    var buffer: [4]u8 = undefined;
    _ = std.mem.writeInt(u32, &buffer, src, builtin.cpu.arch.endian());
    return buffer;
}

pub fn usizetobytes(src: usize) []u8 {
    const usizelen = @sizeOf(usize);
    var buffer: [usizelen]u8 = undefined;
    _ = std.mem.writeInt(usize, &buffer, src, builtin.cpu.arch.endian());
    return &buffer;
}
