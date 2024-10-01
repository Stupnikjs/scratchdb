const std = @import("std");
const expect = std.testing.expect;
const StorageEngine = @import("storage.zig").StorageEngine;
const commandError = @import("types.zig").commandError;
const util = @import("util.zig");

test "simple set" {
    var engine = StorageEngine.init("headerset", "testdbset", "testsetstore");
    try engine.setup();
    try engine.set("superkey", "michel");
}

test "print keys" {
    var engine = StorageEngine.init("headerprintkeys", "testprintkeys", "printkeysstore");
    try engine.setup();
    try engine.set("super", "mi");
    try engine.set("sj", "ez");
    for (engine.map.keys()) |key| {
        const coord = engine.map.get(key).?;
        std.debug.print(" key {s} : [{d}, {d}] \n", .{ key, coord[0], coord[1] });
    }
}
test "get simple key" {
    var engine = StorageEngine.init("headerget", "testget", "getstore");
    try engine.setup();
    try engine.set("jean", "jean le beau gosse");
    try engine.get("jean");
}

test "util u64 to u8" {
    const number: u64 = 54;
    const bytes = util.u64tobytes(number);
    try expect(util.bytesToU64LE(bytes) == number);
}
