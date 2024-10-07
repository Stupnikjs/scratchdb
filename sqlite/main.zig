// https://cstack.github.io/db_tutorial/parts/part3.html

const std = @import("std");
const prompt = @import("input.zig").prompt;
const streql = std.mem.eql;
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

const COLUMN_USERNAME_SIZE = 32;
const COLUMN_EMAIL_SIZE = 255;

pub fn size_of_attribute(T: type, fieldname: []const u8) u8 {
    return @sizeOf(@field(T, fieldname));
}

const ID_SIZE: u32 = 4;
const USERNAME_SIZE: u32 = 4;
const EMAIL_SIZE: u32 = 4;
const ID_OFFSET: u32 = 0;
const USERNAME_OFFSET: u32 = ID_OFFSET + ID_SIZE;
const EMAIL_OFFSET: u32 = USERNAME_OFFSET + USERNAME_SIZE;
pub const ROW_SIZE: u32 = ID_SIZE + USERNAME_SIZE + EMAIL_SIZE;

const PAGE_SIZE: u32 = 4096;
const TABLE_MAX_PAGES: u32 = 100;
const ROWS_PER_PAGE: u32 = PAGE_SIZE / ROW_SIZE;
const TABLE_MAX_ROWS: u32 = ROWS_PER_PAGE * TABLE_MAX_PAGES;

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

pub fn parse_input(input_buffer: []const u8, statement: *Statement) !void {
    if (input_buffer[6] != ' ') return;
    if (input_buffer[8] != ' ') return;

    var params = Params.init();
    statement.row_to_insert.id = try std.fmt.parseInt(u32, input_buffer[7..8], '2');

    try parseParams(input_buffer, &params);
    statement.row_to_insert.username = params.username.?;
    statement.row_to_insert.email = params.email.?;
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
    memory.serialize_row(&stmt.row_to_insert, try memory.row_slot(table, table.num_rows));
    table.num_rows += 1;
    return executeResult.success;
}

pub fn execute_select(stmt: *Statement, table: *Table) !executeResult {
    _ = stmt;
    for (0..table.num_rows) |i| {
        var row: Row = undefined;
        memory.deserialize_row(memory.row_slot(table, i), &row);
        std.debug.print("{any}", .{row});
    }
    return executeResult.success;
}
