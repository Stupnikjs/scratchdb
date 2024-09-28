const std = @import("std");
const expect = std.testing.expect;
const StorageEngine = @import("storage.zig").StorageEngine;

test "create storage engine" {
    var engine = StorageEngine.init();
    try engine.setup();

    var dir = try engine.openStoreDir();
    var file = try dir.openFile(engine.headerFileName, .{ write = true }); 
    _ = try file.write("moche");
    defer file.close();
    dir.close();
}
