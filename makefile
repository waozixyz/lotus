ID=potato
DIR=~/roms
ASM=uxncli ${DIR}/drifblim.rom
LIN=uxncli ${DIR}/uxnlin.rom
EMU=uxn11
ROM=bin/${ID}.rom

# Application source files
WM_TAL=$(wildcard wm/*.tal)
CMD_TAL=$(wildcard cmd/*.tal)

# Exclude partial files and development tools from standalone build
APPL_EXCLUDE = nasu-manifest nasu-assets loader
WM_FILTER = $(filter-out $(addprefix wm/,$(addsuffix .tal,$(APPL_EXCLUDE))),$(WM_TAL))
CMD_FILTER = $(filter-out $(addprefix cmd/,$(addsuffix .tal,$(APPL_EXCLUDE))),$(CMD_TAL))

all: ${ROM} apps

# Build all applications
apps: $(patsubst %.tal,%.rom,$(WM_FILTER) $(CMD_FILTER))

# Generic build rule (builds in-place)
%.rom: %.tal
	@ ${ASM} $< $@

# Multi-file Nasu build (concatenates files and removes include directives)
wm/nasu.rom: wm/nasu.tal wm/nasu-manifest.tal wm/nasu-assets.tal
	@ cat $^ | sed 's/~nasu-assets.tal//' > /tmp/nasu-combined.tal
	@ ${ASM} /tmp/nasu-combined.tal $@
	@ rm /tmp/nasu-combined.tal

lint:
	@ ${LIN} src/${ID}.tal
test:
	@ ${EMU} ${ROM} lemon15x12.icn
run:
	@if [ -n "$(APP)" ]; then \
		${EMU} $(APP).rom; \
	else \
		${EMU} ${ROM}; \
	fi

# Clean applications only (not main ROM)
clean-apps:
	@ find wm -name "*.rom" -delete
	@ find wm -name "*.sym" -delete
	@ find cmd -name "*.rom" -delete
	@ find cmd -name "*.sym" -delete

clean: clean-apps
	@ rm -f ${ROM} ${ROM}.sym
install: ${ROM}
	@ cp ${ROM} ${DIR}
uninstall:
	@ rm -f ${DIR}/${ID}.rom

.PHONY: all clean lint run install uninstall apps clean-apps

${ROM}: src/*
	@ mkdir -p bin
	@ ${ASM} src/${ID}.tal ${ROM}

