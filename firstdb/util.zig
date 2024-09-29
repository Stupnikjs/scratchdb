const std = @import("std");
const builtin = @import("builtin");
const commandError = @import("types").commandError;

pub fn u64tobytes(src: u64) [8]u8 {
    var buffer: [8]u8 = undefined;
    _ = std.mem.writeInt(u64, &buffer, src, builtin.cpu.arch.endian());
    return buffer;
}

pub fn addPaddingKey(key: []const u8) ![]u8 {
    if (key.len > 8) return commandError.keyTooLong;
    var list = try std.ArrayList(u8).initCapacity(std.heap.page_allocator, 8);
    defer list.deinit();
    for (0..8) |i| {
        try list.append(key[i]);
    }
    return list.toOwnedSlice();
}
