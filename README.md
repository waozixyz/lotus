# A potato

A desktop environment, written in [Uxntal](https://wiki.xxiivv.com/site/uxntal.html).

## Build

You must have an [Uxntal](https://git.sr.ht/~rabbits/uxn) assembler.

```sh
uxnasm src/potato.tal bin/potato.rom
```

If do not wish to assemble it yourself, you can download [potato.rom](https://rabbits.srht.site/potato/potato.rom).

## Run

You must have a Varvara emulator.

```sh
uxnemu bin/potato.rom
```

## Manual

Since this is designed to be used principally on a handheld devices without a window manager, the controls are aimed at d-pad centric. The pattern here is using the B button to handle all window operations, and leave the A button to the applications. Alternatively, you can open a file with `mouse2`.

- `B+Up`, expand a window
- `B+Down`, tab a window
- `B+Right`, open a window
- `B+Left`, close a window

## Notes

- `---- name.txt` is a filepath
- `name.txt` is a filename
- `desktop/id` is an icon
- `desktop/file` is a file

## TODO

- Change cursor icon on alt mod for drag.
- Audio player.
- Terminal.
- Piano.
- Documentation.
- Basic text editor?
    - Scrollbar
- Image viewer
    - palette chooser
    - Select next image
    - Select prev image
- Clock widget
- Wallpaper application?
    - Select `.paper` image
- Hex editor
- Desktop
    - Rename file
    - Copy file
- Tile
    - Support ICN/CHR mode switching
- Screensaver?
- Swatch should show icon over selection
- Catch maximum number of windows
- Windows names shouldn't leave window bar bounds

## Support

- [theme](https://wiki.xxiivv.com/site/theme.html)
- [snarf](https://wiki.xxiivv.com/site/snarf.html)
