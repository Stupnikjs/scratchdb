const types = @import("types.zig");
const utils = @import("utils.zig");
const builtin = @import("builtin");
const Row = types.Row;
const std = @import("std");
const Table = types.Table;

const EMAIL_OFFSET = types.EMAIL_OFFSET;
const EMAIL_SIZE = types.EMAIL_SIZE;
const ID_OFFSET = types.ID_OFFSET;
const ID_SIZE = types.ID_SIZE;
const USERNAME_OFFSET = types.USERNAME_OFFSET;
const ROWS_PER_PAGE = types.ROWS_PER_PAGE;
const ROW_SIZE = types.ROW_SIZE;
const TABLE_MAX_PAGES = types.TABLE_MAX_PAGES;
const USERNAME_SIZE = types.USERNAME_SIZE;

pub fn serialize_row(source: *Row, destination: []u8) void {
    // Serialize the `id` (u32) in little-endian orders

    var bytes: [4]u8 = undefined;
    _ = std.mem.writeInt(u32, &bytes, source.id, builtin.cpu.arch.endian());

    var username_int_ptr: [8]u8 = undefined;
    _ = std.mem.writeInt(usize, &username_int_ptr, @intFromPtr(&source.username), builtin.cpu.arch.endian());

    var email_int_ptr: [8]u8 = undefined;
    _ = std.mem.writeInt(usize, &email_int_ptr, @intFromPtr(&source.email), builtin.cpu.arch.endian());

    @memcpy(destination[ID_OFFSET .. ID_SIZE + ID_OFFSET], &bytes);
    // Copy `username` and `email` into the destination buffer
    @memcpy(destination[USERNAME_OFFSET .. @sizeOf(usize) + USERNAME_OFFSET], &email_int_ptr);

    @memcpy(destination[EMAIL_OFFSET .. EMAIL_OFFSET + @sizeOf(usize)], &email_int_ptr);
}

pub fn deserialize_row(source: []u8, destination: *Row) void {
    destination.id = try utils.bytesToIntLE(u32, source[ID_OFFSET .. ID_OFFSET + ID_SIZE]);
    destination.username = source[USERNAME_OFFSET .. USERNAME_OFFSET + USERNAME_SIZE];
    destination.email = source[EMAIL_OFFSET .. EMAIL_OFFSET + EMAIL_SIZE];
}

pub fn row_slot(table: *Table, row_num: usize) ![]u8 {
    const page_num = row_num / ROWS_PER_PAGE;

    if (table.pages[page_num] == null) {
        var allocator = table.allocator;
        var buffer_alloc = try allocator.alloc(u8, types.PAGE_SIZE);
        table.pages[page_num] = &buffer_alloc;
    }

    const row_offset = row_num % ROWS_PER_PAGE;
    const byte_offset = row_offset * ROW_SIZE;

    // to access the next aviable memory space
    const buf = table.pages[page_num].?.*;
    return buf[byte_offset .. byte_offset + ROW_SIZE];
}

pub fn freeTable(table: *Table) !void {
    try table.allocator.free();
}
