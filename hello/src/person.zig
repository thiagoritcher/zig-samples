const std = @import("std");
const i = @import("data/item.zig");

pub const Person = struct {
    name: []const u8,
    age: u8,
    itens: std.ArrayList(i.Item),

    pub fn init(_: std.mem.Allocator, name: []const u8, age: u8) Person {
        const list = std.ArrayList(i.Item).empty;
        return Person{ .name = name, .age = age, .itens = list };
    }

    pub fn deinit(self: *Person, aloc: std.mem.Allocator) void {
        self.itens.deinit(aloc);
    }
};

const toString = fn (*Person) []const u8;

pub fn justName(person: *Person) []const u8 {
    var buffer: [1024]u8 = undefined;
    return std.fmt.bufPrint(&buffer, "My name is {s}", .{person.name}) catch unreachable;
}

pub fn nameAndAge(person: *Person) []const u8 {
    var buffer: [1024]u8 = undefined;
    return std.fmt.bufPrint(&buffer, "{s} is {} years old", .{ person.name, person.age }) catch unreachable;
}

pub fn callOnPerson(person: *Person, funct: toString) []const u8 {
    return funct(person);
}
