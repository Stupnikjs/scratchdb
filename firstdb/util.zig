const std = @import("std");
const builtin = @import("builtin");
const commandError = @import("types.zig").commandError;

pub fn u64tobytes(src: u64) [8]u8 {
    var buffer: [8]u8 = undefined;
    _ = std.mem.writeInt(u64, &buffer, src, builtin.cpu.arch.endian());
    return buffer;
}

pub fn bytesTou64(src: [8]u8) u64 {
    var buffer: u64 = undefined;
    _ = std.mem.writeInt(u8, &buffer, src, builtin.cpu.arch.endian());
    return buffer;
}

pub fn bytesToU32LE(bytes: [4]u8) u32 {
    // Little-endian: least significant byte first
    return @as(u32, bytes[0]) |
        (@as(u32, bytes[1]) << 8) |
        (@as(u32, bytes[2]) << 16) |
        (@as(u32, bytes[3]) << 24);
}

pub fn addPaddingKey(key: []const u8) ![]u8 {
    if (key.len > 8) return commandError.keyTooLong;
    var list = try std.ArrayList(u8).initCapacity(std.heap.page_allocator, 8);
    defer list.deinit();
    for (0..8) |i| {
        if (i >= key.len) {
            try list.append('0');
            continue;
        }
        try list.append(key[i]);
    }
    return list.toOwnedSlice();
}

pub fn removePadding(paddedKey: []const u8) ![]const u8 {
    var list = std.ArrayList(u8).init(std.heap.page_allocator);
    defer list.deinit();
    for (paddedKey) |c| {
        if (c == '0') return list.toOwnedSlice();
        try list.append(c);
    }
    return list.toOwnedSlice();
}

pub fn stringInArr(str: []const u8, arr: [][]const u8) bool {
    for (arr) |s| {
        if (std.mem.eql(u8, s, str)) return true;
    }
    return false;
}
