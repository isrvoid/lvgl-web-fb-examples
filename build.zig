const std = @import("std");
const bl = @import("lvgl-wasm/build_webfb_gui.zig");

pub fn build(b: *std.Build) !void {
    bl.addWebfbGui(b, .{ .name = "one_channel", .src_dir = "one-channel-psu" });
}
