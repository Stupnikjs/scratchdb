const std = @import("std");

pub const Row = struct {
    id: u32,
    username: []const u8,
    email: []const u8,
};

pub const metaCMDresult = enum {
    sucess,
    unreconized_command,
};

pub const prepareResult = enum {
    success,
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
