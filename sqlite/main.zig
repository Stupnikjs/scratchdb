const std = @import("std");
const prompt = @import("input.zig").prompt;
const streql = std.mem.eql;
const types = @import("types.zig");
const metaCMDresult = types.metaCMDresult;
const statementType = types.statementType;
const prepare_result = types.prepareResult;

// https://cstack.github.io/db_tutorial/parts/part3.html

pub fn main() !void {
    while (true) {
        const cmd = try prompt();
        if (cmd[0] == '.') {
            const meta_cmd = try doMetaCmd(cmd);
            if (meta_cmd == metaCMDresult.unreconized_command) {
                std.debug.print("unreconized command \n", .{});
            }
        }
        var stmt: statement = undefined;
        const res = prepareStatement(cmd, &stmt);
        if (res == prepare_result.success) {
            executeStmt(stmt);
            continue;
        }
    }
}

fn doMetaCmd(cmd: []const u8) !metaCMDresult {
    if (streql(u8, cmd, ".exit")) std.process.exit(2);
    return metaCMDresult.unreconized_command;
}

fn prepareStatement(cmd: []const u8, stmt: *statementType) prepare_result {
    if (streql(u8, cmd[0..6], "insert")) {
        stmt.* = statementType.insert;
        return prepare_result.success;
    }
    if (streql(u8, cmd[0..6], "select")) {
        stmt.* = statementType.select;
        return prepare_result.success;
    }
    return prepare_result.unreconized_statement;
}

pub fn executeStmt(stmt: statement) void {
    switch (stmt) {
        .insert => {
            std.debug.print("this is insert stmt \n", .{});
        },
        .select => {
            std.debug.print("this is select stmt \n", .{});
        },
    }
}
