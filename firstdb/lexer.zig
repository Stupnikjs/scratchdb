const std = @import("std");
const String = @import("types.zig").String;
const streql = std.mem.eql;
const tokenType = @import("types.zig").tokenType;
const Token = @import("types.zig").Token;
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
    std.debug.print("{s} {s}", .{ "test", str });
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
    pub fn nexToken(old_self: *Lexer) Token {
        const self = eatWhiteSpace(old_self);
        // check command
        if (streql(u8, self.source[self.position .. self.position + 3], "get")) {
            self.position += 3;
            return .{
                .kind = tokenType.get,
                .value = null,
            };
        }
        if (streql(u8, self.source[self.position .. self.position + 3], "del")) {
            self.position += 3;
            return .{
                .kind = tokenType.del,
                .value = null,
            };
        }
        if (streql(u8, self.source[self.position .. self.position + 3], "set")) {
            self.position += 3;
            return .{
                .kind = tokenType.set,
                .value = null,
            };
        }
        const value = getIndentifierValue(self); 
        return .{
            .kind = tokenType.indentifier;  
            .value = value; 
        }
       
    };
     pub fn getIndentifierValue(self: *Lexer) !String {
         var list = std.ArrayList(u8).init(std.heap.page_allocator);
         const start = self.position; 
         defer list.deinit(); 
         var i: usize = 0;  
         while (true){
            if (source[self.position] == " " or source[self.position] == "\n") {
                return indent;
            }
            else {
                try list.append(source[i]); 
                i += 1;
                self.position += 1; 
            } 


         }
        }

    fn eatWhiteSpace(self: *Lexer) *Lexer {
        if (self.ch == ' ' or self.ch == '\n' or self.ch == '\r') {
            self.position += 1;
            return self;
        }
        return self;
    }
};
