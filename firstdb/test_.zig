const std = @import("std");
const expect = std.testing.expect;
const StorageEngine = @import("storage.zig").StorageEngine;
const Parser = @import("parser.zig").Parser;
const commandError = @import("types.zig").commandError;
const util = @import("util.zig");

test "simple set" {
    var engine = StorageEngine.init("headerset", "testdbset", "testsetstore");
    try engine.setup();
    try engine.set("superkey", "michel azjozorjzor oaokkpokzkrorp okoaokprokazo");
    try std.fs.cwd().deleteTree(engine.storeDirName);
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
    try std.fs.cwd().deleteTree(engine.storeDirName);
}
test "get simple key" {
    var engine = StorageEngine.init("headerget", "testget", "getstore");
    try engine.setup();
    try engine.set("jean", "ooo");
    try engine.set("n", "ooo");
    try engine.set("jn", "ooEEEEE111");
    try engine.set("je", "oooO");
    try engine.set("an", "ooo");
    const res = try engine.get("jn");
    const res1 = try engine.get("jean");
    try expect(std.mem.eql(u8, res, "ooEEEEE111"));
    try expect(std.mem.eql(u8, res1, "ooo"));
    try expect(!std.mem.eql(u8, res1, "ooEEEEE"));

    try std.fs.cwd().deleteTree(engine.storeDirName);
}

test "util u64 to u8" {
    const number: u64 = 54;
    const bytes = util.u64tobytes(number);
    try expect(util.bytesToU64LE(bytes) == number);
}
