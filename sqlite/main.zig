// https://cstack.github.io/db_tutorial/parts/part3.html

const std = @import("std");
const streql = std.mem.eql;
const prompt = @import("input.zig").prompt;
const st = @import("statement.zig");
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
        const res = try st.prepareStatement(cmd, &stmt);
        if (res == prepare_result.success) {
            try st.executeStmt(&stmt, table);
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
