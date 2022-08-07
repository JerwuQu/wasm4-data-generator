const std = @import("std");

pub const DataGenerator = fn get(buf: []u8) usize;

// TODO: When LEB128 length is greater than 8, it's more optimal to use f64
//  problem is, zigs default float serializer does not keep nan payload.
//  Furthermore, the LLVM parsing of floats is different from WAT.
//  https://github.com/llvm/llvm-project/blob/f28c006a5895fc0e329fe15fead81e37457cb1d1/llvm/lib/Support/APFloat.cpp#L2830
//  Keeping code below:
//
// break :blk std.fmt.comptimePrint(
//     \\local.get %[ptr]
//     \\f64.const {s}
//     \\f64.store {d}
// , .{ @bitCast(f64, num), i * 8});
//
// fn lebLength(n: u64) usize {
//     var num = n;
//     var len: usize = 1;
//     while (num > 0x7f) {
//         num >>= 7;
//         len += 1;
//     }
//     return len;
// }

pub fn create(comptime data: []const u8) DataGenerator {
    const numCount = if (data.len % 8 == 0) data.len / 8 else data.len / 8 + 1;
    comptime var nums: [numCount]u64 = [_]u64{0} ** numCount;
    for (data) |char, i| {
        nums[i / 8] |= @intCast(u64, char) << (i % 8) * 8;
    }
    return struct {
        pub fn get(buf: []u8) usize {
            inline for (nums) |num, i| {
                asm volatile (
                    \\local.get %[ptr]
                    \\i64.const %[value]
                    \\i64.store %[offset]
                    :
                    : [value] "n" (num),
                      [offset] "n" (i * 8),
                      [ptr] "r" (buf.ptr),
                );
            }
            return data.len;
        }
    }.get;
}
