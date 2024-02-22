# A potato

A desktop environment, written in [Uxntal](https://wiki.xxiivv.com/site/uxntal.html).

## Build

You must have an [Uxntal](https://git.sr.ht/~rabbits/uxn) assembler.

```sh
uxnasm src/potato.tal bin/potato.rom
uxnemu bin/potato.rom
```

If do not wish to assemble it yourself, you can download [potato.rom](https://rabbits.srht.site/potato/potato.rom).

[![builds.sr.ht status](https://builds.sr.ht/~rabbits/potato.svg)](https://builds.sr.ht/~rabbits/potato?)

## Manual

Since this is designed to be used principally on a handheld devices without a window manager, the controls are aimed at d-pad centric. The pattern here is using the B button to handle all window operations, and leave the A button to the applications. Alternatively, you can open a file with `mouse2`.

- `B+Up`, expand a window
- `B+Down`, tab a window
- `B+Right`, open a window
- `B+Left`, close a window

## TODO

- Change cursor icon on alt mod for drag.
- Fix mouse picking in Play app.
- Terminal.
- Documentation.
- Text Reader scrollbar should be clickable
- Hex Viewer
- Throw error when windows count is > #10
- Throw error when dir is longer than $400
- Fade animation when launching rom

## Support

- [theme](https://wiki.xxiivv.com/site/theme.html)
- [snarf](https://wiki.xxiivv.com/site/snarf.html)

