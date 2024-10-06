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
pub const ROW_SIZE: u32 = ID_SIZE + USERNAME_SIZE + EMAIL_SIZE;

const PAGE_SIZE: u32 = 4096;
const TABLE_MAX_PAGES: u32 = 100;
const ROWS_PER_PAGE: u32 = PAGE_SIZE / ROW_SIZE;
const TABLE_MAX_ROWS: u32 = ROWS_PER_PAGE * TABLE_MAX_PAGES;

pub fn main() !void {
    while (true) {
        const table = try newTable();
        const cmd = try prompt();
        if (cmd[0] == '.') {
            const meta_cmd = try doMetaCmd(cmd, table);
            if (meta_cmd == metaCMDresult.unreconized_command) {
                std.debug.print("unreconized command \n", .{});
            }
        }
        var stmt: Statement = undefined;
        const res = prepareStatement(cmd, &stmt);
        if (res == prepare_result.success) {
            executeStmt(stmt);
            continue;
        }
    }
}

fn doMetaCmd(cmd: []const u8, table: *Table) !metaCMDresult {
    if (streql(u8, cmd, ".exit")) {
        std.process.exit(2);
        try freeTable(table);
    }
    return metaCMDresult.unreconized_command;
}

pub fn parse_input(input_buffer: []const u8, statement: *Statement) !void {
    if (input_buffer[6] != ' ') return prepare_result.syntax_error; 
    if (input_buffer[8] != ' ') return prepare_result.syntax_error; 

    statement.row_to_insert.id = try std.fmt.parseInt(u32, input_buffer[7], u8);
    var end: u8 = 9; 
    var start = 9; 
    for (input_buffer[9..]) |c| {
        if (c == ' ') 
    }
    statement.row_to_insert.username = try std.mem.copy(u8, statement.row_to_insert.username, username);
    statement.row_to_insert.email = try std.mem.copy(u8, statement.row_to_insert.email, email);
}

fn prepareStatement(cmd: []const u8, stmt: *Statement) !prepare_result {
    if (streql(u8, cmd[0..6], "insert")) {
        stmt.type = statementType.insert;
        try parse_input(cmd, stmt);
        return prepare_result.success;
    }
    if (streql(u8, cmd[0..6], "select")) {
        stmt.* = statementType.select;
        return prepare_result.success;
    }
    return prepare_result.unreconized_statement;
}

pub fn executeStmt(stmt: *Statement, table: *Table) void {
    switch (stmt.type) {
        .insert => {
            std.debug.print("this is insert stmt \n", .{});
            execute_insert(stmt, table);
        },
        .select => {
            std.debug.print("this is select stmt \n", .{});
            execute_select(stmt, table);
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

pub fn row_slot(table: *Table, row_num: u32) !*anyopaque {
    const page_num = row_num / ROWS_PER_PAGE;
    var page = table.pages[page_num];
    if (page == null) {
        var allocator = std.heap.page_allocator;
        page = try allocator.alloc(u8, PAGE_SIZE);
        // pointer to allocator
        table.pages[page_num] = page;
        table.allocator = allocator;
    }
    const row_offset = row_num % ROWS_PER_PAGE;
    const byte_offset = row_offset * ROW_SIZE;

    // to access the next aviable memory space
    return page + byte_offset;
}

pub fn newTable() !*Table {
    var table: *Table = try std.heap.page_allocator.create(Table);
    table.num_rows = 0;
    for (0..TABLE_MAX_PAGES) |i| {
        table.pages[i] = undefined;
    }
    return table;
}

pub fn freeTable(table: *Table) !void {
    try table.allocator.free();
}

pub fn execute_insert(stmt: *Statement, table: *Table) !executeResult {
    if (table.num_rows >= TABLE_MAX_ROWS) {
        return executeResult.table_full;
    }
    serialize_row(stmt.row_to_insert, row_slot(table, table.num_rows));
    table.num_rows += 1;
    return executeResult.success;
}

pub fn execute_select(stmt: *Statement, table: *Table) !executeResult {
    _ = stmt;
    for (0..table.num_rows) |i| {
        var row: Row = undefined;
        deserialize_row(row_slot(table, i), &row);
        std.debug.print("{any}", .{row});
    }
    return executeResult.success;
}
