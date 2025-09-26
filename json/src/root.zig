//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const Place = struct { lat: f32, long: f32, others: []*Place };

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const aloc = std.heap.page_allocator;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    const json = "{ \"lat\": 37.826, \"long\": -122.423, \"others\":[{\"lat\": 7.826, \"long\": 2.423,\"others\": []}] }";

    const parsed = try std.json.parseFromSlice(Place, aloc, json, .{});
    defer parsed.deinit();

    const place = parsed.value;

    try stdout.print("Lat: {}, Long: {}.\n", .{ place.lat, place.long });

    for (place.others) |other| {
        try stdout.print("Others: Lat: {}, Long: {}.\n", .{ other.lat, other.long });
    }

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
