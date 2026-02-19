ID=potato
DIR=~/roms
ASM=uxncli ${DIR}/drifblim.rom
LIN=uxncli ${DIR}/uxnlin.rom
EMU=uxn11
ROM=bin/${ID}.rom

APPL_TAL=$(wildcard appl/*.tal)
APPL_ROM=$(patsubst appl/%.tal,bin/%.rom,$(APPL_TAL))

all: ${ROM} appl bin/nasu.rom

lint:
	@ ${LIN} src/${ID}.tal
test:
	@ ${EMU} ${ROM} lemon15x12.icn
run:
	@if [ -n "$(APP)" ]; then \
		${EMU} bin/$(APP).rom; \
	else \
		${EMU} ${ROM}; \
	fi
clean:
	@ rm -f ${ROM} ${ROM}.sym bin/*.rom bin/*.rom.sym
install: ${ROM}
	@ cp ${ROM} ${DIR}
uninstall:
	@ rm -f ${DIR}/${ID}.rom

.PHONY: all clean lint run install uninstall appl nasu-test nasu-archive

${ROM}: src/*
	@ mkdir -p bin
	@ ${ASM} src/${ID}.tal ${ROM}

appl: ${APPL_ROM}

# Nasu-specific build (multi-file assembly)
bin/nasu.rom: appl/nasu.tal appl/nasu-manifest.tal appl/nasu-assets.tal
	@ mkdir -p bin
	@ cat appl/nasu.tal appl/nasu-manifest.tal appl/nasu-assets.tal > bin/nasu-combined.tal
	@ ${ASM} bin/nasu-combined.tal bin/nasu.rom
	@ rm bin/nasu-combined.tal

# Nasu testing
nasu-test: bin/nasu.rom
	@ ${EMU} bin/nasu.rom assets/ako10x10.chr

# Nasu archive (standalone version)
nasu-archive: bin/nasu.rom
	@ cat appl/nasu.tal appl/nasu-manifest.tal appl/nasu-assets.tal | \
	  sed 's/~[^[:space:]]\+//' > bin/nasu-standalone.tal
	@ ${ASM} bin/nasu-standalone.tal bin/nasu-standalone.rom

bin/%.rom: appl/%.tal
	@ mkdir -p bin
	@ ${ASM} $< $@
