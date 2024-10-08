const input = @import("input.zig");
const std = @import("std");
const types = @import("types.zig");
const expect = std.testing.expect;
const Statement = types.Statement;
const Row = types.Row;

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
    try expect(std.mem.eql(u8, params.username.?, "michel"));
    try expect(std.mem.eql(u8, params.email.?, "michel@gmail.com"));
}
