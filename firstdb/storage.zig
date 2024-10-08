const std = @import("std");
const fs = std.fs;
const String = @import("types.zig").String;
const commandError = @import("types.zig").commandError;
const util = @import("util.zig");
const u64toBytes = util.u64tobytes;
const paddKey = util.addPaddingKey;
const removePadding = util.removePadding;

pub const StorageEngine = struct {
    map: std.StringArrayHashMap([2]u64),
    headerFileName: String,
    dbFileName: String,
    storeDirName: String,
    pub fn init(headerName: []const u8, dbName: []const u8, dirName: []const u8) StorageEngine {
        return .{
            .map = undefined,
            .headerFileName = headerName,
            .dbFileName = dbName,
            .storeDirName = dirName,
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
        try self.parseHeaderFile();
        if (util.stringInArr(key, self.map.keys())) return commandError.keyAlreadyExist;
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
        _ = try headerFile.write(&u64toBytes(value.len));

        try dbFile.seekTo(db_stat.size);
        _ = try dbFile.write(value);
        const arr = [2]u64{ start, value.len };
        try self.map.put(key, arr);
        headerFile.close();
        dbFile.close();
        dir.close();
    }

    pub fn get(self: *StorageEngine, key: []const u8) ![]u8 {
        try self.parseHeaderFile();
        const coord = self.map.get(key);
        if (coord == null) return commandError.keyNotFound;
        var dir = try self.openStoreDir();
        var file = try dir.openFile(self.dbFileName, .{ .mode = .read_only });

        var buffer: [8912]u8 = undefined;
        _ = try file.reader().readAll(&buffer); // not efficient at all
        return buffer[coord.?[0] .. coord.?[0] + coord.?[1]];
    }

    pub fn del(self: *StorageEngine, key: []const u8) !void {
        const paddedKey = try util.addPaddingKey(key);
        var dir = try self.openStoreDir();
        var list = std.ArrayList([24]u8).init(std.heap.page_allocator);
        defer list.deinit();
        var file = try dir.openFile(self.headerFileName, .{ .mode = .read_write });
        try self.parseHeaderFile();
        defer file.close();
        // iterate over headerfile and rewrite it without key
        var buffer: [24]u8 = undefined; // OUR BATCH SIZE ;
        while (true) {
            const n = try file.read(&buffer);
            if (!std.mem.eql(u8, buffer[0..8], paddedKey)) try list.append(buffer);
            if (n == 0) break;
        }
        try dir.deleteFile(self.headerFileName);
        const removed = self.map.swapRemove(key);
        if (removed) {
            var newHeaderFile = try dir.createFile(self.headerFileName, .{});
            for (try list.toOwnedSlice()) |buf| {
                _ = try newHeaderFile.write(&buf);
            }
        } else {
            std.debug.print("fail to remove key from map \n", .{});
        }
    }

    pub fn printKeys(self: *StorageEngine) !void {
        try self.parseHeaderFile();
        for (self.map.keys()) |key| {
            std.debug.print("key :{s}", .{key});
        }
    }

    pub fn parseHeaderFile(self: *StorageEngine) !void {
        var dir = try self.openStoreDir();
        var file = try dir.openFile(self.headerFileName, .{ .mode = .read_only });

        var buffer: [24]u8 = undefined;
        var start: [8]u8 = undefined;
        var len: [8]u8 = undefined;
        var key: []const u8 = undefined;
        var coord: [2]u64 = [2]u64{ 0, 0 };
        while (true) {
            const size = try file.read(&buffer);
            if (size == 0) break;
            key = try removePadding(buffer[0..8]);
            start = buffer[8..16].*;
            len = buffer[16..].*;
            coord[0] = util.bytesToU64LE(start);
            coord[1] = util.bytesToU64LE(len);

            if (!util.stringInArr(key, self.map.keys())) try self.map.put(key, coord) else {
                continue;
            }
            coord = undefined;
            buffer = undefined;
            start = undefined;
            len = undefined;
        }
    }
};

// put start + size of value to hash
// delete will juste remove the key from header ?
