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

- `B+Up`, close a window
- `B+Down`, open a window
- `B+Down Down`, tab a window

## TODO

- Change icon on alt mod for drag.
- Wallpaper application.
- Audio player.
- Image viewer.
- Theme editor.
- Clock application.
- Terminal.
- Piano.
- Documentation.
- Basic text editor?

## Support

- [theme](https://wiki.xxiivv.com/site/theme.html)
- [snarf](https://wiki.xxiivv.com/site/snarf.html)



