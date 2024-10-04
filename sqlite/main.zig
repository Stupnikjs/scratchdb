// https://cstack.github.io/db_tutorial/parts/part3.html

const std = @import("std");
const prompt = @import("input.zig").prompt;
const streql = std.mem.eql;
const types = @import("types.zig");
const metaCMDresult = types.metaCMDresult;
const statementType = types.statementType;
const prepare_result = types.prepareResult;
const Row = types.Row;

const COLUMN_USERNAME_SIZE = 32;
const COLUMN_EMAIL_SIZE = 255;

pub fn size_of_attribute(T: type, fieldname: []const u8) u8 {
    return @sizeOf(@field(T, fieldname));
}

const ID_SIZE: u32 = size_of_attribute(Row, "id");
const USERNAME_SIZE: u32 = size_of_attribute(Row, "username");
const EMAIL_SIZE: u32 = size_of_attribute(Row, "email");
const ID_OFFSET: u32 = 0;
const USERNAME_OFFSET: u32 = ID_OFFSET + ID_SIZE;
const EMAIL_OFFSET: u32 = USERNAME_OFFSET + USERNAME_SIZE;
const ROW_SIZE: u32 = ID_SIZE + USERNAME_SIZE + EMAIL_SIZE;

const PAGE_SIZE: u32 = 4096;
const TABLE_MAX_PAGES: u32 = 100;
const ROWS_PER_PAGE: u32 = PAGE_SIZE / ROW_SIZE;
const TABLE_MAX_ROWS: u32 = ROWS_PER_PAGE * TABLE_MAX_PAGES;

pub fn main() !void {
    while (true) {
        const cmd = try prompt();
        if (cmd[0] == '.') {
            const meta_cmd = try doMetaCmd(cmd);
            if (meta_cmd == metaCMDresult.unreconized_command) {
                std.debug.print("unreconized command \n", .{});
            }
        }
        var stmt: statementType = undefined;
        const res = prepareStatement(cmd, &stmt);
        if (res == prepare_result.success) {
            executeStmt(stmt);
            continue;
        }
    }
}

fn doMetaCmd(cmd: []const u8) !metaCMDresult {
    if (streql(u8, cmd, ".exit")) std.process.exit(2);
    return metaCMDresult.unreconized_command;
}

fn prepareStatement(cmd: []const u8, stmt: *statementType) prepare_result {
    if (streql(u8, cmd[0..6], "insert")) {
        stmt.* = statementType.insert;
        return prepare_result.success;
    }
    if (streql(u8, cmd[0..6], "select")) {
        stmt.* = statementType.select;
        return prepare_result.success;
    }
    return prepare_result.unreconized_statement;
}

pub fn executeStmt(stmt: statementType) void {
    switch (stmt) {
        .insert => {
            std.debug.print("this is insert stmt \n", .{});
        },
        .select => {
            std.debug.print("this is select stmt \n", .{});
        },
    }
}

pub fn serialize_row(source: *Row, destination: []u8) void {
    if (destination.len < EMAIL_OFFSET + EMAIL_SIZE) {
        std.debug.print("buffer to small", .{});
    }
    std.mem.copyBackwards(u8, source.id, destination[ID_OFFSET..ID_SIZE]);
    std.mem.copyBackwards(u8, source.username, destination[USERNAME_OFFSET..USERNAME_SIZE]);
    std.mem.copyBackwards(u8, source.username, destination[EMAIL_OFFSET..EMAIL_SIZE]);
}

pub fn deserialize_row(source: []u8, destination: *Row) void {
    destination.id = types.bytesToU32LE(source[ID_OFFSET .. ID_OFFSET + ID_SIZE]);
    destination.username = source[USERNAME_OFFSET .. USERNAME_OFFSET + USERNAME_SIZE];
    destination.email = source[EMAIL_OFFSET .. EMAIL_OFFSET + EMAIL_SIZE];
}

pub fn row_slot(row_num: u32) *anyopaque {
    const page_num = row_num / ROWS_PER_PAGE;
}
