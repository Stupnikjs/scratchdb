const std = @import("std");
const expect = std.testing.expect;
const StorageEngine = @import("storage.zig").StorageEngine;
const Parser = @import("parser.zig").Parser;
const commandError = @import("types.zig").commandError;
const util = @import("util.zig");

test "parser" {
    var parser = Parser.init("set joe 'is gay");
    var engine = StorageEngine.init("headerset", "testdbset", "testsetstore");
    try engine.setup();
    try parser.parse(&engine);

    try std.fs.cwd().deleteTree(engine.storeDirName);
}

test "parse identifier with get" {
    var parser = Parser.init("set joe 'is gay");
    var parser2 = Parser.init("get joe");
    var engine = StorageEngine.init("head", "dbset", "tstore");
    try engine.setup();
    try parser.parse(&engine);
    try engine.printKeys();
    try parser2.parse(&engine);

    try std.fs.cwd().deleteTree(engine.storeDirName);
}
