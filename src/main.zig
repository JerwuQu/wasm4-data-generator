const w4 = @import("wasm4.zig");
const datagen = @import("datagen.zig");

const testTextGen = datagen.create(@embedFile("./test_text.txt"));
const testBinaryGen = datagen.create(@embedFile("./test_binary.dat"));

export fn start() void {
    var gData: [256]u8 = undefined;

    w4.trace("# Text:");
    gData[testTextGen(&gData)] = 0;
    w4.tracef("> %s", .{gData});

    w4.trace("# Binary:");
    const sz = testBinaryGen(&gData);
    var i: usize = 0;
    while (i < sz) : (i += 1) {
        w4.tracef("> %d", gData[i]);
    }
}
