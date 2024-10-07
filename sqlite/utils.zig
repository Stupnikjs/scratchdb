const std = @import("std");

pub const Params = struct {
    username: ?[]const u8,
    email: ?[]const u8,
    pub fn init() Params {
        return .{
            .username = null,
            .email = null,
        };
    }
};

pub fn parseUsernameEmail(input: []const u8, params: *Params) !void {
    var username_list = std.ArrayList(u8).init(std.heap.page_allocator);
    defer username_list.deinit();
    var email_list = std.ArrayList(u8).init(std.heap.page_allocator);
    defer email_list.deinit();
    for (input[9..]) |c| {
        if (c == ' ' and params.username == null and params.email == null) {
            params.username = try username_list.toOwnedSlice();
        }
        if (c == ' ' and params.email == null) {
            params.email = try email_list.toOwnedSlice();
        }
        if (params.username == null and params.email == null) {
            try username_list.append(c);
        }
        if (params.email == null) {
            try email_list.append(c);
        }
    }
}
