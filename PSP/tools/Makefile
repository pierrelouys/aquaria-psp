#
# Aquaria PSP port
# Copyright (C) 2010 Andrew Church <achurch@achurch.org>
#
# tools/Makefile: Build control file for tool programs.
#

###########################################################################

# System environment settings
#
# The asset converters are ordinary native Linux programs.  The default
# build intentionally excludes the old GTK2 GUI builder, so converting
# assets does not require GTK2 development packages.

EXEEXT =
SYS_CFLAGS = -DIS_LITTLE_ENDIAN
ARCH := $(shell uname -m)
ifeq ($(GENERIC),)
ifneq ($(filter x86_64 amd64,$(ARCH)),)
SYS_CFLAGS += -DUSE_SSE2 -DARCH_AMD64
else ifeq ($(ARCH),i686)
SYS_CFLAGS += -msse2 -DUSE_SSE2
endif
endif

# Common programs/flags.  WERROR=1 can be used for a strict build; by default
# warnings remain visible without making newer compiler diagnostics fatal.

CC      = gcc
CFLAGS  = -g -O2 -Wall -Wstrict-prototypes -Wmissing-prototypes
ifeq ($(WERROR),1)
CFLAGS += -Werror
endif
LDFLAGS =
LIBS    =
PKG_CONFIG ?= pkg-config

# These are host-side Linux tools, even when built from a shell configured for
# the PSP SDK.  In particular, CPATH/C_INCLUDE_PATH can silently select the
# PSP's newlib headers (causing host links to fail on symbols such as
# _impure_ptr).  Likewise, the PSP pkg-config paths and library search path
# must not leak into native converter builds.  HOST_ENV is overridable for
# unusual host setups that intentionally use non-system host dependencies.
HOST_ENV ?= env -u CPATH -u C_INCLUDE_PATH -u CPLUS_INCLUDE_PATH \
               -u OBJC_INCLUDE_PATH -u LIBRARY_PATH -u COMPILER_PATH \
               -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR \
               -u PKG_CONFIG_SYSROOT_DIR
HOST_PKG_CONFIG = $(HOST_ENV) $(PKG_CONFIG)

# Resolve distro-specific include and linker flags through pkg-config when
# available, with conventional library names as a fallback for installations
# that provide headers/libraries but no .pc files.
CFLAGS_png = $(shell $(HOST_PKG_CONFIG) --cflags libpng 2>/dev/null)
LIBS_png = $(shell $(HOST_PKG_CONFIG) --libs libpng 2>/dev/null)
ifeq ($(strip $(LIBS_png)),)
LIBS_png = -lpng -lz
endif

CFLAGS_vorbis = $(shell $(HOST_PKG_CONFIG) --cflags vorbisfile 2>/dev/null)
LIBS_vorbis = $(shell $(HOST_PKG_CONFIG) --libs vorbisfile 2>/dev/null)
ifeq ($(strip $(LIBS_vorbis)),)
LIBS_vorbis = -lvorbisfile -lvorbis -logg
endif

CFLAGS_lame = $(shell $(HOST_PKG_CONFIG) --cflags lame 2>/dev/null)
LIBS_lame = $(shell $(HOST_PKG_CONFIG) --libs lame 2>/dev/null)
ifeq ($(strip $(LIBS_lame)),)
LIBS_lame = -lmp3lame
endif

# These flags are used only by the optional legacy GTK2 application.
ifeq ($(shell uname -s | cut -c1-5 | tr A-Z a-z),mingw)
GTKSYS = win32
else
GTKSYS = x11
endif
CFLAGS_gtk = $(shell $(HOST_PKG_CONFIG) --cflags gtk+-$(GTKSYS)-2.0 2>/dev/null)
LDFLAGS_gtk =
LIBS_gtk = $(filter-out -lpng%,$(shell $(HOST_PKG_CONFIG) --libs gtk+-$(GTKSYS)-2.0 2>/dev/null))

######################################

# Programs to build and their sources/flags

ASSET_PROGRAMS = oggtomp3 pngtotex
CLI_PROGRAMS = $(ASSET_PROGRAMS) build-pkg
PROGRAMS = AquariaPSPBuilder $(CLI_PROGRAMS)
AquariaPSPBuilder_AUTOGEN = AquariaPSPBuilder-eboot.i \
                            AquariaPSPBuilder-scripts.i \
                            AquariaPSPBuilder-ui.i

AquariaPSPBuilder_SOURCES = AquariaPSPBuilder.c quantize.c zoom.c
AquariaPSPBuilder_DEPS    = ../src/common.h ../src/resource/package-pkg.h \
                            ../src/texture.h quantize.h sse2.h zoom.h \
                            $(AquariaPSPBuilder_AUTOGEN)
AquariaPSPBuilder_CFLAGS  = $(SYS_CFLAGS) $(CFLAGS) -DIN_TOOL $(CFLAGS_gtk) \
                            $(CFLAGS_vorbis) $(CFLAGS_lame) $(CFLAGS_png) \
                            -DHG_REVISION=\"$(shell hg id -n 2>/dev/null || echo unknown)\"
AquariaPSPBuilder_LDFLAGS = $(LDFLAGS) $(LDFLAGS_gtk) \
                            $(LDFLAGS_vorbis) $(LDFLAGS_lame) $(LDFLAGS_png)
AquariaPSPBuilder_LIBS    = $(LIBS) $(LIBS_gtk) \
                            $(LIBS_vorbis) $(LIBS_lame) $(LIBS_png) -lm

