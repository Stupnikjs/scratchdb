const std = @import("std");
const expect = std.testing.expect;
const Lexer = @import("lexer.zig").Lexer;
const tokenType = @import("types.zig").tokenType;

test "lexer set" {
    var lexer = Lexer.init("set michel 'balala'");
    const nextTok = lexer.nexToken();
    try expect(nextTok.kind == tokenType.set);

    const next_nextToken = lexer.nexToken();
    try expect(next_nextToken.kind == tokenType.indentifier);
}
test "lexer get " {
    var lexer = Lexer.init("get michel 'balala'");
    const nextTok = lexer.nexToken();
    try expect(nextTok.kind == tokenType.get);

    const next_nextToken = lexer.nexToken();
    try expect(next_nextToken.kind == tokenType.indentifier);
}
test "lexer del" {
    var lexer = Lexer.init("del michel 'balala'");
    const nextTok = lexer.nexToken();
    try expect(nextTok.kind == tokenType.del);

    const next_nextToken = lexer.nexToken();
    try expect(next_nextToken.kind == tokenType.indentifier);
}
