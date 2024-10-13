const input = @import("input.zig");
const mem = @import("mem.zig");
const std = @import("std");

pub fn main() !void {
    var table = try mem.Table.init(std.heap.page_allocator);
    while (true) {
        const cmd = try input.prompt();
        try table.set(cmd, 2);
        for (table.pages) |p| {
            if (p != null) std.debug.print("{s} \n", .{p.?.*});
        }
    }
}
