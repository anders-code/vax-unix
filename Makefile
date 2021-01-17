# this is not a real makefile with proper dependencies, but rather more of a 
# meta-build script

SIMH_BIG4 = vax780 vax750 vax730 vax8600
SIMH_TOOLS = mksimtape tar2mt

.PHONY: all clean submodules clean-submodules simh-big4 simh-tools
.PHONY: $(SUBDIRS:%=%.clean)

SUBDIRS = simh $(SIMH_TOOLS:%=simhtools/converters/%)
SUBMODULES = simh simhtools 4.3BSD-dist
SIMH_BUILDROMS = simh/BIN/buildtools/BuildROMs
SIMH_BIG4_PATHS = $(SIMH_BIG4:%=simh/BIN/%)
SIMH_TOOLS_PATHS = $(join $(SIMH_TOOLS:%=simhtools/converters/%/),$(SIMH_TOOLS))

all: simh-big4 simh-tools

clean: $(SUBDIRS:%=%.clean)
	$(RM) .simh-makefile-patch.mk

$(SUBDIRS:%=%.clean):
	-$(MAKE) -C $(@:%.clean=%) clean

submodules: $(SUBMODULES:%=%/.git)

clean-submodules:
	git submodule deinit -f --all

$(SUBMODULES:%=%/.git):
	git submodule update --init $(@:%/.git=%)

simh-big4: $(SIMH_BIG4_PATHS)

$(SIMH_BIG4_PATHS): $(SIMH_BUILDROMS) | simh/.git
	$(MAKE) -C simh TESTS=0 $(@:simh/BIN/%=%)

# this needs to be build separately at the top level so that make -j8 works
$(SIMH_BUILDROMS): | simh/.git
	$(MAKE) -C simh TESTS=0 $(@:simh/%=%)

simh-tools: $(SIMH_TOOLS_PATHS)

$(SIMH_TOOLS_PATHS): | simhtools/.git
	$(MAKE) -C $(dir $@)

