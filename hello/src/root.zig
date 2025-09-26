//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const p = @import("person.zig");
const i = @import("data/item.zig");

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    const aloc = std.heap.page_allocator;

    var person = p.Person.init(aloc, "Thiago", 20);
    defer person.deinit(aloc);

    try person.itens.append(
        aloc,
        i.Item{
            .id = 1,
            .name = "Zig",
            .price = 10.0,
        },
    );
    try person.itens.append(
        aloc,
        i.Item{
            .id = 1,
            .name = "Price",
            .price = 20.0,
        },
    );

    try person.itens.append(
        aloc,
        i.Item{
            .id = 1,
            .name = "Next",
            .price = 20.0,
        },
    );
    try stdout.print("{s}\n", .{""});

    try stdout.print("{s}\n", .{callOnPerson(&person, justName)});
    try stdout.print("{s}\n", .{callOnPerson(&person, nameAndAge)});
    try stdout.flush(); // Don't forget to flush!

}

const toString = fn (*p.Person) []const u8;

fn justName(person: *p.Person) []const u8 {
    var buffer: [1024]u8 = undefined;
    return std.fmt.bufPrint(&buffer, "My name is {s}\n", .{person.name}) catch unreachable;
}

fn nameAndAge(person: *p.Person) []const u8 {
    var result: [1024]u8 = undefined;
    var buffer: [1024]u8 = undefined;

    var pos: usize = 0;

    for (person.itens.items) |item| {
        const txt = std.fmt.bufPrint(&buffer, "Item {s}, price {} \n", .{ item.name, item.price }) catch unreachable;
        @memcpy(result[pos .. pos + txt.len], txt);
        pos += txt.len;
    }

    const txt2 = std.fmt.bufPrint(&buffer, "{s} is {} years old", .{ person.name, person.age }) catch unreachable;
    @memcpy(result[pos .. pos + txt2.len], txt2);
    pos += txt2.len;

    return result[0..pos];
}

fn callOnPerson(person: *p.Person, funct: toString) []const u8 {
    return funct(person);
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
