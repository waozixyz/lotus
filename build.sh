#!/bin/sh -e

echo "Cleaning.."
rm -rf bin
mkdir bin

if [ -e "$HOME/roms/uxnlin.rom" ]
then
	echo "Linting.."
	uxncli $HOME/roms/uxnlin.rom src/main.tal
	uxncli $HOME/roms/uxnlin.rom src/desktop.tal
	uxncli $HOME/roms/uxnlin.rom src/apps.tal
fi

echo "Assembling.."
cat src/main.tal src/manifest.tal src/desktop.tal src/apps.tal src/assets.tal > bin/potato.tal
uxncli $HOME/roms/drifblim.rom bin/potato.tal bin/potato.rom

cp ~/roms/noodle.rom bin/noodle.rom

if [ -d "$HOME/roms" ] && [ -e ./bin/potato.rom ]
then
	cp ./bin/potato.rom $HOME/roms
    echo "Installed in $HOME/roms" 
fi

echo "Running.."
uxnemu bin/potato.rom
