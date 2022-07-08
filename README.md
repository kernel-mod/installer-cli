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
- [Zig](https://ziglang.org/download/), `>=0.9.1`.

#### Steps

1. Clone this repository to your development environment.
   
   ```sh
   # optionally, provide a destination path and/or use SSH
   git clone https://github.com/kernel-mod/installer-cli.git --recurse-submodules
   cd installer-cli
   ```
   > `--recurse-submodules` is NOT optional, as we use them for depending on `zig-clap`.

2. Run `zig build`, optionally passing the `-Drelease-fast` flag, for both a smaller and faster binary.

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
