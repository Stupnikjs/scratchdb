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

    pub fn init(source: String) Lexer {
        return .{
            .source = source,
            .position = 0,
        };
    }
    pub fn readCommand(self: *Lexer) ?Token {
        if (self.source.len - self.position >= 3) {
            const str = self.source[self.position .. self.position + 3];
            if (streql(u8, str, "set")) {
                self.position += 3;
                return .{
                    .kind = tokenType.set,
                    .value = null,
                };
            }
            if (streql(u8, str, "del")) {
                self.position += 3;
                return .{
                    .kind = tokenType.del,
                    .value = null,
                };
            }
            if (streql(u8, str, "get")) {
                self.position += 3;
                return .{
                    .kind = tokenType.get,
                    .value = null,
                };
            }
            return null;
        }
        return null;
    }

    pub fn nextToken(self: *Lexer) !?Token {
        std.debug.print("char: {c} \n", .{self.source[self.position]});
        var token = readCommand(self);
        if (token == null) {
            self.position += 1;
            std.debug.print(" pos: {d} \n", .{self.source[self.position]});
            var list = std.ArrayList(u8).init(std.heap.page_allocator);
            defer list.deinit();
            while (self.source[self.position] != ' ') {
                try list.append(self.source[self.position]);
                self.position += 1;
            }
            token = Token{
                .kind = tokenType.indentifier,
                .value = try list.toOwnedSlice(),
            };
            return token;
        }

        return token.?;
    }
};
