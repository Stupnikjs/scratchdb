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
const Table = memory.Table;
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
    const allocator = std.heap.page_allocator;
    var table = try Table.init(allocator);
    var index: usize = 0;
    while (true) {
        std.debug.print("index {d} \n", .{index});

        const cmd = try prompt();
        const id = try std.fmt.parseInt(u8, cmd[0..1], 10);
        if (index % 2 == 0) {
            try table.set(cmd, id);
        }
        std.debug.print("{s} \n", .{table.get(id).?});
        index += 1;
    }
}
