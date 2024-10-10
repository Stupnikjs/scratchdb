const std = @import("std");
const memory = @import("memory.zig");
const streql = std.mem.eql;
const parse_input = @import("input.zig").parse_input;
const types = @import("types.zig");
const metaCMDresult = types.metaCMDresult;
const executeResult = types.executeResult;
const statementType = types.statementType;
const Statement = types.Statement;
const prepare_result = types.prepareResult;
const Table = types.Table;
const Row = types.Row;
const TABLE_MAX_ROWS = types.TABLE_MAX_ROWS;

pub fn prepareStatement(cmd: []const u8, stmt: *Statement) !prepare_result {
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
        row.printRow();
    }
    return executeResult.success;
}
