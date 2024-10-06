const std = @import("std");
const size_of_attribute = @import("main.zig");

const ID_SIZE: u32 = size_of_attribute(Row, "id");
const USERNAME_SIZE: u32 = size_of_attribute(Row, "username");
const EMAIL_SIZE: u32 = size_of_attribute(Row, "email");
const ID_OFFSET: u32 = 0;
const USERNAME_OFFSET: u32 = ID_OFFSET + ID_SIZE;
const EMAIL_OFFSET: u32 = USERNAME_OFFSET + USERNAME_SIZE;
pub const ROW_SIZE: u32 = ID_SIZE + USERNAME_SIZE + EMAIL_SIZE;

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

pub const Table = struct {
    num_rows: u32,
    pages: [TABLE_MAX_PAGES]*anyopaque,
    allocator: std.mem.Allocator,
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

pub const executeResult = enum {
    success,
    table_full,
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
