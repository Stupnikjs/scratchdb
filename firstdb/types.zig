pub const String = []const u8;

pub const tokenType = enum {
    get,
    set,
    del,
    indentifier,
    value,
    quote,
};

pub const Token = struct {
    kind: tokenType,
    value: ?[]const u8,
};
