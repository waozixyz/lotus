#!/bin/sh -e

echo "Cleaning.."
rm -rf bin
mkdir bin

if [ -e "$HOME/roms/uxnlin.rom" ]
then
	echo "Linting.."
	uxncli $HOME/roms/uxnlin.rom src/potato.tal
fi

echo "Assembling.."
uxnasm src/potato.tal bin/potato.rom

if [ -d "$HOME/roms" ] && [ -e ./bin/potato.rom ]
then
	cp ./bin/potato.rom $HOME/roms
    echo "Installed in $HOME/roms" 
fi

echo "Running.."
uxnemu bin/potato.rom
