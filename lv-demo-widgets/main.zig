const std = @import("std");

const webfb = @import("webfb");
const Server = webfb.Server;
const ListContent = webfb.content.ListContent;

pub fn main() !void {
    server.instance = try initServer();
    defer server.instance.deinit();
    while (true) {
        try handleConnections();
        std.time.sleep(1e6);
    }
}

fn initServer() !Server {
    const files = @import("web_files");
    const content_entries = &[_]ListContent.Entry{
        .{ .name = "index.html", .cont = files.index, .cont_type = .html },
        .{ .name = "webfb.js", .cont = files.webfb_js, .cont_type = .javascript },
        .{ .name = "webfb.wasm", .cont = files.demo_widgets, .cont_type = .webassembly },
    };
    server.content = ListContent{ .entries = content_entries };
    return try Server.init(8080, server.content.content(), &server.request_buf);
}

var server = struct {
    instance: Server = undefined,
    request_buf: [0x400]u8 = undefined,
    content: ListContent = undefined,
}{};

fn handleConnections() !void {
    const res = try server.instance.step();
    if (res) |socket|
        // Normally, we would add the new client socket to a list. The demo doesn't transmit remote values.
        // To simplify: omit client management and close the WebSocket connection.
        try closeWebSocket(socket);
}

fn closeWebSocket(socket: std.os.socket_t) !void {
    var buf: [0x100]u8 = undefined;
    var ws = webfb.WebSocket.init(socket, &buf);
    while (!try ws.closeStep())
        std.time.sleep(1e6);
}
