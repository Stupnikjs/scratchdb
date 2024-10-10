const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const Params = types.Params;

pub fn tobytes(T: type, src: T) []u8 {
    const len = @sizeOf(T);
    var buffer: [len]u8 = undefined;
    _ = std.mem.writeInt(T, &buffer, src, builtin.cpu.arch.endian());
    return &buffer;
}

pub fn bytesToIntLE(T: type, bytes: []u8) !T {
    const len = @sizeOf(T);
    var result: T = 0;
    // Little-endian: least significant byte first
    var index: u5 = 0;
    for (bytes[0..len]) |byte| {
        result |= @as(T, byte) << index * 8;
        index += 1;
    }
    return result;
}

pub const sqliteErr = error{
    customErr,
};
