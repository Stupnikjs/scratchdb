const std = @import("std");
const expect = std.testing.expect;
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;
const tokenType = @import("types.zig").tokenType;

test "lexer set" {
    var lexer = Lexer.init("set  miceh ");
    const token = try lexer.nextToken();
    const nextTok = try lexer.nextToken();
    try expect(token.?.kind == tokenType.set);
    try expect(nextTok.?.kind == tokenType.indentifier);
}
