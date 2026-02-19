ID=potato
DIR=~/roms
ASM=uxncli ${DIR}/drifblim.rom
LIN=uxncli ${DIR}/uxnlin.rom
EMU=uxn11

# Source files
WM_TAL=$(wildcard wm/*.tal)
CMD_TAL=$(wildcard cmd/*.tal)
POTATO_TAL=potato/potato.tal

# Exclude partial files from standalone build
APPL_EXCLUDE = nasu-manifest nasu-assets
WM_FILTER = $(filter-out $(addprefix wm/,$(addsuffix .tal,$(APPL_EXCLUDE))),$(WM_TAL))
CMD_FILTER = $(filter-out $(addprefix cmd/,$(addsuffix .tal,$(APPL_EXCLUDE))),$(CMD_TAL))

# All ROMs go to bin/ with subdirectories
WM_ROM=$(patsubst wm/%.tal,bin/wm/%.rom,$(WM_FILTER))
CMD_ROM=$(patsubst cmd/%.tal,bin/cmd/%.rom,$(CMD_FILTER))
POTATO_ROM=bin/${ID}.rom

all: ${POTATO_ROM} ${WM_ROM} ${CMD_ROM}

# Main project (single file build, must build from potato/ dir for includes)
${POTATO_ROM}: potato/potato.tal
	@ mkdir -p bin
	@ cd potato && ${ASM} potato.tal ../$@
	@ rm -f ${@}.sym

# WM apps
bin/wm/%.rom: wm/%.tal
	@ mkdir -p bin/wm
	@ ${ASM} $< $@
	@ rm -f ${@}.sym

# CMD apps
bin/cmd/%.rom: cmd/%.tal
	@ mkdir -p bin/cmd
	@ ${ASM} $< $@
	@ rm -f ${@}.sym

# Multi-file Nasu build
bin/wm/nasu.rom: wm/nasu.tal wm/nasu-manifest.tal wm/nasu-assets.tal
	@ mkdir -p bin/wm
	@ cat $^ | sed 's/~nasu-assets.tal//' > /tmp/nasu-combined.tal
	@ ${ASM} /tmp/nasu-combined.tal $@
	@ rm -f ${@}.sym
	@ rm /tmp/nasu-combined.tal

# Lint
lint:
	@ ${LIN} ${POTATO_TAL}

# Test
test:
	@ ${EMU} ${POTATO_ROM} lib/akane20x10.icn

# Run main project
run:
	@ ${EMU} ${POTATO_ROM}

# Run app from bin/
run-app:
	@if [ -n "$(APP)" ]; then \
		if [ -f bin/wm/$(APP).rom ]; then \
			${EMU} bin/wm/$(APP).rom; \
		elif [ -f bin/cmd/$(APP).rom ]; then \
			${EMU} bin/cmd/$(APP).rom; \
		else \
			echo "Error: bin/wm/$(APP).rom or bin/cmd/$(APP).rom not found"; \
		fi; \
	fi

# Clean all ROMs
clean:
	@ rm -rf bin

install: ${POTATO_ROM}
	@ cp ${POTATO_ROM} ${DIR}

uninstall:
	@ rm -f ${DIR}/${ID}.rom

.PHONY: all clean lint run run-app install uninstall
