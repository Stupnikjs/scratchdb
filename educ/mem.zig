const std = @import("std");

const Table = struct {
    num_rows: u32,
    pages: [10]?*[]u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Table {
        var page_init: [10]*[]u8 = undefined;
        for (0..10) |i| {
            var buf: []u8 = try allocator.alloc(u8, 1024);
            page_init[i] = &buf;

            if (i == 3) {
                var bu = try allocator.alloc(u8, 10);
                bu[0] = 'e';
                bu[1] = 66;
                bu[4] = 5;
                page_init[i] = &bu;
            }
        }
        return .{
            .num_rows = 0,
            .pages = page_init,
            .allocator = allocator,
        };
    }
    pub fn printPages(self: *Table) void {
        std.debug.print("fourth page {d} \n", .{self.pages[3].?.*});
    }
};

test "Table init" {
    const al = std.heap.page_allocator;
    var table = try Table.init(al);
    table.printPages();
}
