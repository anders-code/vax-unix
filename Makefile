# this is not a real makefile with proper dependencies, but rather more of a 
# meta-build script

SIMH_BIG4 = vax780 vax750 vax730 vax8600
SIMH_TOOLS = mksimtape tar2mt
SUBDIRS = simh $(SIMH_TOOLS:%=simhtools/converters/%)

all: simh-big4 simh-tools
clean: $(SUBDIRS:%=%.clean)
	$(RM) -f .simh-makefile-patch.mk

simh-big4: $(SIMH_BIG4)

simh-tools: $(SIMH_TOOLS)

$(SUBDIRS:%=%.clean):
	$(MAKE) -C "$(@:%.clean=%)" clean

$(SIMH_BIG4): .simh-makefile-patch.mk
	$(MAKE) -C simh -f ../.simh-makefile-patch.mk TESTS=0 "$@"

$(SIMH_TOOLS):
	$(MAKE) -C "simhtools/converters/$@"

# fix HORRIBLE TERRIBLE simh makefile issue
.simh-makefile-patch.mk:
	sed -e 's?-d ./.git?-e ./.git?' simh/makefile > "$@"

.PHONY: all clean simh-big4 simh-tools
.PHONY: $(SUBDIRS:%=%.clean) $(SIMH_BIG4) $(SIMH_TOOLS)

