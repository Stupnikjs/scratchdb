const Lexer = @import("lexer.zig").Lexer;
const Token = @import("types.zig").Token;
const std = @import("std");
pub const Parser = struct {
    lexer: *Lexer,
    curToken: Token,
    peekToken: Token,
    pub fn init(lexer: *Lexer) Parser {
        return .{
            .lexer = lexer,
        };
    }
    pub fn parse(self: *Parser) ![]Token {
        _ = self;
    }
};
