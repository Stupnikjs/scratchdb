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
