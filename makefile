ID=potato
DIR=~/roms
ASM=uxncli ${DIR}/drifblim.rom
LIN=uxncli ${DIR}/uxnlin.rom
EMU=uxn11
ROM=bin/${ID}.rom

APPL_TAL=$(wildcard appl/*.tal)
APPL_ROM=$(patsubst appl/%.tal,bin/%.rom,$(APPL_TAL))

all: ${ROM} appl

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

.PHONY: all clean lint run install uninstall appl

${ROM}: src/*
	@ mkdir -p bin
	@ ${ASM} src/${ID}.tal ${ROM}

appl: ${APPL_ROM}

bin/%.rom: appl/%.tal
	@ mkdir -p bin
	@ ${ASM} $< $@
