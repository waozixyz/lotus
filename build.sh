#!/bin/sh -e

ASM="uxnasm"
EMU="uxnemu"
LIN="uxncli $HOME/roms/uxnlin.rom"

SRC="src/potato.tal"
DST="bin/potato.rom"

CPY="$HOME/roms"
ARG=""

echo ">> Cleaning"
rm -rf bin
mkdir bin

if [[ "$*" == *"--lint"* ]]
then
    echo ">> Linting $SRC"
	$LIN $SRC
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
