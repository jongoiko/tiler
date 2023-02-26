# tiler - A GameBoy tile editor for the GameBoy

`tiler` is a simple drawing app for the GameBoy, with the peculiarity that it converts the tile you're drawing into [the console's tile format](https://www.huderlem.com/demos/gameboy2bpp.html).

![The ROM running on an emulator](https://github.com/jongoiko/tiler/blob/main/tiler.gif)

This project is old and highly limited (can only edit a single tile, no support for saving the data/viewing it in real single-tile size), but still fun to play with.

## Usage

- Move the cursor around with the **joypad**.
- Change the color in the cursor's position with **A** (darken the pixel) or **B** (lighten the pixel).

In order to read the tile data corresponding to the drawing, an emulator with debugging capabilities is needed, or at least one which allows peeking into specific memory addresses. In particular, the tile data is stored in the 16 bytes starting at `0xFF90`.

## Compilation

1. Make sure that the [RGBDS](https://github.com/gbdev/rgbds) toolchain is installed on your machine.
2. In the project's root directory, run `make`.
3. The compiled ROM will be located in the `build/` directory.
