const types = @import("types.zig");
const utils = @import("utils.zig");
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

    // Serialize the `id` (u32) in little-endian order
    const bytes: [4]u8 = utils.u32tobytes(source.id);
    @memcpy(destination[ID_OFFSET .. ID_SIZE + ID_OFFSET], &bytes);

    // Copy `username` and `email` into the destination buffer
    @memcpy(destination[USERNAME_OFFSET..][0..USERNAME_SIZE], source.username);
    @memcpy(destination[EMAIL_OFFSET..][0..EMAIL_SIZE], source.email);
}

pub fn deserialize_row(source: []u8, destination: *Row) void {
    destination.id = types.bytesToU32LE(source[ID_OFFSET .. ID_OFFSET + ID_SIZE].*);
    destination.username = source[USERNAME_OFFSET .. USERNAME_OFFSET + USERNAME_SIZE];
    destination.email = source[EMAIL_OFFSET .. EMAIL_OFFSET + EMAIL_SIZE];
}

pub fn row_slot(table: *Table, row_num: usize) ![]u8 {
    const page_num = row_num / ROWS_PER_PAGE;
    const page = table.pages[page_num];
    var buf: []u8 = undefined;
    if (page == null) {
        var allocator = table.allocator;
        page.?.* = try allocator.alloc(u8, types.PAGE_SIZE);
        table.pages[page_num] = page;
    }

    const row_offset = row_num % ROWS_PER_PAGE;
    const byte_offset = row_offset * ROW_SIZE;

    // to access the next aviable memory space
    buf = table.pages[page_num].?.*;
    return buf[byte_offset .. byte_offset + ROW_SIZE];
}

pub fn newTable() !*Table {
    var table: *Table = try std.heap.page_allocator.create(Table);
    table.num_rows = 0;
    for (0..TABLE_MAX_PAGES) |i| {
        table.pages[i] = null;
    }
    return table;
}

pub fn freeTable(table: *Table) !void {
    try table.allocator.free();
}
