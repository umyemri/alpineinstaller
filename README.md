# Alpine Laptop Installer

Based on the instruction from the wiki: 
- https://wiki.alpinelinux.org/wiki/Setting_up_a_laptop
- https://wiki.alpinelinux.org/wiki/LVM_on_LUKS

This is not meant to be a container / server setup in anyway.

## Impressions

So far I did a basic install of Alpine to my Dell XPS 13 9360 with regular setup-alpine. Works just fine. Did a git clone of dwm, compiled it and my laptop functions more or less the same as my Arch build.

~~I'll need to write up some notes for an encrypted build, but it looks like it's just a combo of cfdisk, chroot and cryptsetup. Some trial and error and I should be good.~~ __Edit:__ Encrypted build complete - see encrypt.sh.

## To Do
- fix postinstall.sh assumptions
- ibus and japanese input in st: sthttps://bbs.archlinux.org/viewtopic.php?id=244688
  - fcitx compile?
    - https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package
    - https://github.com/fcitx/fcitx
- texlive setup: no sigil build on alpine, but i've been meaning to learn latex anyway.
- dwmblocks makefile update: compile issues in alpine
- st / dwm alpha patching
- st font2 patch
- dash install: no chsh
  - alias clean-up
- switch fonts out and work on that kerning
- vim integration: missing some things... hmmm
- python3 paths
- package / service / security audit
