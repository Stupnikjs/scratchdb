const std = @import("std");
const size_of_attribute = @import("main.zig");

pub const ID_SIZE: u32 = 4;
pub const USERNAME_SIZE: u32 = @sizeOf(usize);
pub const EMAIL_SIZE: u32 = @sizeOf(usize);
pub const ID_OFFSET: u32 = 0;
pub const USERNAME_OFFSET: u32 = ID_OFFSET + ID_SIZE;
pub const EMAIL_OFFSET: u32 = USERNAME_OFFSET + USERNAME_SIZE;
pub const ROW_SIZE: u32 = ID_SIZE + USERNAME_SIZE + EMAIL_SIZE;

pub const PAGE_SIZE: u32 = 4096;
pub const TABLE_MAX_PAGES: u32 = 100;
pub const ROWS_PER_PAGE: u32 = PAGE_SIZE / ROW_SIZE;
pub const TABLE_MAX_ROWS: u32 = ROWS_PER_PAGE * TABLE_MAX_PAGES;

pub const Row = struct {
    id: u32,
    username: []const u8,
    email: []const u8,
    pub fn printRow(self: Row) void {
        std.debug.print("{d}, {s}, {s}", .{ self.id, self.username, self.email });
    }
};

pub const Params = struct {
    username: ?[]const u8,
    email: ?[]const u8,
    pub fn init() Params {
        return .{
            .username = null,
            .email = null,
        };
    }
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
