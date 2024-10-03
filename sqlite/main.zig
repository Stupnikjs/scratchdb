const std = @import("std");
const prompt = @import("input.zig").prompt;

// https://cstack.github.io/db_tutorial/parts/part3.html

pub fn main() !void {
    while (true) {
        const cmd = try prompt();
        std.debug.print("{s}\n", .{cmd});
    }
}
