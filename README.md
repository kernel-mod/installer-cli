## Download

Get the build for your system from [releases](https://github.com/kernel-mod/installer-cli/releases/latest).

## Community

Join on [Discord](https://discord.gg/8mPTjTZ4SZ) or [Matrix](https://matrix.to/#/!iWdiwStUmqwDcNfYbG:bigdumb.gq?via=bigdumb.gq&via=catvibers.me&via=matrix.org).

## Build From Source

Real instructions coming soon. You need [Zig 0.9.0](https://ziglang.org/download/) or higher and [Gyro](https://github.com/mattnite/gyro).

## Installation

#### Linux / MacOS

```zsh
./installer-cli -i /Applications/Discord.app/Contents -k ~/location/of/kernel
```

#### Windows

```bash
installer-cli -i C:/Users/Username/AppData/Roaming/Discord/app-X.X.XXX -k location/of/kernel
```

## Flags

`-h`, `--help` displays help and exits.

`-i`, `--inject <string>` injects to the Electron application. 

`-u`, `--uninject <string>` uninjects the Electron application.

`-k`, `--kernel <string>` injects using the path of where the `kernel.asar` and `kernel` parent folder is.

## Troubleshooting

#### Linux / MacOS

```zsh
chmod 755 ./installer-cli
```

or

```zsh
chmod +x ./installer-cli
```

Adds execution permissions in order for the script to run.

Linux may require `sudo` in front.
