## Download

Get the build for your system from [releases](https://github.com/kernel-mod/installer-cli/releases/latest).

## Community

Join on [Discord](https://discord.gg/8mPTjTZ4SZ) or [Matrix](https://matrix.to/#/!iWdiwStUmqwDcNfYbG:bigdumb.gq?via=bigdumb.gq&via=catvibers.me&via=matrix.org).

## Build From Source

Real instructions coming soon. You need [Zig 0.9.0](https://ziglang.org/download/) or higher and [Gyro](https://github.com/mattnite/gyro).

## Usage

```bash
installer-cli -i path/to/electron/app -k path/to/kernel
```

The `-i` flag specifies the path to the Electron app to inject into.

It should be the path to the directory above the `resources` folder (or the '`resources`' folder itself, because of cases like discord\_arch\_electron/discord-canary-electron-bin on the AUR, which place the contents of the `resources` folder into `/usr/lib/discord` and `/usr/lib/discord-canary` respectively).

For example on Windows for Discord: `C:/Users/Kyza/AppData/Local/Discord/app-XXXX/`

The `-k` flag specifies the path to the folder Kernel is in.
