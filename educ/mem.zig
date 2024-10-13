const std = @import("std");

pub const Table = struct {
    num_rows: u32,
    pages: []?*[]u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Table {
        var page_init: []?*[]u8 = try allocator.alloc(?*[]u8, 10);
        for (0..10) |i| {
            page_init[i] = null;
        }
        return .{
            .num_rows = 0,
            .pages = page_init,
            .allocator = allocator,
        };
    }
    pub fn set(self: *Table, data: []const u8, i: usize) !void {
        var buf = try self.allocator.alloc(u8, data.len);
        std.mem.copyForwards(u8, buf, data);
        self.pages[i] = &buf;
    }
};
test "Table init" {
    const al = std.heap.page_allocator;
    var table = try Table.init(al);

    const longstring = "thisisasuperlongstring";
    for (0..10) |i| {
        if (i == 3) try table.set("okokokdd", i) else try table.set(longstring, i);
    }
    std.debug.print("{s} \n", .{table.pages[3].?.*});
    // the same ref is passed
    // try std.testing.expect(std.mem.eql(u8, table.pages[1].?.*, "th"));
}
