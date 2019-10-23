MODULE = $(notdir $(CURDIR))
CWD  = $(CURDIR)
TMP ?= $(CWD)/tmp
SRC ?= $(TMP)/src
GZ  ?= $(HOME)/gz
BUILD ?= $(TMP)/build

KICAD_VER = 5.1.4
KICAD     = kicad-$(KICAD_VER)
KICAD_GZ  = $(KICAD).tar.xz

WGET = wget -c -P $(GZ)

.PHONY: install dirs kicad

install: dirs kicad

dirs:
	mkdir -p $(GZ) $(TMP) $(SRC) $(BUILD)

PROC_NUM ?= $(shell grep processor /proc/cpuinfo|wc -l)

CMAKE_ALL    = -G"Unix Makefiles" -DMULTITHREADED_BUILD=$(PROC_NUM)
CMAKE_ALL   += -DCMAKE_INSTALL_PREFIX=$(CWD)/_install -DCMAKE_BUILD_TYPE=Release

CMAKE_KICAD  = $(CFG_ALL) -DKICAD_SKIP_BOOST=ON 
CMAKE_KICAD += -DKICAD_SPICE=OFF -DKICAD_USE_OCE=OFF
CMAKE_KICAD += -DKICAD_SCRIPTING=ON -DKICAD_SCRIPTING_MODULES=ON -DKICAD_SCRIPTING_WXPYTHON=ON

kicad: $(SRC)/$(KICAD)/README
	rm -rf $(BUILD)/$(KICAD) ; mkdir $(BUILD)/$(KICAD) ; cd $(BUILD)/$(KICAD) ;\
	cmake $(CMAKE_KICAD) $(SRC)/$(KICAD) && $(MAKE) -j$(PROC_NUM) && $(MAKE) install

$(SRC)/$(KICAD)/README: $(GZ)/$(KICAD_GZ)
	cd $(SRC) ; xzcat $< | tar -x && touch $@

$(GZ)/$(KICAD_GZ):
	$(WGET) -O $@ https://launchpad.net/kicad/5.0/$(KICAD_VER)/+download/$(KICAD_GZ)

DOC  = README.md doc/index.md doc/install.md doc/make.md 
DOC += doc/sw.md doc/kicad.md doc/freecad.md doc/lib.md
DOC += doc/cortex.md doc/linux.md

.PHONY: doc
doc: docs/index.html
docs/index.html: $(DOC) Makefile
	pandoc -f markdown -t html --toc -s -o $@ $(DOC)

.PHONY: deb
DEB  = build-essential make gawk cmake git flex bison ragel 
DEB += python-wxgtk3.0-dev
deb:
	sudo apt install -u $(DEB)

.PHONY: cross binutils cclibs gcc texane
cross: binutils	texane

BINUTILS_VER = 2.33.1
BINUTILS     = binutils-$(BINUTILS_VER)
BINUTILS_GZ  = $(BINUTILS).tar.xz

TEXANE_VER   = 1.5.1
TEXANE       = texane-$(TEXANE_VER)
TEXANE_GZ	 = $(TEXANE).tar.gz

TARGET ?= arm-none-eabi

CFG_ALL      = --disable-nls --prefix=$(CWD)/_cross
CFG_BINUTILS = $(CFG_ALL) --target=$(TARGET)

binutils: $(SRC)/$(BINUTILS)/README
	rm -rf $(BUILD)/$(BINUTILS) ; mkdir $(BUILD)/$(BINUTILS) ; cd $(BUILD)/$(BINUTILS) ;\
	$(SRC)/$(BINUTILS)/configure $(CFG_BINUTILS) && $(MAKE) -j$(PROC_NUM) && $(MAKE) install

$(GZ)/$(BINUTILS_GZ):
	$(WGET) -O $@ https://mirror.tochlab.net/pub/gnu/binutils/$(BINUTILS_GZ)

texane: $(GZ)/$(TEXANE_GZ)

$(GZ)/$(TEXANE_GZ):
	$(WGET) -O $@ https://github.com/texane/stlink/archive/v$(TEXANE_VER).tar.gz

$(SRC)/%/README: $(GZ)/%.tar.xz
	cd $(SRC) ; xzcat $< | tar x && touch $@
