const std = @import("std");
const fs = std.fs;
const String = @import("types.zig").String;

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

    // pub fn set(self: *StorageEngine, key: []const u8, value: []const u8) !void {}
};
