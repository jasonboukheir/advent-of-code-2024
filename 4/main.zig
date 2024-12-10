const std = @import("std");
const input = @embedFile("input.txt");

const split = std.mem.split;
const stdout = std.io.getStdOut().writer();
const assert = std.debug.assert;

const row_count = 140;
const col_count = 140;

pub fn convert_to_grid(comptime text: []const u8) [row_count * col_count]u8 {
    var result = std.mem.zeroes([row_count * col_count]u8);
    for (0..row_count) |r| {
        const start = r * (col_count + 1);
        const end = start + col_count;
        @memcpy(result[r * col_count .. (r + 1) * col_count], text[start..end]);
    }
    return result;
}

const grid = convert_to_grid(input);
const pattern = "XMAS";
const rpattern = "SAMX";

pub fn main() !void {
    var total: u32 = 0;

    // HORIZONTAL
    for (0..row_count) |r| {
        for (0..col_count - pattern.len) |c| {
            const start = r * col_count + c;
            const end = start + pattern.len;
            if (std.mem.eql(u8, pattern, grid[start..end])) {
                total += 1;
            }
            if (std.mem.eql(u8, rpattern, grid[start..end])) {
                total += 1;
            }
        }
    }

    try stdout.print("Total: {d}\n", .{total});
}
