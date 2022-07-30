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

Since this is designed to be used principally on a handheld devices without a window manager, the controls are aimed at d-pad centric. The pattern here is using the B button to handle all window operations, and leave the A button to the applications.

- `B+Up`, expand a window
- `B+Down`, tab a window
- `B+Right`, open a window
- `B+Left`, close a window

## TODO

- Change icon on alt mod for drag.
- Audio player.
- Terminal.
- Piano.
- Documentation.
- Basic text editor?
    - Scrollbar
- Image viewer
    - chr view
    - palette chooser
    - Select next image
    - Select prev image
- Clock widget
- Wallpaper application
    - Select image
- Theme selector
    - Save patt after theme
- Error modal/application
- Throw error when trying to open a folder as pict/text/data
- Mouse picking on desktop
- Hex editor
- Desktop
    - Rename file
    - Copy file
    - Delete file
- Tile
    - Support ICN/CHR mode switching
    - Support Copy/Paste(snarf)

## Support

- [theme](https://wiki.xxiivv.com/site/theme.html)
- [snarf](https://wiki.xxiivv.com/site/snarf.html)
