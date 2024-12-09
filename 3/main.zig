const std = @import("std");
const input = @embedFile("input.txt");

const stdout = std.io.getStdOut().writer();

pub fn seqEq(text: []const u8, ptn: []const u8, start: usize) bool {
    for (0..ptn.len) |i| {
        if (text[start + i] != ptn[i]) {
            return false;
        }
    }
    return true;
}

pub fn findNextPtn(text: []const u8, start: usize, ptn: []const u8) ?usize {
    var index = start;
    const ptnLen = ptn.len;
    while (index + ptnLen < text.len and !seqEq(text, ptn, index)) {
        index += 1;
    }
    if (index >= text.len or index < 0) {
        return null;
    }
    return index;
}

pub fn parseDigit(text: []const u8, start: usize, max_len: usize, end_char: u8) ?struct { u32, usize } {
    var end = @min(text.len - 1, start + max_len);
    while (end > start) {
        const digits = text[start..end];
        if (std.fmt.parseUnsigned(u32, digits, 10)) |number| {
            if (text[end] == end_char) {
                return .{ number, end + 1 };
            } else {
                return null;
            }
        } else |_| {}
        end -= 1;
    }
    return null;
}

const DoDontIterator = struct {
    index: usize,
    do: bool,
    text: []const u8,

    const Self = @This();
    const DONT = "don't()";
    const DO = "do()";

    pub fn next(self: *Self) ?DoDontState {
        const ptn = if (self.do) DONT else DO;
        if (findNextPtn(self.text, self.index, ptn)) |ptnStart| {
            self.do = !self.do;
            self.index = ptnStart + ptn.len;
            return .{ .do = self.do, .index = ptnStart };
        } else {
            return null;
        }
    }

    pub fn reset(self: *Self) void {
        self.index = 0;
        self.do = true;
    }
};

const DoDontState = struct {
    do: bool,
    index: usize,
};

const MulExpressionIterator = struct {
    index: usize,
    text: []const u8,
    doDontIterator: DoDontIterator,
    prevDoDont: DoDontState,
    nextDoDont: ?DoDontState,

    const Self = @This();
    const MIN_SIZE = "mul(0,0)".len;

    pub fn next(self: *Self) ?u32 {
        if (self.index + MIN_SIZE >= self.text.len) {
            return null;
        }
        while (findNextPtn(self.text, self.index, "mul(")) |mIndex| {
            self.index = mIndex + "mul(".len;
            if (self.nextDoDont) |nextDoDont| {
                if (self.index > nextDoDont.index) {
                    self.prevDoDont = nextDoDont;
                    self.nextDoDont = self.doDontIterator.next();
                }
            }
            if (!self.prevDoDont.do) continue;
            if (parseDigit(self.text, self.index, 3, ',')) |lResult| {
                const left, self.index = lResult;
                if (parseDigit(self.text, self.index, 3, ')')) |rResult| {
                    const right, self.index = rResult;
                    return left * right;
                }
            }
        } else {
            return null;
        }
    }

    pub fn reset(self: *Self) void {
        self.index = 0;
    }
};

pub fn parseMulExpressions(text: []const u8) MulExpressionIterator {
    var doDontIterator: DoDontIterator = .{ .text = text, .index = 0, .do = true };
    const prevDoDont: DoDontState = .{ .do = true, .index = 0 };
    const nextDoDont: ?DoDontState = doDontIterator.next();

    return .{
        .text = text,
        .index = 0,
        .doDontIterator = doDontIterator,
        .prevDoDont = prevDoDont,
        .nextDoDont = nextDoDont,
    };
}

pub fn main() !void {
    var total: u32 = 0;
    var mul_expressions = parseMulExpressions(input);
    while (mul_expressions.next()) |product| {
        total += product;
    }

    try stdout.print("Total: {d}\n", .{total});
}
