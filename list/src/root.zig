//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const Item = struct {
    value: i32,
    name: []const u8 = undefined,
};

pub const List = struct {
    gpa: std.mem.Allocator = undefined,
    items: std.ArrayList(Item) = undefined,

    pub fn init(gpa: std.mem.Allocator) List {
        return List{ .gpa = gpa, .items = std.ArrayList(Item).empty };
    }

    pub fn add(self: *List, item: Item) !void {
        try self.items.append(self.gpa, item);
    }

    pub fn deinit(self: *List) void {
        self.items.deinit(self.gpa);
    }
};

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    //

    const use_aloc: comptime_int = 0;

    const alloc: std.mem.Allocator =
        switch (use_aloc) {
            1 => {
                const gpa: std.heap.DebugAllocator(.{}) = .init;
                defer gpa.deinit();
                return gpa.allocator();
            },
            else => std.heap.page_allocator,
        };

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var list = List.init(alloc);
    defer list.deinit();
    try list.add(Item{ .value = 3 });

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
