const std = @import("std");

const webfb = @import("webfb");
const Server = webfb.Server;
const ListContent = webfb.content.DirContent; // FIXME
const c = @cImport({
    @cInclude("psu_emu.h");
});

var prng = std.rand.DefaultPrng.init(42);
const rand = prng.random();

export fn rand_norm() f32 {
    return rand.floatNorm(f32);
}

export fn mono_tick_us() u32 {
    return @truncate(u32, @bitCast(u64, std.time.microTimestamp()));
}

pub fn main() !void {
    var server = try initServer();
    defer server.deinit();
    while (true) {
        const res = try server.step();
        if (res) |socket|
            try closeWebSocket(socket); // FIXME

        std.time.sleep(1e6);
    }
}

fn initServer() !Server {
    server_data.cont = ListContent{ .dir = "web-fb/web-root" };
    return try Server.init(8080, server_data.cont.content(), &server_data.request_buf);
}

var server_data = struct {
    request_buf: [0x400]u8 = undefined,
    cont: ListContent = undefined,
}{};

// temp dummy
fn closeWebSocket(socket: std.os.socket_t) !void {
    var buf: [0x100]u8 = undefined;
    var ws = webfb.WebSocket.init(socket, &buf);
    while (!try ws.closeStep())
        std.time.sleep(1e6);
}
