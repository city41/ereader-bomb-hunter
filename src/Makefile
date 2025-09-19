# Makefile.asm
#
# This Makefile takes z80 assembly code and does everything need to get it bunbled into raw cards, bmps, and can
# also directly run the result in mGBA
#
# The compiled z80 bin can either be one you have made via assembling a z80 program, or one you
# have extracted out of an existing e-reader card
SHELL :=/bin/bash


# root name of the z80 assembly file (without the .asm extension) that is the starting point of everything here 
Z80_ASM_NAME=includes
# The primary name that will show up in the E-Reader interface
EREADER_NAME=Bomb Hunter
# The root name for the raw and bmp files, will be $OUTNAME.ereader1.raw, $OUTNAME.ereader2.raw, $OUTNAME.dotcode1.bmp, etc
OUTNAME=bombHunter

# If running on Linux (and presumably MacOS), this is used to run the E-Reader tools through wine
# wine.sh is just a simple script that will take an installed wine command and allow it to run against
# exe's in the bin directory
WINE=wine
BIN=../bin
RAW2BMP=$(BIN)/raw2bmp
NEDCMAKE=$(WINE) $(BIN)/nedcmake.exe
NEFLMAKE=$(BIN)/neflmake
NEVPK=$(WINE) $(BIN)/nevpk.exe
ASLINK=$(BIN)/aslink
# ASZ80_EREADER=$(WINE) asz80-ereader.exe
ASZ80_EREADER=$(BIN)/asz80
CONVERTPNG=../scripts/convertpng.sh

# this allows a custom mgba setup to execute and run the e-reader and have the cards ready to go
# your mgba binary
MGBA=mgba-qt
# the ereader rom for each region
EREADER_MGBA_ROM=~/roms/gba/ereaderUSA.zip
EREADER_MGBA_ROM_SAV=~/roms/gba/ereaderUSA.sav
EREADER_MGBA_ROM_JPN=~/roms/gba/ereaderJPN.zip
EREADER_MGBA_ROM_SAV_JPN=~/roms/gba/ereaderJPN.sav

PRELUDE?=
REGION?=1
TEXT?=UNIVERSAL
DPI?=1200

sav: $(OUTNAME).sav

gfx:
	$(CONVERTPNG) $(shell pwd)/resources/resources.json

$(OUTNAME).sav: $(Z80_ASM_NAME).vpk
	$(NEFLMAKE) -i $(Z80_ASM_NAME).vpk -o $(OUTNAME).sav -type 1 -name '$(EREADER_NAME)' -region 1

# this craziness allows this Makefile to work no matter how many strips a given z80 binary needs
# so after nedcmake runs, if it made one raw or 8 raws, it will create new make rules for each created raw
# that way "make raws" or "make bmps" makes the correct number accounting for all needed strips
raws.mk: $(Z80_ASM_NAME).vpk
	$(NEDCMAKE) -i $(Z80_ASM_NAME).vpk -o $(OUTNAME).raw -type 1 -region $(REGION) -name '$(EREADER_NAME)' -raw -save 1;
	I=1; for r in $(OUTNAME).raw*.raw; do \
		echo "$(OUTNAME).r$(REGION).$(TEXT).ereader$$I.raw: $r"; \
		echo "	mv $$r $(OUTNAME).r$(REGION).$(TEXT).ereader$$I.raw"; \
		echo "RAW_TARGETS += $(OUTNAME).r$(REGION).$(TEXT).ereader$$I.raw"; \
		echo "$(OUTNAME).r$(REGION).$(TEXT).ereader$$I.bmp: $(OUTNAME).r$(REGION).$(TEXT).ereader$$I.raw"; \
		echo "	$(RAW2BMP) -i $(OUTNAME).r$(REGION).$(TEXT).ereader$$I.raw -o $(OUTNAME).r$(REGION).$(TEXT).dotcode$$I -dpi $(DPI)"; \
		echo "BMP_TARGETS += $(OUTNAME).r$(REGION).$(TEXT).ereader$$I.bmp"; \
		((I = I + 1)); \
	done > $@

-include raws.mk

raws: $(RAW_TARGETS)
bmps: $(BMP_TARGETS)

$(Z80_ASM_NAME).vpk: $(Z80_ASM_NAME).bin
	$(NEVPK) -i $(Z80_ASM_NAME).bin -o $(Z80_ASM_NAME).vpk -c -level 2

$(Z80_ASM_NAME).bin: $(Z80_ASM_NAME).s19
	objcopy --input-target=srec --output-target=binary $(Z80_ASM_NAME).s19 $(Z80_ASM_NAME).bin

$(Z80_ASM_NAME).s19: $(Z80_ASM_NAME).rel
	$(ASLINK) -n -s $(Z80_ASM_NAME).rel

$(Z80_ASM_NAME).rel: $(Z80_ASM_NAME).asm 
	$(ASZ80_EREADER) -o -s -w $(PRELUDE) $(Z80_ASM_NAME).asm

clean:
	rm -rf $(OUTNAME).ereader*.raw \
	$(Z80_ASM_NAME).vpk \
	$(Z80_ASM_NAME).rel \
	$(Z80_ASM_NAME).bin \
	$(Z80_ASM_NAME).s19 \
	raws.mk \
	*.raw \
	*.bmp \
	*.sav \
	*.sym

runsav: $(OUTNAME).sav
	rm $(EREADER_MGBA_ROM_SAV);
	cp $(OUTNAME).sav $(EREADER_MGBA_ROM_SAV);
	$(MGBA) $(EREADER_MGBA_ROM)

runsavjpn: $(OUTNAME).sav
	rm $(EREADER_MGBA_ROM_SAV_JPN);
	cp $(OUTNAME).sav $(EREADER_MGBA_ROM_SAV_JPN);
	$(MGBA) $(EREADER_MGBA_ROM_JPN)
