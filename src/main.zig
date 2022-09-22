const std = @import("std");
const fs = std.fs;
const heap = std.heap;
const exit = std.os.exit;
const mem = std.mem;
const log = @import("./log.zig");

const Args = struct {
    dir_path: ?[]const u8,
    parents: bool,
    len: usize,

    fn init(allocator: mem.Allocator, args_slice: [][]u8) !*Args {
        var args = try allocator.create(Args);
        args.* = Args {
            .len = args_slice.len,
            .parents = false,
            .dir_path = null,
        };

        for (args_slice) |arg| {
            if (mem.eql(u8, "-p", arg)) {
                args.parents = true;
                continue;
            }

            args.dir_path = arg;
        }

        return args;
    }
};

pub fn main() void {
    var buffer: [1024]u8 = undefined;
    var fba = heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const args_slice = std.process.argsAlloc(allocator) catch |err| {
        logError(err);
    };
    defer std.process.argsFree(allocator, args_slice);

    const args = Args.init(allocator, args_slice[1..]) catch |err| {
        logError(err);
    };
    defer allocator.destroy(args);

    if (args.dir_path == null) {
        log.err("the dir path is missing", .{});
        exit(1);
    }

    const dir_path = args.dir_path.?;
    const dir = fs.cwd();

    if (args.parents) {
        dir.makePath(dir_path) catch |err| {
            logError(err);
        };
    } else {
        dir.makeDir(dir_path) catch |err| {
            logError(err);
        };
    }

    log.info("dir '{s}' created sucessfully", .{dir_path});
}

fn logError(err: anyerror) noreturn {
    log.err("{s}" , .{@errorName(err)});
    exit(1);
}