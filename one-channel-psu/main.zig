const std = @import("std");
const c = @cImport({
    @cInclude("psu_emu.h");
});

var prng = std.rand.DefaultPrng.init(42);
const rand = prng.random();

export fn rand_norm() f32 {
    return rand.floatNorm(f32);
}

pub fn main() void {
}
