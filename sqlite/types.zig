const std = @import("std");

const PAGE_SIZE: u32 = 4096;
const TABLE_MAX_PAGES: u32 = 100;
const ROWS_PER_PAGE: u32 = PAGE_SIZE / ROW_SIZE;
const TABLE_MAX_ROWS: u32 = ROWS_PER_PAGE * TABLE_MAX_PAGES;

pub const Row = struct {
    id: u32,
    username: []const u8,
    email: []const u8,

    pub fn printRow(self: Row) void {
        std.debug.print("{d}, {s}, {s}", .{ self.id, self.username, self.email });
    }
};

const Table = struct {
    num_rows: u32,
    pages: [TABLE_MAX_PAGES]*anyopaque,
};

pub const metaCMDresult = enum {
    sucess,
    unreconized_command,
};

pub const prepareResult = enum {
    success,
    syntax_error,
    unreconized_statement,
};

pub const statementType = enum {
    select,
    insert,
};

pub const Statement = struct {
    type: statementType,
    row_to_insert: Row,
};

pub fn bytesToU32LE(bytes: [4]u8) u32 {
    // Little-endian: least significant byte first
    return @as(u32, bytes[0]) |
        (@as(u32, bytes[1]) << 8) |
        (@as(u32, bytes[2]) << 16) |
        (@as(u32, bytes[3]) << 24);
}
