const std = @import("std");
const deps = @import("deps");
const zbench = @import("zbench");

pub fn addx(a:i32, b:i32) i32{
    return a + b;
}

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    try deps.bufferedPrint();

    var stdout = std.fs.File.stdout().writerStreaming(&.{});
    const writer = &stdout.interface;
    const alloc = std.heap.page_allocator;
    
//    const fmem = try aloc.alloc(Adder, 1);
//    defer aloc.free(fmem);
//    fmem = addx;

    var bench = zbench.Benchmark.init(alloc, .{});
    defer bench.deinit();

//    const mfp =  MyBenchFP.init(addx);
//    mfp.run(std.heap.page_allocator);

    try bench.addParam("My Benchmark Static", &MyBenchS.init(), .{});
    try bench.addParam("My Benchmark FP", &MyBenchFP.init(addx), .{});

    try writer.writeAll("\n");
    try bench.run(writer);
}

const Adder = fn(i32,i32) i32;


const MyBenchS = struct {
    fn init() @This() {
        return .{};
    }

    pub fn add(_: @This(), a:i32, b:i32) i32{
        return a + b;
    }

    pub fn run (self: @This(), _: std.mem.Allocator) void {
        for (0..1000) |_| {
            _ = self.add(45, 55);
        }
    }
};

const MyBenchFP = struct {
    addf:*const Adder,

    fn init(addfn: *const Adder) @This() {
        return .{.addf = addfn};
    }
    
    pub fn add(self: @This(), a:i32, b:i32) i32{
        const f = self.addf;
        return f(a,b);
    }

    pub fn run (self:@This(), _: std.mem.Allocator) void {
        for (0..1000) |_| {
            _ = self.add(45, 55);
        }

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
