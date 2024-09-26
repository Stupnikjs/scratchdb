const std = @import("std");
const expect = std.testing.expect;
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;
const tokenType = @import("types.zig").tokenType;

test "lexer del" {
    var lexer = Lexer.init("set set");
    var parser = Parser.init(&lexer);
    const tokens = try parser.parse();

    for (tokens) |t| {
        std.debug.print("{any}", .{t});
    }
}
