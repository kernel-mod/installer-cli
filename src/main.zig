const clap = @import("clap");
const std = @import("std");

const debug = std.debug;
const io = std.io;
const mem = std.mem;
const time = std.time;
const fs = std.fs;

const allocator = std.heap.page_allocator;

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

   if (args.flag("--help")) {
      try clap.help(
         io.getStdErr().writer(),
         comptime &params
      );
      return;
   }

   if (args.option("--inject")) |inject| {
      if (args.option("--kernel")) |kernel| {
         debug.print("Injecting...\n", .{});

         const kernel_path = try fs.path.resolve(allocator, &[_][]const u8{ kernel });

         const app_path = try fs.path.resolve(allocator, &[_][]const u8{ inject });
         const resources_path = try fs.path.join(allocator, &[_][]const u8{ app_path, "resources" });

         const app_folder_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app" });
         const app_asar_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app.asar" });

         const app_folder_index_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app", "index.js" });
         const app_folder_package_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app", "package.json" });

         const app_original_folder_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app-original" });
         const app_original_asar_path = try fs.path.join(allocator, &[_][]const u8{ resources_path, "app-original.asar" });

         // Test if the folder is (probably) a valid Electron app.
         _ = fs.openDirAbsolute(resources_path, .{}) catch invalidAppDir();

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

         try index.writeAll("const path=require(\"path\");require(path.join(require(path.join(__dirname,\"package.json\")).location,\"kernel.asar\"));");

         const package_start = "{\"name\":\"kernel\",\"main\":\"index.js\",\"location\":\"";
         const package_end = "\"}";

         var package_json = try allocator.alloc(u8, package_start.len + kernel_path.len + package_end.len);
         mem.copy(u8, package_json[0..], package_start);
         mem.copy(u8, package_json[package_start.len..], kernel_path);
         mem.copy(u8, package_json[package_start.len+kernel_path.len..], package_end);

         try package.writeAll(package_json);
      }
   }
   exit();
}

pub fn invalidAppDir() void {
   debug.print("Invalid Electron app directory.\n", .{});
   exit();
}

pub fn alreadyInjected() void {
   debug.print("Something is already injected there.\n", .{});
   exit();
}

pub fn appRunning() void {
   debug.print("The app is running, close it before injecting.\n", .{});
   exit();
}

pub fn exit() void {
   if (timer) |t| {
      const end_time = t.read();
      debug.print("Done in: {d}\n", .{ std.fmt.fmtDuration(end_time) });
   }
   std.os.exit(0);
}
