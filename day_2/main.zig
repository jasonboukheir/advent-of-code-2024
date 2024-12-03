const std = @import("std");
const input = @embedFile("input.txt");
const split = std.mem.splitSequence;
const parseInt = std.fmt.parseInt;
const stdout = std.io.getStdOut().writer();
const Allocator = std.mem.Allocator;
const DelimiterType = std.mem.DelimiterType;
const SplitIterator = std.mem.SplitIterator;

const Direction = enum(u4) {
    none,
    ascending,
    descending,
};

pub fn skipSequence(
    comptime T: type,
    skip_index: usize,
    iter: SplitIterator(T, DelimiterType.sequence),
) SkipIterator(T, DelimiterType.sequence) {
    return .{
        .iter = iter,
        .skip_index = skip_index,
        .index = 0,
    };
}

pub fn SkipIterator(comptime T: type, comptime delimiter_type: DelimiterType) type {
    return struct {
        iter: SplitIterator(T, delimiter_type),
        skip_index: usize,
        index: usize,

        const Self = @This();

        pub fn next(self: *Self) ?[]const T {
            if (self.index == self.skip_index) {
                _ = self.iter.next();
            }
            self.index += 1;
            return self.iter.next();
        }

        pub fn reset(self: *Self) void {
            self.iter.index = 0;
            self.index = 0;
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    // const allocator = arena.allocator();

    var lines = split(u8, input, "\n");

    var safe_count: i32 = 0;
    while (lines.next()) |line| {
        if (check_dampened_level(line)) {
            safe_count += 1;
        } else {
            try stdout.print("'{s}' NO\n", .{line});
        }
    }

    try stdout.print("Safe Count: {d}\n", .{safe_count});

    const line: []const u8 = "1 2 3 4 5";
    for (0..(5 + 1)) |i| {
        try stdout.print("Skipping Index {d}:", .{i});
        var skip = skipSequence(u8, i, split(u8, line, " "));
        while (skip.next()) |s| {
            try stdout.print(" {s}", .{s});
        }
        try stdout.print("\n", .{});
    }
}

fn check_level(line: []const u8) bool {
    var levels = split(u8, line, " ");
    var direction = Direction.none;
    const prev_level_str = levels.next();
    if (prev_level_str == null) {
        return false;
    }
    var prev_level = parseInt(i32, prev_level_str.?, 10) catch return false;
    while (levels.next()) |level_str| {
        const level = parseInt(i32, level_str, 10) catch continue;
        const d = level - prev_level;
        if (d == 0 or d < -3 or d > 3) return false;

        switch (direction) {
            Direction.none => {
                if (d < 0) {
                    direction = Direction.descending;
                } else {
                    direction = Direction.ascending;
                }
            },
            Direction.ascending => {
                if (d < 0) return false;
            },
            Direction.descending => {
                if (d > 0) return false;
            },
        }
        prev_level = level;
    }
    return true;
}

fn check_dampened_level(line: []const u8) bool {
    if (line.len <= 1) return false;

    var levels = split(u8, line, " ");
    var level_count: usize = 0;
    while (levels.next()) |_| {
        level_count += 1;
    }
    levels.reset();
    if (level_count <= 2) return true;

    for (0..(level_count + 1)) |skip_index| {
        if (check_skipped_dampen_level(skipSequence(u8, skip_index, levels))) {
            return true;
        }
    }
    return false;
}

fn check_skipped_dampen_level(skip: SkipIterator(u8, DelimiterType.sequence)) bool {
    var skip_levels = skip;
    var direction = Direction.none;
    const prev_level_str = skip_levels.next();
    if (prev_level_str == null) {
        return false;
    }
    var prev_level = parseInt(i32, prev_level_str.?, 10) catch return false;
    while (skip_levels.next()) |level_str| {
        const level = parseInt(i32, level_str, 10) catch return false;
        const d = level - prev_level;
        if (d == 0 or d < -3 or d > 3) return false;

        switch (direction) {
            Direction.none => {
                if (d < 0) {
                    direction = Direction.descending;
                } else {
                    direction = Direction.ascending;
                }
            },
            Direction.ascending => {
                if (d < 0) return false;
            },
            Direction.descending => {
                if (d > 0) return false;
            },
        }
        prev_level = level;
    }
    return true;
}
