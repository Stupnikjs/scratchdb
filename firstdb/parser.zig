const Lexer = @import("lexer.zig").Lexer;
const Token = @import("types.zig").Token;
const std = @import("std");
const Parser = struct {
    lexer: Lexer,

    fn parse(self: Parser) []Token {
        var list = std.ArrayList(Token).init(std.heap.page_allocator);
        defer list.deinit();
        while (self.lexer.nexToken()) {
            try list.append(self.lexer.nexToken());
        }
        return list.toOwnedSlice();
    }
};
