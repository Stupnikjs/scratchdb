const std = @import("std");

pub fn prompt() ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    std.debug.print(":>", .{});
    var buffer: [1024]u8 = undefined;
    const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
    return user_input[0 .. user_input.len - 1];
}
