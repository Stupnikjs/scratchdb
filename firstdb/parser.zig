const std = @import("std");
const String = @import("types.zig").String;
const streql = std.mem.eql;
const commandType = @import("types.zig").commandType;
const commandError = @import("types.zig").commandError;
const StorageEngine = @import("storage.zig").StorageEngine;

pub fn firstdb() !void {
    const stdin = std.io.getStdIn().reader();
    const engine = StorageEngine.init("header", "db", "store");
    try engine.setup();
    while (true) {
        std.debug.print(":>", .{});
        var buffer: [1024]u8 = undefined;
        const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
        const str = user_input[0 .. user_input.len - 1];
        var parser = Parser.init(str);
        try parser.parse();
    }
}

pub const Parser = struct {
    source: String,
    position: u64,
    ch: u8,

    pub fn init(source: String) Parser {
        return .{
            .source = source,
            .position = 0,
            .ch = source[0],
        };
    }

    pub fn parseCommand(self: *Parser) commandError!commandType {
        if (streql(u8, self.source[self.position .. self.position + 3], "del")) {
            self.moveCursor();
            self.moveCursor();
            self.moveCursor();
            return commandType.del;
        }
        if (streql(u8, self.source[self.position .. self.position + 3], "get")) {
            self.moveCursor();
            self.moveCursor();
            self.moveCursor();
            return commandType.get;
        }
        if (streql(u8, self.source[self.position .. self.position + 3], "set")) {
            self.moveCursor();
            self.moveCursor();
            self.moveCursor();
            return commandType.set;
        }
        return commandError.unknownCommand;
    }

    pub fn moveCursor(self: *Parser) void {
        if (self.position > 0 and self.source.len <= self.position - 1) self.ch = 0;
        self.position += 1;
        self.ch = self.source[self.position];
    }
    pub fn parseIndentifier(self: *Parser) !String {
        var list = std.ArrayList(u8).init(std.heap.page_allocator);
        defer list.deinit();
        if (self.ch != ' ') return commandError.noSpaceBetweenCommandIdent;
        self.moveCursor();
        for (self.source[self.position .. self.source.len - 1]) |c| {
            if (c == ' ') break;
            try list.append(c);
            self.moveCursor();
        }
        return list.toOwnedSlice();
    }
    pub fn parse(self: *Parser, engine: *StorageEngine) !void {
        self.eatWhiteSpace();
        const cmd = try self.parseCommand();
        const indent = try self.parseIndentifier();
        std.debug.print("command: {any} indentifier: {s} \n", .{ cmd, indent });
        // pass the value
        switch (cmd) {
            commandType.set => engine.set(
                indent,
            ),
            else => return,
        }
    }
    pub fn eatWhiteSpace(self: *Parser) void {
        if (self.ch == ' ') {
            self.moveCursor();
        }
    }
};
