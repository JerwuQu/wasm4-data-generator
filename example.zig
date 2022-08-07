const datagen = @import("datagen.zig");

extern fn tracef(x: [*:0]const u8, ...) void;

const testTextGen = datagen.create(@embedFile("testdata/text.txt"));
const testBinaryGen = datagen.create(@embedFile("testdata/binary.dat"));

export fn start() void {
    var gData: [256]u8 = undefined;

    tracef("# Text:");
    gData[testTextGen(&gData)] = 0;
    tracef("> %s", .{gData});

    tracef("# Binary:");
    const sz = testBinaryGen(&gData);
    var i: usize = 0;
    while (i < sz) : (i += 1) {
        tracef("> %d", gData[i]);
    }
}
