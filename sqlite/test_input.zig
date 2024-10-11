const input = @import("input.zig");
const std = @import("std");
const builtin = @import("builtin");
const types = @import("types.zig");
const utils = @import("utils.zig");
const memory = @import("memory.zig");
const st = @import("statement.zig");
const expect = std.testing.expect;
const prepare_result = types.prepareResult;
const Statement = types.Statement;
const Row = types.Row;
const Table = memory.Table;

test "prompt" {
    // TYPE michel
    //const cmd = try input.prompt();
    // std.debug.print("{s}", .{cmd});
    //try expect(std.mem.eql(u8, cmd, "michel"));
}

test "parse input" {
    const in = "insert 1 michel michel@gmail.com";

    var stmt: Statement = undefined;
    try input.parse_input(in, &stmt);
    try expect(std.mem.eql(u8, stmt.row_to_insert.username, "michel"));
}

test "parseuseremail" {
    var params = types.Params.init();
    const in = "insert 1 michel michel@gmail.com";
    try input.parseUsernameEmail(in, &params);
    std.debug.print("username: {s}|\n", .{params.username.?});
    std.debug.print("email: {s}|\n", .{params.email.?});
    try expect(std.mem.eql(u8, params.username.?, "michel"));
    try expect(std.mem.eql(u8, params.email.?, "michel@gmail.com"));
}

test "prepare statement" {
    std.debug.print("usize :  {d} \n", .{@sizeOf(usize)});
    var stmt: Statement = undefined;
    var al = std.heap.page_allocator;

    var table = Table.init(al);
    defer al.free(table);
    const in = "insert 1 michel michel@gmail.com";
    const res = try st.prepareStatement(in, &stmt);
    if (res == prepare_result.success) {
        try st.executeStmt(&stmt, &table);
    }

    std.debug.print("{any}", .{table.pages[1]});
}

test "utils tobyte" {
    const int: u32 = 65;
    var buff: [4]u8 = undefined;
    _ = std.mem.writeInt(u32, &buff, int, builtin.cpu.arch.endian());
    const newint = try utils.bytesToIntLE(u32, &buff);
    std.debug.print("newint {d} {any} \n", .{ newint, buff });
    try expect(int == newint);
}
