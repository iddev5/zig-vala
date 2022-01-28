const std = @import("std");
const ZigValaStep = @import("ZigValaStep.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const vala = ZigValaStep.init(b, "basic");
    vala.addSourceFile("src/main.vala");
    vala.addPackage("gtk+-3.0");
    vala.exe.setTarget(target);
    vala.exe.setBuildMode(mode); 
    vala.exe.install();

    const run_cmd = vala.exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
