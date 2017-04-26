OBJDIR=Work
VERSION=1.2.0
WORK=wb_handler
PKG=$(WORK)-$(VERSION)
GHDL=ghdl
GHDL_FLAGS=-P../utils/Work/ --work=$(WORK) --workdir=$(OBJDIR)

vpath %.o $(OBJDIR)

all: lib test

lib: $(OBJDIR) wb_handler.o

%.o: %.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<

%.o: testbench/%.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<

$(OBJDIR):
	mkdir $(OBJDIR)

clean:
	-rm -r $(OBJDIR)

wb_handler.o: wb_handler_pkg.o
wb_dummy_tb.o: wb_dummy.o wb_handler_pkg.o
wb_dummy.o: wb_handler_pkg.o

$(OBJDIR)/wb_dummy_tb: wb_dummy_tb.o
	$(GHDL) -e $(GHDL_FLAGS) -o $@ $(@F)

test: $(OBJDIR)/wb_dummy_tb
	$< --ieee-asserts=disable-at-0 --wave=$<.ghw

tarball:
	-mkdir $(WORK) 2> /dev/null
	-mkdir $(WORK)/testbench 2> /dev/null
	cp *.vhdl Makefile LEEME.txt README.txt $(WORK)
	cp testbench/*.vhdl $(WORK)/testbench
	cp /usr/share/common-licenses/GPL $(WORK)/LICENSE
	tar zcvf ../$(PKG).tar.gz $(WORK)
	rm -r $(WORK)

