# -*- mode: makefile-gmake -*-

OS := $(shell uname)

# Do not forget to bump SOMINOR when changing VERSION,
# and SOMAJOR when breaking ABI in a backward-incompatible way
VERSION = 0.4
SOMAJOR = 1
SOMINOR = 0

DESTDIR =
prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
includedir = $(prefix)/include

FC = gfortran
# CFLAGS_add and FFLAGS_add are flags that we always want to include
# They are not overridable by the user, whereas CFLAGS and FFLAGS are
# simply defaults and are overridable via environment variables or
# `make CFLAGS="foo"` on the command line

FFLAGS = -O3
CFLAGS = -std=c99 -Wall -O3
CPPFLAGS =

override FFLAGS_add =
override CFLAGS_add =
override CPPFLAGS_add =

USEGCC = 1
USECLANG = 0

ifeq ($(OS), Darwin)
USEGCC = 0
USECLANG = 1
endif

AR = ar

ifeq ($(USECLANG),1)
USEGCC = 0
CC = clang
override CFLAGS_add += -fno-builtin
endif

ifeq ($(USEGCC),1)
CC = gcc
override CFLAGS_add += -fno-gnu89-inline -std=c99
endif

ARCH := $(shell $(CC) -dumpmachine | sed "s/\([^-]*\).*$$/\1/")
ifeq ($(ARCH),mingw32)
$(error "the mingw32 compiler you are using fails the openblas testsuite. please see the Julia README.windows.md document for a replacement")
endif

ifeq ($(USE_OPENLIBM),1)
override CPPFLAGS_add += -DUSE_OPENLIBM -I$(includedir) -I$(includedir)/openlibm/
endif

default: all

%.c.o: %.c
	$(CC) $(CPPFLAGS) $(CPPFLAGS_add) $(CFLAGS_add) $(CFLAGS) -c $< -o $@

%.f.o: %.f
	$(FC) $(FFLAGS) $(FFLAGS_add) -c $< -o $@

%.S.o: %.S
	$(CC) $(SFLAGS) $(filter -m% -B% -I% -D%,$(CFLAGS_add)) -c $< -o $@

# OS-specific stuff
ifeq ($(ARCH),i386)
override ARCH := i387
endif
ifeq ($(ARCH),i486)
override ARCH := i387
endif
ifeq ($(ARCH),i686)
override ARCH := i387
endif

ifeq ($(ARCH),x86_64)
override ARCH := amd64
endif 

ifneq (,$(findstring MINGW,$(OS)))
override OS=WINNT
endif

#keep these if statements separate
ifeq ($(OS), WINNT)
SHLIB_EXT = dll
SONAME_FLAG = -soname
override CFLAGS_add += -nodefaultlibs
override FFLAGS_add += -nodefaultlibs
shlibdir = $(bindir)
else
shlibdir = $(libdir)
endif

ifeq ($(OS), Linux)
SHLIB_EXT = so
SONAME_FLAG = -soname
override CFLAGS_add += -fPIC
override FFLAGS_add += -fPIC
endif

ifeq ($(OS), FreeBSD)
SHLIB_EXT = so
SONAME_FLAG = -soname
override CFLAGS_add += -fPIC
override FFLAGS_add += -fPIC
endif

ifeq ($(OS), Darwin)
SONAME_FLAG = -install_name
SHLIB_EXT = dylib
override CFLAGS_add += -fPIC
override FFLAGS_add += -fPIC
endif
