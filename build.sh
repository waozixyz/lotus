#!/bin/sh

set -o nounset # This will make the script fail when accessing an unset variable. To use a variable that may or may not have been set, use "${varname-}" instead of "${varname}".
set -o errexit # Exit immediately if a command exits with a non-zero status.

roms_dir=${UXN_ROMS_DIR-"$HOME/roms"}

asm="uxncli $roms_dir/drifblim.rom"
asm="uxnasm"
emu="uxnemu"
lin="uxncli $roms_dir/uxnlin.rom"

src="src/potato.tal"
dst="bin/potato.rom"

cpy="$roms_dir"
arg=""

echo ">> Cleaning"
rm -rf bin
mkdir bin

case "$*" in
  *--lint*)
    echo ">> Linting $src"
    $lin $src
    ;;
esac

echo ">> Assembling $src"
$asm $src $dst

case "$*" in
  *--save*)
    echo ">> Saving $dst"
    cp $dst $cpy
    ;;
esac

echo ">> Running $dst"
$emu $dst $arg

