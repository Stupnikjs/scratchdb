const std = @import("std");
const types = @import("types.zig");
const Statement = types.Statement;
const Params = types.Params;
const utils = @import("utils.zig");

pub fn prompt() ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    std.debug.print(":>", .{});
    var buffer: [1024]u8 = undefined;
    const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
    return user_input[0 .. user_input.len - 1];
}

pub fn parse_input(input_buffer: []const u8, statement: *Statement) !void {
    if (input_buffer[6] != ' ') return;
    if (input_buffer[8] != ' ') return;

    var params: Params = Params.init();
    const byte = input_buffer[7];
    const bytes: [4]u8 = [4]u8{
        byte,
        0,
        0,
        0,
    };
    statement.row_to_insert.id = utils.bytesToIntLE(u32, &bytes);
    std.debug.print("{d}", .{statement.row_to_insert.id});
    try parseUsernameEmail(input_buffer, &params);
    if (params.email == null or params.username == null) {
        std.debug.print("unexpected command", .{});
    }
    statement.row_to_insert.username = params.username.?;
    statement.row_to_insert.email = params.email.?;
}

pub fn parseUsernameEmail(input: []const u8, params: *Params) !void {
    var index: usize = 9;
    var first_space_index: usize = 0;
    std.debug.print("input {s} \n", .{input});
    if (input.len < 9) return;
    const end = input.len;
    for (input[9..]) |i| {
        index += 1;
        if (i == ' ' and first_space_index == 0) {
            first_space_index = index - 1;
        }
    }
    params.username = input[9..first_space_index];
    params.email = input[first_space_index + 1 .. end];
    index = 0;
}
