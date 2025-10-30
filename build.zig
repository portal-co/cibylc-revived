const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const elfutils_dependency = b.dependency("elfutils", .{
        .target = target,
        .optimize = optimize,
    });
    const libelf = elfutils_dependency.artifact("elf");
    const libdw = elfutils_dependency.artifact("dw");
    // const libasm = elfutils_dependency.artifact("asm");

    const sources = [_][]const u8{ "src/basicblock.cc", "src/builtins.cc", "src/calltablemethod.cc", "src/codeblock.cc", "src/controller.cc", "src/elf.cc", "src/emit.cc", "src/function.cc", "src/functioncolocation.cc", "src/instruction.cc", "src/javamethod.cc", "src/javaclass.cc", "src/mips.cc", "src/mips-dwarf.c", "src/registerallocator.cc", "src/string-instruction.cc", "src/syscall-wrappers.cc", "src/utils.cc" };
    const lib = b.addLibrary(.{
        .name = "selba-core",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            // .strip = false,
            // .pic = pic,
            .link_libc = true,
            .link_libcpp = true,
            .root_source_file = b.path("src/lib.zig"),
        }),
    });
    lib.root_module.linkLibrary(libelf);
    lib.root_module.linkLibrary(libdw);
    lib.root_module.addCSourceFiles(.{ .files = &sources });
    lib.root_module.addIncludePath(b.path("include"));
    b.installArtifact(lib);
    const exe = b.addExecutable(.{
        .name = "xcibyl-translator",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            // .strip = false,
            // .pic = pic,
            .link_libc = true,
        }),
    });
    exe.root_module.linkLibrary(lib);
    exe.root_module.linkLibrary(libelf);
    exe.root_module.linkLibrary(libdw);
    exe.root_module.addCSourceFiles(.{ .files = &[_][]const u8{"src/main.cc"} });
    exe.root_module.addIncludePath(b.path("include"));
    b.installArtifact(exe);
}
