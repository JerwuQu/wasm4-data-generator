const std = @import("std");

fn leb128Length(n: u64) usize {
    var num = n;
    var len: usize = 1;
    while (num > 0x7f) {
        num >>= 7;
        len += 1;
    }
    return len;
}

pub fn create(comptime data: []const u8) fn ([]u8) usize {
    @setEvalBranchQuota(100000000);
    const numCount = if (data.len % 8 == 0) data.len / 8 else data.len / 8 + 1;
    comptime var nums: [numCount]u64 = [_]u64{0} ** numCount;
    for (data) |char, i| {
        nums[i / 8] |= @intCast(u64, char) << (i % 8) * 8;
    }
    return struct {
        pub fn get(buf: []u8) usize {
            inline for (nums) |num, i| {
                // When the byte length for LEB128 of our number is less than 8,
                // it's more efficient to use an i64 rather than a f64.
                // Also, we don't have support for NaNs with payload yet,
                // so we fall back on using i64 for those too for now.

                // TODO: reimplement f64
                // const fnum = @bitCast(f64, num);
                // if (comptime (leb128Length(num) < 8 or std.math.isNan(fnum))) {
                    asm volatile (
                        \\local.get %[ptr]
                        \\i64.const %[value]
                        \\i64.store %[offset]
                        :
                        : [ptr] "r" (buf.ptr),
                          [value] "n" (num),
                          [offset] "n" (i * 8),
                    );
                // } else {
                //     const asmStr = comptime std.fmt.comptimePrint(
                //         \\local.get %[ptr]
                //         \\f64.const {x}
                //         \\f64.store %[offset]
                //     , .{fnum});
                //     asm volatile (asmStr
                //         :
                //         : [ptr] "r" (buf.ptr),
                //           [offset] "n" (i * 8),
                //     );
                // }
            }
            return data.len;
        }
    }.get;
}
