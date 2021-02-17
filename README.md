# Alpine Laptop Installer

Based on the instruction from the wiki: 
- https://wiki.alpinelinux.org/wiki/Setting_up_a_laptop
- https://wiki.alpinelinux.org/wiki/LVM_on_LUKS

This is not meant to be a container / server setup in anyway.

## Impressions

So far I did a basic install of Alpine to my Dell XPS 13 9360 with regular setup-alpine. Works just fine. Did a git clone of dwm, compiled it and my laptop functions more or less the same as my Arch build.

## To Do
- ibus and japanese input in st: sthttps://bbs.archlinux.org/viewtopic.php?id=244688
  - fcitx compile?
    - https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package
    - https://github.com/fcitx/fcitx
- dwmblocks makefile update: compile issues in alpine
- st / dwm alpha patching
- st font2 patch
- switch fonts out and work on that kerning
- package / service / security audit
