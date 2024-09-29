const std = @import("std");
const fs = std.fs;
const String = @import("types.zig").String;
const u64toBytes = @import("util.zig").u64tobytes;
const paddKey = @import("util.zig").addPaddingKey;

pub const StorageEngine = struct {
    headerFileName: String,
    dbFileName: String,
    storeDirName: String,
    pub fn init() StorageEngine {
        // test if header exist
        // if doesnt create dir and files

        return .{
            .headerFileName = "header",
            .dbFileName = "db",
            .storeDirName = "store",
        };
    }
    pub fn createHeaderFile(self: *StorageEngine) !void {
        const storageDir = try fs.cwd().openDir(self.storeDirName, .{});
        _ = try storageDir.createFile(self.headerFileName, .{});
    }
    pub fn createDBFile(self: *StorageEngine) !void {
        const storageDir = try fs.cwd().openDir(self.storeDirName, .{});
        _ = try storageDir.createFile(self.dbFileName, .{});
    }
    pub fn makeStoreDir(self: *StorageEngine) !void {
        _ = try fs.cwd().makeDir(self.storeDirName);
    }

    pub fn setup(self: *StorageEngine) !void {
        _ = self.makeStoreDir() catch |err| {
            if (err == error.PathAlreadyExists) return;
            return err;
        };
        _ = self.createDBFile() catch |err| {
            if (err == error.PathAlreadyExists) return;
            return err;
        };
        _ = self.createHeaderFile() catch |err| {
            if (err == error.PathAlreadyExists) return;
            return err;
        };
    }

    pub fn openStoreDir(self: *StorageEngine) !fs.Dir {
        const dir = try fs.cwd().openDir(self.storeDirName, .{});
        return dir;
    }

    pub fn set(self: *StorageEngine, key: []const u8, value: []const u8) !void {
        var dir = try self.openStoreDir();
        var file = try dir.openFile(self.headerFileName, .{ .mode = .read_write });
        const paddedKey = try paddKey(key);
        const stat = try file.stat();
        try file.seekTo(stat.size);
        const start = stat.size + 8;
        _ = try file.writer().write(paddedKey);
        _ = try file.write(&u64toBytes(start));
        _ = try file.write(&u64toBytes(value.len));
        file.close();
    }

    pub fn printHeader(self: *StorageEngine) !void {
        var dir = try self.openStoreDir();
        var file = try dir.openFile(self.headerFileName, .{ .mode = .read_write });
        var buffer: [1024]u8 = undefined;
        const size = try file.readAll(&buffer);
        for (buffer[0..size]) |b| {
            std.debug.print("{c}", .{b});
        }
    }

    pub fn parseHeaderFile(self: *StorageEngine) !void {
        var dir = try self.openStoreDir();
        var file = try dir.openFile(self.headerFileName, .{ .mode = .read_only });
        var buffer: [8]u8 = undefined;
        var index: u8 = 0;
        while (true) {
            const size = try file.read(&buffer);
            if (size == 0) break;
            if (index % 3 == 0) std.debug.print("key: {s} \n", .{buffer});
            buffer = undefined;
            index += 1;
        }

        // remove key padding
        // get the start end num
        // store in hash map
    }
};
