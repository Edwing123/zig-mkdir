const std = @import("std");
const stdOut = std.io.getStdOut().writer();
const stdErr = std.io.getStdErr().writer();

pub fn err(comptime format: []const u8, args: anytype) void {
    stdErr.print("err: " ++ format ++ "\n", args) catch {};
}

pub fn info(comptime format: []const u8, args: anytype) void {
    stdOut.print("info: " ++ format ++ "\n", args) catch {};
}