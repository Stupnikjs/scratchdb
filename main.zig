const std = @import("std");
const fdb = @import("firstdb/lexer.zig");

pub fn main() !void {
    try fdb.firstdb();
}
