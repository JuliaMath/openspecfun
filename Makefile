OPENLIBM_HOME=$(abspath .)
include ./Make.inc

SUBDIRS = amos Faddeeva

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

all: libopenspecfun.a libopenspecfun.$(SHLIB_EXT) 
libopenspecfun.a: $(OBJS)
	$(AR) -rcs libopenspecfun.a $(OBJS)
libopenspecfun.$(SHLIB_EXT): $(OBJS)
ifeq ($(OS),WINNT)
	$(FC) -shared $(OBJS) $(LDFLAGS) -Wl,$(SONAME_FLAG),libopenspecfun.$(SHLIB_EXT) -o libopenspecfun.$(SHLIB_EXT)
else
	$(FC) -shared $(OBJS) $(LDFLAGS) -Wl,$(SONAME_FLAG),libopenspecfun.$(SHLIB_EXT).$(word 1,$(VERSION_SPLIT)) -o libopenspecfun.$(SHLIB_EXT).$(VERSION)
	ln -s libopenspecfun.$(SHLIB_EXT).$(VERSION) libopenspecfun.$(SHLIB_EXT).$(word 1,$(VERSION_SPLIT)).$(word 2,$(VERSION_SPLIT))
	ln -s libopenspecfun.$(SHLIB_EXT).$(VERSION) libopenspecfun.$(SHLIB_EXT).$(word 1,$(VERSION_SPLIT))
	ln -s libopenspecfun.$(SHLIB_EXT).$(VERSION) libopenspecfun.$(SHLIB_EXT)
endif

install: all
	mkdir -p $(DESTDIR)$(shlibdir)
	mkdir -p $(DESTDIR)$(libdir)
	mkdir -p $(DESTDIR)$(includedir)
	cp -a libopenspecfun.$(SHLIB_EXT)* $(DESTDIR)$(shlibdir)/
	cp -a libopenspecfun.a $(DESTDIR)$(libdir)/
	cp -a Faddeeva/Faddeeva.h $(DESTDIR)$(includedir)

clean:
	@for dir in Faddeeva amos .; do \
		rm -fr $$dir/*.o $$dir/*.a $$dir/*.$(SHLIB_EXT)*; \
	done

distclean: clean
