## `installer-cli`

> Make installing your favourite Electron modification both quick, and snappy!

---

### Table of Contents

- [Building from Source](#building-from-source)
    - [Requirements](#requirements)
    - [Steps](#steps)
- [Usage](#usage)
- [Download](#download)
- [Community](#community)

---

### Building from Source

#### Requirements

- [Git](https://git-scm.com/), recommended. *You can also directly download the ZIP of the repository.*
- [Zig](https://ziglang.org/download/), `>=0.9.0`.
- [Gyro](https://github.com/mattnite/gyro), `>=0.7.0`.

#### Steps

1. Clone this repository to your development environment.
   
   ```sh
   # optionally, provide a destination path and/or use SSH
   git clone https://github.com/kernel-mod/installer-cli.git
   cd installer-cli
   ```
2. Run `gyro fetch` to install the required dependencies.
   
    If you are using a build of `zig` that returns an error pointing to `deps.zig` when trying to
    build, replace the contents of that file with something akin to:
    ```zig
    const std = @import("std");

    pub const pkgs = struct {
        pub const clap = std.build.Pkg{
            .name = "clap",
            .path = .{
                .path = ".gyro\\zig-clap-Hejsil-github.com-********\\pkg\\clap.zig",
            },
        };

        pub fn addAllTo(artifact: *std.build.LibExeObjStep) void {
            artifact.addPackage(pkgs.clap);
        }
    };
    ``` 

3. Run `zig build`, `gyro build` is not necessary if using `gyro update` beforehand.

---

### Usage

```sh
installer-cli --kernel path/to/kernel.asar/folder --inject path/to/electron/app/dir
```

If you require more help with usage, call `installer-cli` with no options, or the `--help` option.

---

### Download

Get the build for your system from [releases](https://github.com/kernel-mod/installer-cli/releases/latest).

---

### Community

Join on [Discord](https://discord.gg/8mPTjTZ4SZ) or [Matrix](https://matrix.to/#/!iWdiwStUmqwDcNfYbG:bigdumb.gq?via=bigdumb.gq&via=catvibers.me&via=matrix.org).
