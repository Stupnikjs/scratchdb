const std = @import("std");
const String = @import("types.zig").String;
const streql = std.mem.eql;
const tokenType = @import("types.zig").tokenType;
const Token = @import("types.zig").Token;
const Parser = @import("parser.zig").Parser;
//

pub fn firstdb() !void {
    const stdin = std.io.getStdIn().reader();

    while (true) {
        std.debug.print(":>", .{});
        var buffer: [1024]u8 = undefined;
        const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
        const str = user_input[0 .. user_input.len - 1];
        try ParseCommand(str);
    }
}

pub fn ParseCommand(str: String) !void {
    var lex = Lexer.init(str);
    var parser = Parser{
        .lexer = &lex,
    };
    const tokens = try parser.parse();
    for (tokens) |t| {
        std.debug.print("{any}", .{t});
    }
}

pub const Lexer = struct {
    source: String,
    position: u64,
    ch: u8,

    pub fn init(source: String) Lexer {
        return .{
            .source = source,
            .position = 0,
            .ch = source[0],
        };
    }

    pub fn nextToken(self: *Lexer) Token {
        // return current token and move cursor forward
        if (streql(u8, self.source[self.position .. self.position + 2], "set")) {
            self.position += 3;
            self.movecursor();
            self.movecursor();
            self.movecursor();
            return .{ .kind = tokenType.set, .value = null };
        } else {
            return .{ .kind = tokenType.del, .value = null };
        }
    }
    fn eatWhiteSpace(self: *Lexer) void {
        if (self.ch == ' ' or self.ch == '\n' or self.ch == '\r') {
            self.position += 1;
            if (self.source.len > self.position) self.movecursor();
        }
    }
    fn movecursor(self: *Lexer) void {
        self.ch = self.source[self.position];
    }
};
