const std = @import("std");
const input = @embedFile("input.txt");
const testing = std.testing;

const split = std.mem.split;
const stdout = std.io.getStdOut().writer();
const assert = std.debug.assert;

const WordSearchGrid = struct { grid: []const u8, row_count: usize, col_count: usize };

pub fn count_rows_colums(text: []const u8, needle: []const u8) !.{usize, usize} {
    const row_count = std.mem.count(u8, text, "")
}

pub fn convert_to_grid(comptime text: []const u8) !WordSearchGrid {
    const row_count = comptime std.mem.count(u8, text, "\n") + 1;
    const col_count = comptime if (std.mem.indexOf(u8, text, "\n")) |c| c else 0;
    var grid = std.mem.zeroes([row_count * col_count]u8);
    try stdout.print("GRID\n", .{});
    for (0..row_count) |r| {
        for (0..col_count) |c| {
            grid[r * col_count + c] = text[r * (col_count + 1) + c];
        }
        try stdout.print("{s}\n", .{grid[r * col_count .. (r + 1) * col_count]});
    }
    return .{ .grid = grid[0..grid.len], .row_count = row_count, .col_count = col_count };
}

const pattern = "XMAS";
const rpattern = "SAMX";

test "example 1" {
    const text = @embedFile("example_1.txt");
    const wordSearch = try convert_to_grid(text);
    assert(wordSearch.grid.len == wordSearch.row_count * wordSearch.col_count);
    try stdout.print("rows: {d}, cols: {d}\n", .{ wordSearch.row_count, wordSearch.col_count });
    try stdout.print("{s}\n", .{wordSearch.grid[0..wordSearch.grid.len]});
    const actual = try countPatterns(wordSearch);
    const expected = 18;
    try testing.expectEqual(expected, actual);
}

pub fn countPatterns(wordSearch: WordSearchGrid) !u32 {
    var total: u32 = 0;
    const grid = wordSearch.grid;
    const row_count = wordSearch.row_count;
    const col_count = wordSearch.col_count;

    // HORIZONTAL
    for (0..row_count) |r| {
        for (0..col_count - pattern.len) |c| {
            const start = r * col_count + c;
            const end = start + pattern.len;
            try stdout.print("{s}\n", .{grid[start..end]});
            if (std.mem.eql(u8, pattern, grid[start..end])) {
                total += 1;
            }
            if (std.mem.eql(u8, rpattern, grid[start..end])) {
                total += 1;
            }
        }
    }

    var chars = [_]u8{0} ** pattern.len;

    // VERTICAL
    for (0..row_count - pattern.len) |r| {
        for (0..col_count) |c| {
            for (0..pattern.len) |i| {
                chars[i] = grid[(r + i) * col_count + c];
            }
            if (std.mem.eql(u8, pattern, @as([]const u8, &chars))) {
                total += 1;
            }
            if (std.mem.eql(u8, rpattern, @as([]const u8, &chars))) {
                total += 1;
            }
        }
    }

    // DIAGONALS
    for (0..row_count - pattern.len) |r| {
        for (0..col_count - pattern.len) |c| {
            for (0..pattern.len) |i| {
                chars[i] = grid[(r + i) * col_count + c + i];
            }
            if (std.mem.eql(u8, pattern, @as([]const u8, &chars))) {
                total += 1;
            }
            if (std.mem.eql(u8, rpattern, @as([]const u8, &chars))) {
                total += 1;
            }

            for (0..pattern.len) |i| {
                chars[i] = grid[(r + i + 1) * col_count - c - i - 1];
            }
            if (std.mem.eql(u8, pattern, @as([]const u8, &chars))) {
                total += 1;
            }
            if (std.mem.eql(u8, rpattern, @as([]const u8, &chars))) {
                total += 1;
            }
        }
    }
    return total;
}

pub fn main() !void {
    const total = try countPatterns(try convert_to_grid(input));
    try stdout.print("Total: {d}\n", .{total});
}
