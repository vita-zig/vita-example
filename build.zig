const std = @import("std");
const Vita = @import("vita").Vita;

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});

    const vita = Vita.init(b, b.dependency("vita", .{}));

    const package = vita.addPackage(.{
        .name = "example",
        .title_id = "VSDK01337",
        .version = try .parse("1.0.0"),
        .parental_level = 1,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });
    package.linkSystemModule(.SceLibKernel);
    package.linkSystemModule(.SceSysmem);
    package.linkSystemModule(.SceIofilemgr);
    package.linkSystemModule(.SceDisplay);
    // package.linkSystemModule(.SceDisplayUser);
    package.linkSystemModule(.SceRtc);
    package.linkSystemModule(.SceNet);
    package.linkSystemModule(.SceProcessmgr);
    package.linkSystemModule(.SceKernelThreadMgr);
    // package.linkSystemModule(.SceThreadmgrCoredumpTime);

    package.installVpk(b);
    package.installSelf(b);
    package.installVelf(b);

    const exe_mod = package.root_module;

    // exe_mod.addIncludePath(b.path("vitasdk/arm-vita-eabi/include"));
    exe_mod.addIncludePath(b.path("vitasdk/share/gcc-arm-vita-eabi/samples/common"));
    exe_mod.addLibraryPath(b.path("vitasdk/arm-vita-eabi/lib"));
    exe_mod.addObjectFile(b.path("vitasdk/arm-vita-eabi/lib/crt0.o"));
    exe_mod.addObjectFile(b.path("vitasdk/lib/gcc/arm-vita-eabi/10.3.0/crti.o"));
    exe_mod.addObjectFile(b.path("vitasdk/lib/gcc/arm-vita-eabi/10.3.0/crtn.o"));
    // exe_mod.addObjectFile(b.path("vitasdk/arm-vita-eabi/lib/libg.a"));
    exe_mod.addObjectFile(b.path("vitasdk/arm-vita-eabi/lib/libc.a"));
    exe_mod.addObjectFile(b.path("vitasdk/arm-vita-eabi/lib/libm.a"));
    // exe_mod.linkSystemLibrary("SceLibKernel_stub", .{});
    // exe_mod.linkSystemLibrary("SceDisplay_stub", .{});
    // exe_mod.linkSystemLibrary("SceSysmem_stub", .{});
    // exe_mod.linkSystemLibrary("SceIofilemgr_stub", .{});
    // exe_mod.linkSystemLibrary("SceKernelThreadMgr_stub", .{});
    // ???
    // exe_mod.linkSystemLibrary("SceRtc_stub", .{});
    // exe_mod.linkSystemLibrary("SceNet_stub", .{});
    // exe_mod.linkSystemLibrary("SceProcessmgr_stub", .{});

    // exe_mod.addIncludePath(b.path("sdl2/include"));
    // exe_mod.addObjectFile(b.path("sdl2/lib/libSDL2.a"));
    // exe_mod.linkSystemLibrary("SceGxm_stub", .{});
    // exe_mod.linkSystemLibrary("SceTouch_stub", .{});
    // exe_mod.linkSystemLibrary("SceHid_stub", .{});
    // exe_mod.linkSystemLibrary("SceAudio_stub", .{});
    // exe_mod.linkSystemLibrary("SceAudioIn_stub", .{});
    // exe_mod.linkSystemLibrary("SceMotion_stub", .{});
    // exe_mod.linkSystemLibrary("SceCtrl_stub", .{});
    // exe_mod.linkSystemLibrary("SceIme_stub", .{});
    // exe_mod.linkSystemLibrary("SceCommonDialog_stub", .{});
    // exe_mod.linkSystemLibrary("SceAppUtil_stub", .{});

    // // DVUI
    // const dvui = dvui_dep.module("dvui_sdl2");
    // const dvui_sdl = dvui.import_table.getEntry("backend").?.value_ptr.*;
    // dvui_sdl.addIncludePath(b.path("sdl2/include"));
    // dvui.addIncludePath(b.path("freetype/include/freetype2"));
    // exe_mod.addImport("dvui", dvui);

    exe_mod.addCSourceFile(.{ .file = b.path("vitasdk/share/gcc-arm-vita-eabi/samples/common/debugScreen.c"), .flags = &.{"-D__vita__"} });
    // exe_mod.addCSourceFile(.{ .file = b.path("vitasdk/share/gcc-arm-vita-eabi/samples/hello_world/src/main.c"), .flags = &.{"-D__vita__"} });
    // exe_mod.addObjectFile(b.path("vitasdk/share/gcc-arm-vita-eabi/samples/hello_world/libhello_cpp_world.a"));

    const exe = package.artifact;

    // exe.addObject(SceLibKernel);
    b.installArtifact(exe);
    exe_mod.strip = false;
    // exe_mod.single_threaded = true;
    // exe.link_emit_relocs = false;
    // exe.pie = true;
    exe.image_base = 0x80000000;
    // exe_mod.code_model = .small;

    const libc_step = Vita.GenerateLibcFile.create(b, "vita_libc");
    libc_step.setInclueDir(b.path("vitasdk/arm-vita-eabi/includez/"));
    libc_step.setSysInclueDir(b.path("vitasdk/arm-vita-eabi/include/"));
    libc_step.setCrtDir(b.path("vitasdk/arm-vita-eabi/lib"));
    libc_step.setGccDir(b.path("vitasdk/lib/gcc/arm-vita-eabi/10.3.0"));
    exe.setLibCFile(libc_step.getLibcFile());

    // exe.link_function_sections = true;
    exe_mod.link_libc = true;
    exe.setLinkerScript(b.path("vita.ld"));
    exe.link_emit_relocs = false;
    // exe.verbose_link = true;

    b.getInstallStep().dependOn(&b.addInstallFile(package.velf, "bin/vita_example.velf").step);
    b.getInstallStep().dependOn(&b.addInstallFile(package.self, "bin/eboot.bin").step);
    b.getInstallStep().dependOn(&b.addInstallFile(package.vpk, "bin/vita_example.vpk").step);
    b.installArtifact(exe);

    // -a sce_sys/icon0.png=sce_sys/icon0.png \
    // -a sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png \
    // -a sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png \
    // -a sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml \
}
