const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const Params = types.Params;

// to bytes
// buf:[4]u8 = undefined;
// _ = std.mem.writeInt(u32, &buff, int, builtin.cpu.arch.endian());

pub fn bytesToIntLE(T: type, bytes: []u8) !T {
    const len = @sizeOf(T);
    std.debug.print("{d}", .{len});
    var result: T = 0;
    // Little-endian: least significant byte first
    var index: u5 = 0;
    while (true) {
        if (bytes.len <= index) {
            result |= @as(T, 0) << index * 8;
        } else {
            result |= @as(T, bytes[index]) << index * 8;
        }
        if (index == len - 1) break;
        index += 1;
    }
    return result;
}

pub const sqliteErr = error{
    customErr,
};
