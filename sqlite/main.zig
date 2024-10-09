// https://cstack.github.io/db_tutorial/parts/part3.html

const std = @import("std");
const streql = std.mem.eql;
const prompt = @import("input.zig").prompt;
const parse_input = @import("input.zig").parse_input;
const types = @import("types.zig");
const metaCMDresult = types.metaCMDresult;
const executeResult = types.executeResult;
const statementType = types.statementType;
const Statement = types.Statement;
const prepare_result = types.prepareResult;
const Row = types.Row;
const Table = types.Table;
const Params = @import("utils.zig").Params;
const parseParams = @import("utils.zig").parseUsernameEmail;
const memory = @import("memory.zig");
const EMAIL_OFFSET = types.EMAIL_OFFSET;
const EMAIL_SIZE = types.EMAIL_SIZE;
const ID_OFFSET = types.ID_OFFSET;
const ID_SIZE = types.ID_SIZE;
const USERNAME_OFFSET = types.USERNAME_OFFSET;
const ROWS_PER_PAGE = types.ROWS_PER_PAGE;
const ROW_SIZE = types.ROW_SIZE;
const TABLE_MAX_PAGES = types.TABLE_MAX_PAGES;
const TABLE_MAX_ROWS = types.TABLE_MAX_ROWS;
const USERNAME_SIZE = types.USERNAME_SIZE;

const COLUMN_USERNAME_SIZE = 32;
const COLUMN_EMAIL_SIZE = 255;

pub fn size_of_attribute(T: type, fieldname: []const u8) u8 {
    return @sizeOf(@field(T, fieldname));
}

pub fn main() !void {
    while (true) {
        const table = try memory.newTable();
        const cmd = try prompt();
        if (cmd[0] == '.') {
            const meta_cmd = try doMetaCmd(cmd, table);
            if (meta_cmd == metaCMDresult.unreconized_command) {
                std.debug.print("unreconized command \n", .{});
            }
        }
        var stmt: Statement = undefined;
        const res = try prepareStatement(cmd, &stmt);
        if (res == prepare_result.success) {
            try executeStmt(&stmt, table);
            continue;
        }
    }
}

fn doMetaCmd(cmd: []const u8, table: *Table) !metaCMDresult {
    if (streql(u8, cmd, ".exit")) {
        std.process.exit(2);
        try memory.freeTable(table);
    }
    return metaCMDresult.unreconized_command;
}

fn prepareStatement(cmd: []const u8, stmt: *Statement) !prepare_result {
    if (streql(u8, cmd[0..6], "insert")) {
        stmt.type = statementType.insert;
        try parse_input(cmd, stmt);
        return prepare_result.success;
    }
    if (streql(u8, cmd[0..6], "select")) {
        stmt.type = statementType.select;
        return prepare_result.success;
    }
    return prepare_result.unreconized_statement;
}

pub fn executeStmt(stmt: *Statement, table: *Table) !void {
    switch (stmt.type) {
        .insert => {
            std.debug.print("this is insert stmt \n", .{});
            _ = try execute_insert(stmt, table);
        },
        .select => {
            std.debug.print("this is select stmt \n", .{});
            _ = try execute_select(stmt, table);
        },
    }
}

pub fn execute_insert(stmt: *Statement, table: *Table) !executeResult {
    if (table.num_rows >= TABLE_MAX_ROWS) {
        return executeResult.table_full;
    }
    const slot = try memory.row_slot(table, table.num_rows);
    memory.serialize_row(&stmt.row_to_insert, slot);
    table.num_rows += 1;
    return executeResult.success;
}

pub fn execute_select(stmt: *Statement, table: *Table) !executeResult {
    _ = stmt;
    for (0..table.num_rows) |i| {
        var row: Row = undefined;
        memory.deserialize_row(try memory.row_slot(table, i), &row);
    }
    return executeResult.success;
}
