## Download

Get the build for your system from [releases](https://github.com/kernel-mod/installer-cli/releases/latest).

## Community

Join on [Discord](https://discord.gg/8mPTjTZ4SZ) or [Matrix](https://matrix.to/#/!iWdiwStUmqwDcNfYbG:bigdumb.gq?via=bigdumb.gq&via=catvibers.me&via=matrix.org).

## Build From Source

Real instructions coming soon. You need [Zig 0.9.0](https://ziglang.org/download/) or higher and [Gyro](https://github.com/mattnite/gyro).

## Usage

#### Windows
```bash
installer-cli -i C:/Users/Username/AppData/Roaming/Discord/app-X.X.XXX -k location/of/kernel
```

#### MacOS
```zsh
./installer-cli -i /Applications/Discord.app/Contents -k ~/location/of/kernel
```

The `-i` flag specifies the path to the Electron app to inject into.

It should be the path to the directory above the `resources` folder.

The `-k` flag specifies the path to the folder Kernel is in.
