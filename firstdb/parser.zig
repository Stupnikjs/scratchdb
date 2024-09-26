const Lexer = @import("lexer.zig").Lexer;
const Token = @import("types.zig").Token;
const std = @import("std");
pub const Parser = struct {
    lexer: *Lexer,

    pub fn init(lexer: *Lexer) Parser {
        return .{
            .lexer = lexer,
        };
    }
    pub fn parse(self: *Parser) ![]Token {
        var list = std.ArrayList(Token).init(std.heap.page_allocator);
        defer list.deinit();

        while (true) {
            std.debug.print("loop", .{});
            const tok = self.lexer.nextToken();
            try list.append(tok);
            if (self.lexer.position >= self.lexer.source.len - 1) break;
        }
        return list.toOwnedSlice();
    }
};
