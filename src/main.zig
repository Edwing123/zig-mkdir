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

    fn create(args_slice: [][]u8) Args {
        var args = Args {
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

const buffer_size = 1024;

pub fn main() void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();

    var sfa = heap.stackFallback(buffer_size, arena.allocator());
    const allocator = sfa.get();

    const args_slice = std.process.argsAlloc(allocator) catch |err| {
        logError(err);
    };
    defer std.process.argsFree(allocator, args_slice);

    const args = Args.create(args_slice[1..]);

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