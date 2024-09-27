const std = @import("std");
const fdb = @import("firstdb/parser.zig");

pub fn main() !void {
    try fdb.firstdb();
}
