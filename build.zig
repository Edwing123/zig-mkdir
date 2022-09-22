const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zigdir", "./src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.single_threaded = true;

    if (mode != .Debug) {
        exe.strip = true;
    }

    const install_artifact = b.addInstallArtifact(exe);
    b.getInstallStep().dependOn(&install_artifact.step);

    const run_app_step = std.build.RunStep.create(b, "run app");
    run_app_step.addArtifactArg(exe);
    if (b.args) |args| {
        run_app_step.addArgs(args);
    }

    const run_step = b.step("run", "run app");
    run_step.dependOn(&run_app_step.step);
}