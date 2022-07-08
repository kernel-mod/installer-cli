const std = @import("std");

const CrossTarget = std.zig.CrossTarget;
const Mode = std.builtin.Mode;
const Target = std.Target;

const BuildTarget = struct {
    name: []const u8,
    cross_target: CrossTarget,
    mode: Mode,
};

pub fn build(b: *std.build.Builder) void {
    const zig_clap: std.build.Pkg = .{ .name = "clap", .path = .{ .path = "lib/zig-clap/clap.zig" } };
    const compile_all_targets = b.option(bool, "all-targets", "Whether to compile for all supported targets.") orelse false;

    if (!compile_all_targets) {
        const target = b.standardTargetOptions(.{});
        const mode = b.standardReleaseOptions();

        const exe = b.addExecutable("installer-cli", "src/main.zig");
        exe.strip = true;
        exe.single_threaded = true;

        exe.linkLibC();
        exe.addPackage(zig_clap);

        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        return;
    }

    const targets = [_]BuildTarget{
        .{ .name = "kernel-installer-i386-windows", .cross_target = .{
            .cpu_arch = Target.Cpu.Arch.i386,
            .os_tag = Target.Os.Tag.windows,
        }, .mode = Mode.ReleaseFast },
        .{ .name = "kernel-installer-x86_64-windows", .cross_target = .{
            .cpu_arch = Target.Cpu.Arch.x86_64,
            .os_tag = Target.Os.Tag.windows,
        }, .mode = Mode.ReleaseFast },
        .{ .name = "kernel-installer-i386-linux", .cross_target = .{
            .cpu_arch = Target.Cpu.Arch.i386,
            .os_tag = Target.Os.Tag.linux,
        }, .mode = Mode.ReleaseFast },
        .{ .name = "kernel-installer-x86_64-linux", .cross_target = .{
            .cpu_arch = Target.Cpu.Arch.x86_64,
            .os_tag = Target.Os.Tag.linux,
        }, .mode = Mode.ReleaseFast },
        .{ .name = "kernel-installer-x86_64-macos", .cross_target = .{
            .cpu_arch = Target.Cpu.Arch.x86_64,
            .os_tag = Target.Os.Tag.macos,
        }, .mode = Mode.ReleaseFast },
    };

    for (targets) |target| {
        const target_exe = b.addExecutable(target.name, "src/main.zig");
        target_exe.strip = true;
        target_exe.single_threaded = true;

        target_exe.linkLibC();
        target_exe.addPackage(zig_clap);

        target_exe.setTarget(target.cross_target);
        target_exe.setBuildMode(target.mode);
        target_exe.install();
    }
}
