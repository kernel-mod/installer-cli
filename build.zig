const std = @import("std");

const Builder = std.build.Builder;
const CrossTarget = std.zig.CrossTarget;
const Pkg = std.build.Pkg;
const Target = std.Target;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const zig_clap: Pkg = .{ .name = "clap", .source = .{ .path = "lib/zig-clap/clap.zig" } };

    const strip_binaries = b.option(bool, "strip", "Whether to strip all resulting binaries.") orelse false;
    const compile_all_targets = b.option(bool, "all-targets", "Whether to compile for all supported targets.") orelse false;

    if (!compile_all_targets) {
        const target = b.standardTargetOptions(.{});

        const exe = b.addExecutable("installer-cli", "src/main.zig");
        exe.strip = strip_binaries;
        exe.single_threaded = true;

        exe.linkLibC();
        exe.addPackage(zig_clap);

        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        return;
    }

    const targets = [_]CrossTarget{
        .{
            .cpu_arch = Target.Cpu.Arch.aarch64,
            .os_tag = Target.Os.Tag.linux,
        },
        .{
            .cpu_arch = Target.Cpu.Arch.i386,
            .os_tag = Target.Os.Tag.linux,
        },
        .{
            .cpu_arch = Target.Cpu.Arch.x86_64,
            .os_tag = Target.Os.Tag.linux,
        },
        .{
            .cpu_arch = Target.Cpu.Arch.aarch64,
            .os_tag = Target.Os.Tag.macos,
        },
        .{
            .cpu_arch = Target.Cpu.Arch.x86_64,
            .os_tag = Target.Os.Tag.macos,
        },
        .{
            .cpu_arch = Target.Cpu.Arch.i386,
            .os_tag = Target.Os.Tag.windows,
        },
        .{
            .cpu_arch = Target.Cpu.Arch.x86_64,
            .os_tag = Target.Os.Tag.windows,
        },
    };

    inline for (targets) |target| {
        const target_name = comptime std.fmt.comptimePrint(
            "installer-cli_{s}_{s}",
            .{
                @tagName(target.os_tag.?),
                @tagName(target.cpu_arch.?)
            }
        );

        const target_exe = b.addExecutable(target_name, "src/main.zig");
        target_exe.strip = strip_binaries;
        target_exe.single_threaded = true;

        target_exe.linkLibC();
        target_exe.addPackage(zig_clap);

        target_exe.setTarget(target);
        target_exe.setBuildMode(mode);
        target_exe.install();
    }
}
