ID=potato
DIR=~/roms
ASM=uxncli ${DIR}/drifblim.rom
LIN=uxncli ${DIR}/uxnlin.rom
EMU=uxn11
ROM=bin/${ID}.rom

APPL_TAL=$(wildcard appl/*.tal)
APPL_ROM=$(APPL_TAL:.tal=.rom)

all: ${ROM} appl

run-appl-%: appl/%.rom
	@ ${EMU} $<

run-appl: run-appl-inbe

inbe: appl/inbe.rom

lint:
	@ ${LIN} src/${ID}.tal
test:
	@ ${EMU} ${ROM} lemon15x12.icn
run:
	@ ${EMU} ${ROM}
clean:
	@ rm -f ${ROM} ${ROM}.sym ${APPL_ROM} ${APPL_ROM:.rom=.rom.sym}
install: ${ROM}
	@ cp ${ROM} ${DIR}
uninstall:
	@ rm -f ${DIR}/${ID}.rom

.PHONY: all clean lint run install uninstall appl run-appl inbe

${ROM}: src/*
	@ mkdir -p bin
	@ ${ASM} src/${ID}.tal ${ROM}

appl: ${APPL_ROM}

appl/%.rom: appl/%.tal
	@ ${ASM} $< $@
