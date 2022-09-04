#!/bin/sh -e

# cat src/main.tal src/manifest.tal src/desktop.tal src/apps.tal src/assets.tal > bin/potato.tal

ASM="uxncli $HOME/roms/drifblim.rom"
EMU="uxnemu"
LIN="uxncli $HOME/roms/uxnlin.rom"

SRC="src/potato.tal"
DST="bin/potato.rom"

CPY="$HOME/roms"
ETC=""
ARG=""

echo ">> Cleaning"
rm -rf bin
mkdir bin

if [[ "$*" == *"--lint"* ]]
then
    echo ">> Linting $SRC"
	$LIN $SRC $ETC
fi

echo ">> Assembling $SRC"
$ASM $SRC $DST

if [[ "$*" == *"--save"* ]]
then
    echo ">> Saving $DST"
	cp $DST $CPY
fi

echo ">> Running $DST"
$EMU $DST $ARG
