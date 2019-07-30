DOC = README.md doc/install.md doc/index.md doc/kicad.md

docs/index.html: $(DOC) Makefile
	pandoc -f markdown -t html --toc -s -o $@ $(DOC)

.PHONY: dirs gz install

install: dirs

CWD  = $(CURDIR)
GZ 	?= $(CWD)/gz
TMP ?= $(CWD)/tmp
SRC ?= $(TMP)/src

dirs:
	mkdir -p $(GZ) $(TMP) $(SRC)

KICAD_VER	= 5.1.3
KICAD		= kicad-$(KICAD_VER)
KICAD_GZ	= $(KICAD).tar.gz

gz: $(GZ)
	$(WGET) https://github.com/KiCad/kicad-source-mirror/archive/5.1.3.tar.gz

