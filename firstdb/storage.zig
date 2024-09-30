const std = @import("std");
const fs = std.fs;
const String = @import("types.zig").String;
const u64toBytes = @import("util.zig").u64tobytes;
const paddKey = @import("util.zig").addPaddingKey;
const removePadding = @import("util.zig").removePadding;
const util = @import("util.zig");

pub const StorageEngine = struct {
    map: std.StringArrayHashMap([2]u64),
    headerFileName: String,
    dbFileName: String,
    storeDirName: String,
    pub fn init() StorageEngine {
        return .{
            .map = undefined,
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
        self.map = std.StringArrayHashMap([2]u64).init(std.heap.page_allocator);
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
        var headerFile = try dir.openFile(self.headerFileName, .{ .mode = .read_write });
        var dbFile = try dir.openFile(self.dbFileName, .{ .mode = .read_write });

        // fill the key to its 8 bytes
        const paddedKey = try paddKey(key);
        const header_stat = try headerFile.stat();
        const db_stat = try dbFile.stat();

        // point to the end of the file
        try headerFile.seekTo(header_stat.size);
        const start = db_stat.size; // start of the file in dbfile

        _ = try headerFile.writer().write(paddedKey);
        _ = try headerFile.write(&u64toBytes(start));
        _ = try headerFile.write(&u64toBytes(value.len + start));
        _ = try dbFile.write(value);
        const arr = [2]u64{ start, start + value.len };
        try self.map.put(key, arr);
        headerFile.close();
        dbFile.close();
    }

    pub fn get(self: *StorageEngine, key: []const u8) []u8 {
        _ = self;
        _ = key;
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
        var key: []const u8 = undefined;
        var coord: [2]u64 = [2]u64{ 0, 0 };

        while (true) {
            const size = try file.read(&buffer);
            if (size == 0) break;
            if (index % 3 == 0) {
                key = try removePadding(&buffer);
                std.debug.print("key: {s} \n", .{key});
                if (!util.stringInArr(key, self.map.keys())) try self.map.put(key, coord) else {
                    std.debug.print(" key already registered", .{});
                }
            }
            if (index % 3 == 1) {
                std.debug.print(" u64 {d} \n", .{util.bytesToU64LE(buffer)});
            }
            coord[0] = util.bytesToU64LE(buffer);
            buffer = undefined;
            index += 1;
        }
    }
};
