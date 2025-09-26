const std = @import("std");

pub const Item = struct {
    id: u32,
    name: []const u8,
    price: f32,
};

const toString = fn (*Item) []const u8;

pub fn justName(item: *Item) []const u8 {
    var buffer: [1024]u8 = undefined;
    return std.fmt.bufPrint(&buffer, "My name is {s}", .{item.name}) catch unreachable;
}

pub fn nameAndAge(item: *Item) []const u8 {
    var buffer: [1024]u8 = undefined;
    return std.fmt.bufPrint(&buffer, "{s} is {} years old", .{ item.name, item.price }) catch unreachable;
}

pub fn callOn(item: *Item, funct: toString) []const u8 {
    return funct(item);
}
