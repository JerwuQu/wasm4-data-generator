# wasm4-data-generator

If you for some reason require more memory for your game but have plenty of cart space to spare.

This is a small function (see `src/datagen.zig`) that will generate `store` instructions for your data, rather than having it in a WASM data segment.
This is only necessary because not every WASM runtime supports passive data segments.

Quick math shows that this method will require about 14 bytes of wasm per every 8 bytes of data.

Released into public domain.
