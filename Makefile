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
	$(FC) -shared $(OBJS) $(LDFLAGS) -Wl,-soname,libopenspecfun.$(SHLIB_EXT).$(VERSION) -o libopenspecfun.$(SHLIB_EXT).$(VERSION)
	ln -s libopenspecfun.$(SHLIB_EXT).$(VERSION) libopenspecfun.$(SHLIB_EXT).$(firstword $(subst ., , $(VERSION)))
	ln -s libopenspecfun.$(SHLIB_EXT).$(VERSION) libopenspecfun.$(SHLIB_EXT)

install: all
	for subdir in lib include; do \
		mkdir -p $(DESTDIR)$(PREFIX)/$$subdir; \
	done

	cp -a libopenspecfun.$(SHLIB_EXT)* libopenspecfun.a $(DESTDIR)$(PREFIX)/lib
	cp -a Faddeeva/Faddeeva.h $(DESTDIR)$(PREFIX)/include/

clean:
	@for dir in Faddeeva amos .; do \
		rm -fr $$dir/*.o $$dir/*.a $$dir/*.$(SHLIB_EXT); \
	done

distclean: clean
