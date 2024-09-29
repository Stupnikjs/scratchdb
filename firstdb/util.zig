const std = @import("std");
const builtin = @import("builtin");

pub fn u64tobytes(src: u64) [8]u8 {
    var buffer: [8]u8 = undefined;
    _ = std.mem.writeInt(u64, &buffer, src, builtin.cpu.arch.endian());
    return buffer;
}
