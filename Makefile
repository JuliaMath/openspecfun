OPENLIBM_HOME=$(abspath .)
include ./Make.inc

SUBDIRS = amos Faddeeva rem_pio2

define INC_template
TEST=test
override CUR_SRCS = $(1)_SRCS
include $(1)/Make.files
SRCS += $$(addprefix $(1)/,$$($(1)_SRCS))
endef

DIR=test

$(foreach dir,$(SUBDIRS),$(eval $(call INC_template,$(dir))))

DUPLICATE_NAMES = $(filter $(patsubst %.S,%,$($(ARCH)_SRCS)),$(patsubst %.c,%,$(src_SRCS)))
DUPLICATE_SRCS = $(addsuffix .c,$(DUPLICATE_NAMES))

OBJS =  $(patsubst %.f,%.f.o,\
	$(patsubst %.S,%.S.o,\
	$(patsubst %.c,%.c.o,$(filter-out $(addprefix src/,$(DUPLICATE_SRCS)),$(SRCS)))))

# If we're on windows, don't do versioned shared libraries.  If we're on OSX,
# put the version number before the .dylib.  Otherwise, put it after.
ifeq ($(OS), WINNT)
OSF_MAJOR_MINOR_SHLIB_EXT := $(SHLIB_EXT)
else
ifeq ($(OS), Darwin)
OSF_MAJOR_MINOR_SHLIB_EXT := $(SOMAJOR).$(SOMINOR).$(SHLIB_EXT)
OSF_MAJOR_SHLIB_EXT := $(SOMAJOR).$(SHLIB_EXT)
else
OSF_MAJOR_MINOR_SHLIB_EXT := $(SHLIB_EXT).$(SOMAJOR).$(SOMINOR)
OSF_MAJOR_SHLIB_EXT := $(SHLIB_EXT).$(SOMAJOR)
endif
endif

all: libopenspecfun.a libopenspecfun.$(OSF_MAJOR_MINOR_SHLIB_EXT)
libopenspecfun.a: $(OBJS)
	$(AR) -rcs libopenspecfun.a $(OBJS)
libopenspecfun.$(OSF_MAJOR_MINOR_SHLIB_EXT): $(OBJS)
	$(FC) -shared $(OBJS) $(LDFLAGS) $(LDFLAGS_add) -Wl,$(SONAME_FLAG),libopenspecfun.$(OSF_MAJOR_SHLIB_EXT) -o $@
ifneq ($(OS),WINNT)
	ln -sf $@ libopenspecfun.$(OSF_MAJOR_SHLIB_EXT)
	ln -sf $@ libopenspecfun.$(SHLIB_EXT)
endif

install: all
	mkdir -p $(DESTDIR)$(shlibdir)
	mkdir -p $(DESTDIR)$(libdir)
	mkdir -p $(DESTDIR)$(includedir)
	cp -a libopenspecfun.*$(SHLIB_EXT)* $(DESTDIR)$(shlibdir)/
	cp -a libopenspecfun.a $(DESTDIR)$(libdir)/
	cp -a Faddeeva/Faddeeva.h $(DESTDIR)$(includedir)

clean:
	@for dir in $(SUBDIRS) .; do \
		rm -fr $$dir/*.o $$dir/*.a $$dir/*.$(SHLIB_EXT)*; \
	done

distclean: clean
