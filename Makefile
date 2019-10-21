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

CFG_ALL  = -G"Unix Makefiles" -DMULTITHREADED_BUILD=$(PROC_NUM)
# -DCMAKE_VERBOSE_MAKEFILE=ON
CFG_ALL += DCMAKE_INSTALL_PREFIX=$(CWD)/_install -DCMAKE_BUILD_TYPE=Release

CFG_KICAD  = $(CFG_ALL)
CFG_KICAD += -DKICAD_SPICE=OFF -DKICAD_USE_OCE=OFF
CFG_KICAD += -DKICAD_SCRIPTING=OFF
# -DKICAD_SCRIPTING_WXPYTHON=OFF

kicad: $(SRC)/$(KICAD)/README
	rm -rf $(BUILD)/$(KICAD) ; mkdir $(BUILD)/$(KICAD) ; cd $(BUILD)/$(KICAD) ;\
	cmake $(CFG_KICAD) $(SRC)/$(KICAD) && $(MAKE) -j$(PROC_NUM) && $(MAKE) install

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
