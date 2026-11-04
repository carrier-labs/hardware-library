# Hardware library: fit pieces and renders for every component in components/
#
#   make fit       out/<part>_fit.{stl,3mf}: the fit piece of every part
#   make renders   components/<part>/render.png (committed: the README shows it)
#   make check     admesh on every fit piece: one part, no problems
#   make all       all three
#   make <part>    one part's fit piece, e.g. make tactile-6x6
#   make site      out/site/: the browsable catalogue (3D viewer per part)
#   make serve     the catalogue on http://localhost:8000
#
# Needs OpenSCAD with the manifold backend (snapshot 2025+), admesh.

OPENSCAD ?= $(firstword $(wildcard $(HOME)/.local/bin/openscad*) openscad)
FLAGS    := --backend=manifold --hardwarnings
OUT      := out
COMPONENTS    := $(notdir $(wildcard components/*))
STLS     := $(COMPONENTS:%=$(OUT)/%_fit.stl)

.PHONY: all fit renders check site serve clean $(COMPONENTS)

all: fit renders check
fit: $(STLS) $(COMPONENTS:%=$(OUT)/%_fit.3mf)
renders: $(COMPONENTS:%=components/%/render.png)
$(COMPONENTS): %: $(OUT)/%_fit.stl $(OUT)/%_fit.3mf

$(OUT):
	mkdir -p $@

.SECONDEXPANSION:
$(OUT)/%_fit.stl $(OUT)/%_fit.3mf: components/%/fit.scad $$(wildcard components/%/*.scad) $$(wildcard util/*.scad) | $(OUT)
	$(OPENSCAD) $(FLAGS) -o $(OUT)/$*_fit.stl $<
	$(OPENSCAD) $(FLAGS) -o $(OUT)/$*_fit.3mf $<

components/%/render.png: components/%/fit.scad $$(wildcard components/%/*.scad)
	$(OPENSCAD) --backend=manifold --imgsize=1200,800 --viewall --autocenter \
	  --camera=0,0,0,50,0,60,0 -o $@ $<

check: $(STLS)
	@for f in $^; do \
	  r=$$(admesh $$f); \
	  parts=$$(echo "$$r" | awk '/Number of parts/ {print $$5}'); \
	  bad=$$(echo "$$r" | awk '/Degenerate facets|Edges fixed|Backwards edges|Total disconnected facets/ {s += $$NF} END {print s+0}'); \
	  echo "$$f: parts=$$parts problems=$$bad"; \
	  [ "$$parts" = 1 ] && [ "$$bad" = 0 ] || { echo "$$r"; exit 1; }; \
	done

site: fit
	python3 tools/build_site.py --openscad $(OPENSCAD)

serve: site
	python3 -m http.server -d $(OUT)/site 8000

clean:
	rm -rf $(OUT)
