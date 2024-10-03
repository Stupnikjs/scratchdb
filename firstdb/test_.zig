const std = @import("std");
const expect = std.testing.expect;
const StorageEngine = @import("storage.zig").StorageEngine;
const commandError = @import("types.zig").commandError;
const util = @import("util.zig");

test "simple set" {
    var engine = StorageEngine.init("headerset", "testdbset", "testsetstore");
    try engine.setup();
    try engine.set("superkey", "michel azjozorjzor oaokkpokzkrorp okoaokprokazo");
    try std.fs.cwd().deleteTree(engine.storeDirName);
}

test "get simple key" {
    var engine = StorageEngine.init("headerget", "testget", "getstore");
    try engine.setup();
    const bigstring =
        \\ iojfosjpofjpoJPFJOPJpojpofjpojpoJ
        \\SSPDKPGOJPOJPOJOPJSPOJOPJPOJOPJOJDJDJ    OEPOZPJEOPE JOPJ
        \\OJZEPOEZJEZOPJZEPOEJ EPJEP huhliuhlihuhiuhihuh              lalalala
    ;

    try engine.set("jean", bigstring);
    try engine.set("n", "ooo");
    try engine.set("jn", "ooEEEEE111");
    try engine.set("je", "oooO");
    try engine.set("an", "ooo");
    const res = try engine.get("jn");
    const res1 = try engine.get("jean");
    try expect(std.mem.eql(u8, res, "ooEEEEE111"));
    try expect(std.mem.eql(u8, res1, bigstring));
    try expect(!std.mem.eql(u8, res1, "ooEEEEE"));
    try std.fs.cwd().deleteTree(engine.storeDirName);
}

test "set and multiple get" {
    var engine = StorageEngine.init("headerget", "testget", "getstore");

    try engine.setup();
    const key = "wil";
    const value = "this is the value  long key   eoIEZFJOZEJFEOZJFOZEOJEF op poepofep   zoezofjez ofzejp ojpezjoepjfopejfpoe jfopzej pofje opfjepofje pofje zop";

    try engine.set("sec", "other val");
    try engine.set(key, value);
    try engine.set("third", "other other value ");
    const res = try engine.get(key);
    try expect(std.mem.eql(u8, res, value));
    try std.fs.cwd().deleteTree(engine.storeDirName);
}

test "del simple" {
    var engine = StorageEngine.init("headerget", "testget", "getstore");
    try engine.setup();
    try engine.set("sec", "other val");
    try engine.del("sec");
    const res = engine.get("sec");
    try expect(res == commandError.keyNotFound);
    try std.fs.cwd().deleteTree(engine.storeDirName);
}

test "util u64 to u8" {
    const number: u64 = 54;
    const bytes = util.u64tobytes(number);
    try expect(util.bytesToU64LE(bytes) == number);
}
