const clap = @import("clap");
const std = @import("std");

/// Injection state, regarding found folders.
pub const InjectState = packed struct {
   found_app_folder: bool = false,
   found_app_asar: bool = false,
   found_app_original_asar: bool = false,
   found_app_original_folder: bool = false,
};

pub fn main() !u8 {
   const stdOut = std.io.getStdOut();
   const allocator = std.heap.c_allocator;
   const params = comptime clap.parseParamsComptime(
      \\-h, --help Display this help and exit.
      \\-i, --inject <str> The path to the Electron application.
      \\-u, --uninject <str> The path to the Electron application.
      \\-k, --kernel <str> The path to the folder of your Kernel distribution, if not present the CWD will be used.
      \\
   );

   var clap_diag: clap.Diagnostic = .{};
   var clapped = clap.parse(clap.Help, &params, clap.parsers.default, .{
      .diagnostic = &clap_diag,
   }) catch |err| {
      clap_diag.report(std.io.getStdErr().writer(), err) catch unreachable;
      return 1;
   };
   defer clapped.deinit();

   var cwd_buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
   var kernel_path = clapped.args.inject orelse try std.os.getcwd(&cwd_buf);

   if (clapped.args.inject) |*inject_path| {
      try stdOut.writeAll("Attempting to inject Kernel...\n");

      inject_path.* = try std.fs.path.resolve(allocator, &[_][]const u8{ inject_path.* });
      defer allocator.free(inject_path.*);
      kernel_path = try std.fs.path.resolve(allocator, &[_][]const u8{ kernel_path });
      defer allocator.free(kernel_path);

      var app_dir = try std.fs.openDirAbsolute(inject_path.*, .{ .iterate = true });
      defer app_dir.close();

      var resources_dir: ?std.fs.Dir = null;
      var app_it = app_dir.iterate();
      while (app_it.next() catch {
         try stdOut.writeAll("Failed to iterate through the application directory, quitting.\n");
         return 1;
      }) |entry| {
         if (!std.mem.eql(u8, "resources", entry.name)) continue;

         resources_dir = try app_dir.openDir(entry.name, .{ .iterate = true });
         break;
      }

      var res_dir = resources_dir orelse {
         try stdOut.writeAll(
            "The provided injection path does not appear to be for an Electron application.\n"
         );
         return 1;
      };
      defer res_dir.close();

      try stdOut.writeAll("Probing resources folder...\n");
      var state: InjectState = .{};
      var res_it = res_dir.iterate();
      while (res_it.next() catch {
         try stdOut.writeAll("Failed to iterate through the resources directory, quitting.\n");
         return 1;
      }) |entry| {
         // Can't switch on non-comptime prongs, e.g switch (true) {...} isn't possible.
         if (std.mem.eql(u8, "app", entry.name)) {
            state.found_app_folder = true;
         } else if (std.mem.eql(u8, "app.asar", entry.name)) {
            state.found_app_asar = true;
         } else if (std.mem.eql(u8, "app-original", entry.name)) {
            state.found_app_original_folder = true;
         } else if (std.mem.eql(u8, "app-original.asar", entry.name)) {
            state.found_app_original_asar = true;
         }
      }

      if (state.found_app_original_asar or state.found_app_original_folder) {
         try stdOut.writeAll(
            "Found an existing injection, quitting.\n"
         );
         return 1;
      }
      try stdOut.writeAll("Found no existing injection, proceeding with detecting an ASAR.\n");

      if (state.found_app_asar) {
         try stdOut.writeAll("Found an ASAR file, renaming.\n");

         res_dir.rename("app.asar", "app-original.asar") catch {
            try cannotModifyResource(stdOut);
            return 1;
         };
      } else if (state.found_app_folder) {
         try stdOut.writeAll("Did not find an ASAR file, but found appropriate folder, renaming.\n");

         res_dir.rename("app", "app-original") catch {
            try cannotModifyResource(stdOut);
            return 1;
         };
      } else {
         try stdOut.writeAll("Did not find an ASAR or appropriate folder, quitting.\n");
         return 1;
      }

      try stdOut.writeAll("Creating injection files...\n");

      try res_dir.makeDir("app");

      var inject_files_dir = try res_dir.openDir("app", .{});
      defer inject_files_dir.close();

      var index_js = inject_files_dir.createFile("index.js", .{}) catch {
         try cannotModifyResource(stdOut);
         return 1;
      };
      defer index_js.close();
      var package_json = inject_files_dir.createFile("package.json", .{}) catch {
         try cannotModifyResource(stdOut);
         return 1;
      };
      defer package_json.close();

      try index_js.writeAll(@embedFile("./index.js"));

      var package_json_text = try std.mem.join(
         allocator, "",
         &[_][]const u8{ "{\"main\":\"index.js\",\"location\":\"", kernel_path, "\"}" }
      );
      defer allocator.free(package_json_text);

      for (package_json_text) |ch, i| if (ch == '\\') {
         package_json_text[i] = '/';
      };
      try package_json.writeAll(package_json_text);

      try stdOut.writeAll("Successfully injected Kernel.\n");

      return 0;
   }

   try clap.help(stdOut.writer(), clap.Help, comptime &params, .{});

   return 0;
}

inline fn cannotModifyResource(writer: anytype) !void {
   return writer.writeAll(
      "The target application may still be open, or you don't have permission to modify the files. Quitting.\n"
   );
}
