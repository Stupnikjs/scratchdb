pub const String = []const u8;

pub const commandType = enum {
    get,
    set,
    del,
};

pub const commandError = error{
    unknownCommand,
    noSpaceBetweenCommandIdent,
    keyTooLong,
    keyAlreadyExist,
    WrongCommand,
    keyNotFound,
};
