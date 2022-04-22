const clap = @import("clap");
const std = @import("std");

const debug = std.debug;
const io = std.io;
const mem = std.mem;
const time = std.time;
const fs = std.fs;

const allocator = std.heap.c_allocator;

var timer: ?time.Timer = null;

pub fn main() !void {
   timer = try time.Timer.start();

   const params = comptime [_]clap.Param(clap.Help) {
      clap.parseParam("-h, --help Display this help and exit.") catch unreachable,
      clap.parseParam("-i, --inject <STR> The path to the Electron app.") catch unreachable,
      clap.parseParam("-u, --uninject <STR> The path to the Electron app.") catch unreachable,
      clap.parseParam("-k, --kernel <STR> The path to your Kernel distro. If left out it uses the current directory.") catch unreachable,
   };

   var diag = clap.Diagnostic{};
   var args = clap.parse(clap.Help, &params, .{ .diagnostic = &diag }) catch |err| {
      diag.report(io.getStdErr().writer(), err) catch {};
      return err;
   };
   defer args.deinit();

   if (args.option("--inject")) |inject| {
      if (args.option("--kernel")) |kernel| {
         debug.print("Injecting...\n", .{});

         const kernel_path = try fs.path.resolve(allocator, &[_][]const u8{ kernel });

         const app_path = try fs.path.resolve(allocator, &[_][]const u8{ inject });

         var resources_path = try fs.path.join(allocator, &[_][]const u8{ app_path, "resources" });

         // Test if the folder is (probably) either a valid electron app path or an app resources path.
         _ = fs.openDirAbsolute(resources_path, .{}) catch {
            resources_path = app_path;
         };

         const app_folder_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app" });
         const app_asar_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app.asar" });

         const app_folder_index_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app", "index.js" });
         const app_folder_package_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app", "package.json" });

         const app_original_folder_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app-original" });
         const app_original_asar_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app-original.asar" });

         debug.print("Detecting injection...\n", .{});
         var injected = true;
         _ = fs.openDirAbsolute(app_original_folder_path, .{}) catch {
            injected = false;
         };
         if (injected) alreadyInjected();
         injected = true;
         _ = fs.openFileAbsolute(app_original_asar_path, .{}) catch {
            injected = false;
         };
         if (injected) alreadyInjected();

         debug.print("No injection visible.\n", .{});
         debug.print("Detecting ASAR.\n", .{});
         var usesAsar = false;
         _ = fs.openDirAbsolute(app_asar_path, .{}) catch {
            usesAsar = true;
         };
         debug.print("Uses ASAR: {s}\n", .{ usesAsar });
         debug.print("Renaming...\n", .{});
         if (usesAsar) {
            fs.renameAbsolute(app_asar_path, app_original_asar_path) catch appRunning();
         } else {
            fs.renameAbsolute(app_folder_path, app_original_folder_path) catch appRunning();
         }

         debug.print("Adding files.\n", .{});
         try fs.makeDirAbsolute(app_folder_path);

         const index = try fs.createFileAbsolute(app_folder_index_path, .{});
         const package = try fs.createFileAbsolute(app_folder_package_path, .{});
         defer index.close();
         defer package.close();

         try index.writeAll(
            \\const pkg = require("./package.json");
            \\const Module = require("module");
            \\const path = require("path");
            \\
            \\try {
            \\  const kernel = require(path.join(pkg.location, "kernel.asar"));
            \\  if (kernel?.default) kernel.default({ startOriginal: true });
            \\} catch(e) {
            \\  console.error("Kernel failed to load: ", e.message);
            \\  Module._load(path.join(__dirname, "..", "app-original.asar"), null, true);
            \\}
         );

         const package_start = "{\"name\":\"kernel\",\"main\":\"index.js\",\"location\":\"";
         const package_end = "\"}";

         const package_json = try mem.join(allocator, "", &[_][]const u8{ package_start, kernel_path, package_end });
         defer allocator.free(package_json);
         try package.writeAll(try replaceSlashes(package_json));
         if (timer) |t| {
            const end_time = t.read();
            debug.print("Done in: {d}\n", .{ std.fmt.fmtDuration(end_time) });
         }

         return std.os.exit(0);
      }
   }

   try clap.help(
      io.getStdErr().writer(),
      comptime &params
   );

   std.os.exit(0);
}

pub fn invalidAppDir() void {
   debug.print("Invalid Electron app directory.\n", .{});
   std.os.exit(0);
}

pub fn alreadyInjected() void {
   debug.print("Something is already injected there.\n", .{});
   std.os.exit(0);
}

pub fn appRunning() void {
   debug.print("The app is running, close it before injecting.\n", .{});
   std.os.exit(0);
}

pub fn replaceSlashes(string: []const u8) ![]u8 {
   const result = try allocator.alloc(u8, string.len);
   var i: i128 = 0;
   for (string) |char| {
      if (char == '\\') {
         result[@intCast(usize, i)] = '/';
      } else {
         result[@intCast(usize, i)] = char;
      }
      i += 1;
   }
   return result;
}
