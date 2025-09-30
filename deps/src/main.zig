const std = @import("std");
const deps = @import("deps");
const zbench = @import("zbench");

pub fn addx(a: i32, b: i32) i32 {
    return a + b;
}

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    try deps.bufferedPrint();

    var stdout = std.fs.File.stdout().writerStreaming(&.{});
    const writer = &stdout.interface;
    const alloc = std.heap.page_allocator;

    var bench = zbench.Benchmark.init(alloc, .{});
    defer bench.deinit();

    try bench.add("My Benchmark FP", benchFP, .{});
    try bench.add("My Benchmark Static", benchS, .{});

    try writer.writeAll("\n");
    try bench.run(writer);
}

const Adder = *const fn (i32, i32) i32;

pub fn benchFP(_: std.mem.Allocator) void {
    const self = MyBenchFP.init(&addx);
    for (0..500) |_| {
        _ = self.add(45, 55);
    }
}

const MyBenchFP = struct {
    addf: Adder,

    fn init(comptime addfn: Adder) @This() {
        return .{ .addf = addfn };
    }

    fn add(self: @This(), a: i32, b: i32) i32 {
        return self.addf(a, b);
    }
};

pub fn benchS(_: std.mem.Allocator) void {
    const self = MyBenchS.init();
    for (0..500) |_| {
        _ = self.add(45, 55);
    }
}

const MyBenchS = struct {
    fn init() @This() {
        return .{};
    }

    fn addx(_: @This(), a: i32, b: i32) i32 {
        return a + b;
    }

    pub fn add(self: @This(), a: i32, b: i32) i32 {
        return self.addx(a, b);
    }
};

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
