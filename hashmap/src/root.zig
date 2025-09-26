//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const Point = struct {x: i32, y: i32};

const printFn = fn(anytype, comptime []const u8, anytype) anyerror!void;

pub fn printItens(map: *std.AutoHashMap(u32, Point), stdout:anytype, print: *const printFn) !void {
    var iter = map.iterator();
    while(iter.next()) |entry| {
        const look = entry.value_ptr;
        try print(stdout, "x:{} / y:{}\n", .{look.x, look.y});
    }
}

//first arg is a std.io.Writer
fn stdoutPrint(stdout:anytype, comptime fmt:[]const u8, args:anytype) anyerror!void {
    comptime try std.testing.expectEqual(@TypeOf(stdout), *std.Io.Writer);
    try stdout.print(fmt, args);
}


const TestBuffer = struct{
    len:usize, 
    buf: []u8, 
};

//first arg is a TestBuffer
fn memoryPrint(buffer:anytype, comptime fmt:[]const u8, args:anytype) anyerror!void {
    comptime try std.testing.expectEqual(@TypeOf(buffer), *TestBuffer);

    var buf: [1024]u8 = undefined;
    const txt = try std.fmt.bufPrint(&buf, fmt, args);
    const clen = buffer.len;
    @memcpy(buffer.buf[clen .. clen + txt.len], txt);
    buffer.len = clen + txt.len;
}


pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    var stdout = &stdout_writer.interface;

    const aloc = std.heap.page_allocator;

    var map = std.AutoHashMap(u32, Point).init(aloc);
    defer map.deinit();

    try map.put(1234, .{.x = 1, .y = 4});
    try map.put(1232, .{.x = 5, .y = 2});

    
    const look = map.get(1234) orelse unreachable;

    try stdout.print("x:{} / y:{}\n", .{look.x, look.y});

    var i:i32 = 0;
    while(i < 1000){
        try printItens(&map, stdout, &stdoutPrint);
        i = i+1;
    }
    try stdout.flush(); // Don't forget to flush!
}



test "print itens happy path" {
    const aloc = std.testing.allocator;
    var map = std.AutoHashMap(u32, Point).init(aloc);
    defer map.deinit();

    try map.put(1234, .{.x = 1, .y = 4});
    try map.put(1232, .{.x = 5, .y = 2});

    var buffer:[1024]u8 = undefined;
    var buf = TestBuffer{ .len = 0, .buf = &buffer };
    try printItens(&map, &buf, &memoryPrint);

    try std.testing.expectEqual(std.mem.indexOf(u8, &buffer, "x:"), 0);
    try std.testing.expectEqual(std.mem.indexOf(u8, &buffer, "y:2"), 16);
}

