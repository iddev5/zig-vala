const std = @import("std");
const Step = std.build.Step;
const Builder = std.build.Builder;

builder: *Builder,
step: Step,
exe: *std.build.LibExeObjStep,
file: []const u8,
deps: std.ArrayList([]const u8),
path: []const u8,

const ZigValaStep = @This();

pub fn init(b: *Builder, name: []const u8, file: []const u8) *ZigValaStep {
    var res = b.allocator.create(ZigValaStep) catch @panic("out of memory");
    res.* = .{
        .file = file,
        .step = Step.init(.custom, "compile a vala project", b.allocator, make),
        .exe = b.addExecutable(name, null),
        .builder = b,
        .deps = std.ArrayList([]const u8).init(b.allocator),
        .path = std.fs.path.join(b.allocator, &.{ b.build_root, "zig-cache", "vala" }) catch @panic("out of memory"),
    };

    const c_file = std.fs.path.join(b.allocator, &.{
        res.path,
        std.mem.concat(
            b.allocator,
            u8,
            &.{ removeExtension(res.file), ".c" },
        ) catch @panic("out of memory"),
    }) catch @panic("out of memory");
    defer b.allocator.free(c_file);

    res.exe.step.dependOn(&res.step);
    res.exe.linkLibC();
    res.exe.addCSourceFile(c_file, &.{});

    return res;
}

pub fn addPackage(self: *ZigValaStep, pkg: []const u8) void {
    self.deps.append(pkg) catch @panic("out of memory");
    self.exe.linkSystemLibrary(pkg);
}

fn removeExtension(filename: []const u8) []const u8 {
    const index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse return filename;
    if (index == 0) return filename;
    return filename[0..index];
}

fn make(step: *Step) !void {
    const self = @fieldParentPtr(ZigValaStep, "step", step);
    const builder = self.builder;
    const allocator = builder.allocator;

    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    try args.append("valac");
    try args.append("-C");
    try args.append(self.file);
    try args.append("-d");
    try args.append(self.path);

    for (self.deps.items) |dep| {
        try args.append("--pkg");
        try args.append(dep);
    }

    const proc = try std.ChildProcess.init(args.items, allocator);
    defer proc.deinit();

    proc.stdin_behavior = .Ignore;
    proc.stdout_behavior = .Inherit;
    proc.stderr_behavior = .Inherit;
    proc.cwd = builder.build_root;
    proc.env_map = builder.env_map;

    try proc.spawn();
    const result = try proc.wait();
    switch (result) {
        .Exited => |code| if (code != 0) {
            std.os.exit(0xff);
        },
        else => {
            std.log.err("valac failed with: {}", .{result});
            std.os.exit(0xff);
        },
    }
}