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
	$(FC) -shared $(OBJS) $(LDFLAGS) -o libopenspecfun.$(SHLIB_EXT)

clean:
	rm -fr {Faddeeva,amos,.}/*{.o,.a,.$(SHLIB_EXT),~}

distclean:
	rm -f $(OBJS) *.a *.$(SHLIB_EXT)
