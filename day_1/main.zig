const std = @import("std");
const input = @embedFile("input.txt");
const split = std.mem.split;
const assert = std.debug.assert;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdout = std.io.getStdOut().writer();
    var lines = split(u8, input, "\n");

    var list1 = std.ArrayList(i32).init(allocator);
    var list2 = std.ArrayList(i32).init(allocator);

    while (lines.next()) |line| {
        var cols = split(u8, line, "   ");
        const col1 = cols.next();
        const col2 = cols.next();
        if (col1 != null and col2 != null) {
            const li1 = try std.fmt.parseInt(i32, col1.?, 10);
            const li2 = try std.fmt.parseInt(i32, col2.?, 10);
            try list1.append(li1);
            try list2.append(li2);
        }
    }
    assert(list1.items.len == list2.items.len);

    std.mem.sort(i32, list1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list2.items, {}, comptime std.sort.asc(i32));

    var total_diff: i32 = 0;
    for (0..list1.items.len) |i| {
        const diff = list1.items[i] - list2.items[i];
        if (diff >= 0) {
            total_diff += diff;
        } else {
            total_diff -= diff;
        }
    }

    var similarity_score: i32 = 0;
    var j: u32 = 0;
    for (0..list1.items.len) |i| {
        const val = list1.items[i];
        while (j < list2.items.len and list2.items[j] < val) {
            j += 1;
        }
        var count: i32 = 0;
        while (j < list2.items.len and list2.items[j] == val) {
            count += 1;
            j += 1;
        }
        similarity_score += val * count;
    }

    try stdout.print("List length: {d}\n", .{list1.items.len});
    try stdout.print("Total Difference: {d}\n", .{total_diff});
    try stdout.print("Similarity Score: {d}\n", .{similarity_score});
}
