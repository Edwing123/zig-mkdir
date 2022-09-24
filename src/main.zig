const std = @import("std");
const fs = std.fs;
const heap = std.heap;
const exit = std.os.exit;
const mem = std.mem;
const log = @import("./log.zig");

const buffer_size = 1024;

pub fn main() void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();

    var sfa = heap.stackFallback(buffer_size, arena.allocator());
    const allocator = sfa.get();

    const args_slice = std.process.argsAlloc(allocator) catch |err| {
        log.err("{s}" , .{@errorName(err)});
        exit(1);
    };

    if (args_slice.len < 2) {
        log.err("No paths provided", .{});
        exit(1);
    }

    const dir = fs.cwd();

    // Iterable over all args, except the first one,
    // because that's the path of the executable.
    for (args_slice[1..]) |arg| {
        makeDir(arg, dir) catch |err| {
            log.err("while creating '{s}', {s}", .{ arg, @errorName(err) });
            continue;
        };

        log.info("dir '{s}' created sucessfully", .{arg});
    }   
}

fn makeDir(path: []const u8, dir: fs.Dir) !void {
    const is_absolute = fs.path.isAbsolute(path);

    if (is_absolute) {
        try dir.makePath(path);
        return;
    }

    try dir.makeDir(path);
}