build-pkg_SOURCES = build-pkg.c
build-pkg_DEPS    = ../src/common.h ../src/resource/package-pkg.h
build-pkg_CFLAGS  = $(SYS_CFLAGS) $(CFLAGS) -DIN_TOOL
build-pkg_LDFLAGS = $(LDFLAGS)
build-pkg_LIBS    = $(LIBS)

oggtomp3_SOURCES  = oggtomp3.c
oggtomp3_DEPS     = ../src/common.h
oggtomp3_CFLAGS   = $(SYS_CFLAGS) $(CFLAGS) -DIN_TOOL $(CFLAGS_vorbis) $(CFLAGS_lame)
oggtomp3_LDFLAGS  = $(LDFLAGS)
oggtomp3_LIBS     = $(LIBS) $(LIBS_vorbis) $(LIBS_lame) -lm

pngtotex_SOURCES  = pngtotex.c quantize.c zoom.c
pngtotex_DEPS     = ../src/common.h ../src/texture.h quantize.h sse2.h zoom.h
pngtotex_CFLAGS   = $(SYS_CFLAGS) $(CFLAGS) -DIN_TOOL $(CFLAGS_png)
pngtotex_LDFLAGS  = $(LDFLAGS)
pngtotex_LIBS     = $(LIBS) $(LIBS_png) -lm

###########################################################################

# Build rules

.PHONY: all asset-tools cli-tools all-tools clean
# Default to the useful native command-line tools; the legacy GUI can be built
# explicitly with `make AquariaPSPBuilder` on systems that still provide GTK2.
all: cli-tools
asset-tools: $(ASSET_PROGRAMS:%=%$(EXEEXT))
cli-tools: $(CLI_PROGRAMS:%=%$(EXEEXT))
all-tools: $(PROGRAMS:%=%$(EXEEXT))
clean:
	rm -f $(PROGRAMS:%=%$(EXEEXT)) $(AquariaPSPBuilder_AUTOGEN)

AquariaPSPBuilder$(EXEEXT): $(AquariaPSPBuilder_SOURCES) $(AquariaPSPBuilder_DEPS) Makefile
	$(HOST_ENV) $(CC) $(AquariaPSPBuilder_CFLAGS) $(AquariaPSPBuilder_SOURCES) \
		$(AquariaPSPBuilder_LDFLAGS) $(AquariaPSPBuilder_LIBS) -o $@

build-pkg$(EXEEXT): $(build-pkg_SOURCES) $(build-pkg_DEPS) Makefile
	$(HOST_ENV) $(CC) $(build-pkg_CFLAGS) $(build-pkg_SOURCES) \
		$(build-pkg_LDFLAGS) $(build-pkg_LIBS) -o $@

oggtomp3$(EXEEXT): $(oggtomp3_SOURCES) $(oggtomp3_DEPS) Makefile
	$(HOST_ENV) $(CC) $(oggtomp3_CFLAGS) $(oggtomp3_SOURCES) \
		$(oggtomp3_LDFLAGS) $(oggtomp3_LIBS) -o $@

pngtotex$(EXEEXT): $(pngtotex_SOURCES) $(pngtotex_DEPS) Makefile
	$(HOST_ENV) $(CC) $(pngtotex_CFLAGS) $(pngtotex_SOURCES) \
		$(pngtotex_LDFLAGS) $(pngtotex_LIBS) -o $@

#-------------------------------------

AquariaPSPBuilder-eboot.i: ../aquaria.prx ../PARAM.SFO Makefile
	perl \
		-e 'foreach (@ARGV) {' \
		-e '    my ($$id, $$file) = split(/=/, $$_);' \
		-e '    print "static const unsigned char $${id}[] = {\n";' \
		-e '    my $$size = 0;' \
		-e '    open F, "<$$file" or die "$$file: $$!\n";' \
		-e '    while (read(F, $$_, 16) > 0) {' \
		-e '        print join(",",unpack("C*",$$_)) . ",\n";' \
		-e '        $$size += length($$_);' \
		-e '    }' \
		-e '    close F;' \
		-e '    print "};\nstatic const unsigned int $${id}_size = $$size;\n";' \
		-e '}' \
		'aquaria_prx=../aquaria.prx' 'param_sfo=../PARAM.SFO' >$@
../PARAM.SFO: ../aquaria.prx
../aquaria.prx:
	make -C ..

AquariaPSPBuilder-scripts.i: FORCE
	find ../../game_scripts/scripts -name \*.lua \
	| perl \
		-e 'print "static const struct {const char *path, *data;} script_data[] = {\n";' \
		-e 'while (<STDIN>) {' \
		-e '    my $$path = $$_;' \
		-e '    chomp $$path;' \
		-e '    open F, "<$$path" or die "$$path: $$!\n";' \
		-e '    my $$data;' \
		-e '    {local $$/ = undef; $$data = <F>;}' \
		-e '    close F;' \
		-e '    $$path =~ s,^\.\./\.\./game_scripts/,, or die "Bad path: $$path\n";' \
		-e '    $$data =~ s/([\\"])/\\$$1/g;' \
		-e '    $$data =~ s/\n/\\n\\\n/g;' \
		-e '    print "{\"$$path\", \"$$data\"},\n"' \
		-e '}' \
		-e 'print "};\n";' \
		>$@

.PHONY: FORCE
FORCE:

AquariaPSPBuilder-ui.i: AquariaPSPBuilder.glade Makefile
	perl \
		-e 'print "static const char ui_glade[] = \"\\\n";' \
		-e 'while (<STDIN>) {' \
		-e '    s/([\\"])/\\$$1/g;' \
		-e '    s/\n/\\n\\\n/;' \
		-e '    print;' \
		-e '}' \
		-e 'print "\";\n";' \
		<$< >$@

###########################################################################
