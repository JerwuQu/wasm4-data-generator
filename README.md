# wasm4-data-generator

**If you for some reason require more memory for your game but have plenty of cart space to spare...**

This is a small function (see [`datagen.zig`](https://github.com/JerwuQu/wasm4-data-generator/blob/master/datagen.zig))
that will generate WASM `store` instructions for your data to load it into memory at runtime, rather than having it in a WASM data segment.
This is only necessary because not every WASM runtime supports passive data segments, which would otherwise be the best solution.

It is most useful when you have lots of compressed data that will be uncompressed at runtime since that data would waste memory while being compressed.

Quick math shows that this method will require about 50-75% more bytes to store your data compared to using a data segment.

Released into public domain.
