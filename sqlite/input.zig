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
    const bit = input_buffer[7];
    const bytes: [4]u8 = [4]u8{ 0, 0, 0, bit };
    statement.row_to_insert.id = types.bytesToU32LE(bytes);
    std.debug.print("{d}", .{statement.row_to_insert.id});
    try parseUsernameEmail(input_buffer, &params);
    if (params.email == null or params.username == null) {
        std.debug.print("unexpected command", .{});
    }
    statement.row_to_insert.username = params.username.?;
    statement.row_to_insert.email = params.email.?;
}

pub fn parseUsernameEmail(input: []const u8, params: *Params) !void {
    var username_list = std.ArrayList(u8).init(std.heap.page_allocator);
    defer username_list.deinit();
    var email_list = std.ArrayList(u8).init(std.heap.page_allocator);
    defer email_list.deinit();
    var index: usize = 0;
    var first_space_index: usize = undefined;
    const end = input.len;
    for (input[9..]) |i| {
        index += 1;
        if (i == ' ' and first_space_index == undefined) {
            first_space_index = index;
        }

        std.debug.print("{d} :  {c} \n", .{ first_space_index, i });
    }
    params.username = input[9..first_space_index];
    params.email = input[first_space_index..end];
    index = 0;
}
