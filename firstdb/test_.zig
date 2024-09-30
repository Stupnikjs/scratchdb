const std = @import("std");
const expect = std.testing.expect;
const StorageEngine = @import("storage.zig").StorageEngine;
const commandError = @import("types.zig").commandError;

test "create storage engine" {
    var engine = StorageEngine.init();
    try engine.setup();
    try engine.parseHeaderFile();
}

test "create storage engine / too long key" {
    var engine = StorageEngine.init();
    try engine.setup();
    const err = engine.set("michelmaneuvre", "superstronk");
    try expect(err == commandError.keyTooLong);
}

test "get all keys" {
    var engine = StorageEngine.init();
    try engine.setup();
    try engine.set("superkey", "michel");
    const keys = engine.map.keys();
    for (keys) |key| {
        std.debug.print("key: {any}", .{engine.map.get(key)});
    }
    try engine.printHeader();
}
