## Build From Source

Real instructions coming soon. You need [Zig 0.9.0](https://ziglang.org/download/) or higher and [Gyro](https://github.com/mattnite/gyro).

## Usage

```bash
installer-cli -i path/to/electron/app -k path/to/kernel
```

The `-i` flag specifies the path to the Electron app to inject into.

It should be the path to the directory below the `resources` folder.

For example on Windows for Discord: `C:/Users/Kyza/AppData/Local/Discord/app-XXXX/`

The `-k` flag specifies the path to the folder Kernel is in.
