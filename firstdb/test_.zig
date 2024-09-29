const std = @import("std");
const expect = std.testing.expect;
const StorageEngine = @import("storage.zig").StorageEngine;

test "create storage engine" {
    var engine = StorageEngine.init();
    try engine.setup();

    try engine.set("michel", "superstronk");
    try engine.set("jean", "superstronk");
    try engine.printHeader();
}
