const std = @import("std");
const pkgs = @import("deps.zig").pkgs;
const builtin = @import("builtin");

const Mode = std.builtin.Mode;

const CrossTarget = std.zig.CrossTarget;
const Target = std.Target;

const BuildTarget = struct {
    name: []const u8,
    cross_target: CrossTarget,
    mode: Mode,
};

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.

    const targets = [_]BuildTarget{
        .{
            .name = "kernel-installer-i386-windows",
            .cross_target = .{
                .cpu_arch = Target.Cpu.Arch.i386,
                .os_tag = Target.Os.Tag.windows,
            },
            .mode = Mode.ReleaseFast
        },
        .{
            .name = "kernel-installer-x86_64-windows",
            .cross_target = .{
                .cpu_arch = Target.Cpu.Arch.x86_64,
                .os_tag = Target.Os.Tag.windows,
            },
            .mode = Mode.ReleaseFast
        },
        .{
            .name = "kernel-installer-i386-linux",
            .cross_target = .{
                .cpu_arch = Target.Cpu.Arch.i386,
                .os_tag = Target.Os.Tag.linux,
            },
            .mode = Mode.ReleaseFast
        },
        .{
            .name = "kernel-installer-x86_64-linux",
            .cross_target = .{
                .cpu_arch = Target.Cpu.Arch.x86_64,
                .os_tag = Target.Os.Tag.linux,
            },
            .mode = Mode.ReleaseFast
        },
        .{
            .name = "kernel-installer-x86_64-macos",
            .cross_target = .{
                .cpu_arch = Target.Cpu.Arch.x86_64,
                .os_tag = Target.Os.Tag.macos,
            },
            .mode = Mode.ReleaseFast
        },
    };

    for (targets) |target| {
        const exe = b.addExecutable(target.name, "src/main.zig");
        exe.strip = true;
        exe.single_threaded = true;
        exe.setTarget(target.cross_target);
        exe.setBuildMode(target.mode);
        exe.linkLibC();
        pkgs.addAllTo(exe);
        exe.install();
    }
}
