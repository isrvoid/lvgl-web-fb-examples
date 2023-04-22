const std = @import("std");
const bwg = @import("lvgl-wasm/build_webfb_gui.zig");

var target: std.zig.CrossTarget = undefined;
var optimize: std.builtin.OptimizeMode = undefined;

pub fn build(b: *std.Build) void {
    target = b.standardTargetOptions(.{});
    optimize = b.standardOptimizeOption(.{});

    addOneChannelPsu(b);
    addDemoWidgets(b);
}

fn addOneChannelPsu(b: *std.Build) void {
    const dir = "one-channel-psu/";
    const gui = bwg.addWebfbGui(b, .{ .name = "one_channel", .src_dir = dir ++ "gui" });
    const install_gui = b.addInstallArtifact(gui); // GUI install step is exposed for later dependency
    b.getInstallStep().dependOn(&install_gui.step);
    const exe = b.addExecutable(.{
        .name = "psu",
        .root_source_file = .{ .path = dir ++ "main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addIncludePath(dir);
    exe.addCSourceFile(dir ++ "psu_emu.c", &.{});
    exe.linkLibC();
    exe.step.dependOn(&install_gui.step); // exe needs installed .wasm file to embed it
    exe.addAnonymousModule("web_files", .{ .source_file = .{ .path = "web_files.zig" } });
    exe.addAnonymousModule("webfb", .{ .source_file = .{ .path = "web-fb/src/modules.zig" } });
    b.installArtifact(exe);
}

fn addDemoWidgets(b: *std.Build) void {
    const dir = "lv-demo-widgets/";
    const gui = bwg.addWebfbGui(b, .{ .name = "demo_widgets", .src_dir = dir, .img_dir = dir ++ "images" });
    const install_gui = b.addInstallArtifact(gui);
    b.getInstallStep().dependOn(&install_gui.step);
    const exe = b.addExecutable(.{
        .name = "widgets",
        .root_source_file = .{ .path = dir ++ "main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.step.dependOn(&install_gui.step);
    exe.addAnonymousModule("web_files", .{ .source_file = .{ .path = "web_files.zig" } });
    exe.addAnonymousModule("webfb", .{ .source_file = .{ .path = "web-fb/src/modules.zig" } });
    b.installArtifact(exe);
}
