const std = @import("std");
const bwg = @import("lvgl-wasm/build_webfb_gui.zig");

pub fn build(b: *std.Build) void {
    addOneChannelPsu(b);
    addDemoWidgets(b);
}

fn addOneChannelPsu(b: *std.Build) void {
    const dir = "one-channel-psu/";
    bwg.addWebfbGui(b, .{ .name = "one_channel", .src_dir = dir ++ "gui" });
    const exe = b.addExecutable(.{
        .name = "psu",
        .root_source_file = .{ .path = dir ++ "main.zig" },
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    exe.addIncludePath(dir);
    exe.addCSourceFile(dir ++ "psu_emu.c", &.{});
    exe.linkLibC();
    exe.addAnonymousModule("webfb", .{ .source_file = .{ .path = "web-fb/src/modules.zig" } });
    b.installArtifact(exe);
}

fn addDemoWidgets(b: *std.Build) void {
    bwg.addWebfbGui(b, .{ .name = "demo_widgets", .src_dir = "lv-demo-widgets", .img_dir = "lv-demo-widgets/images" });
}
