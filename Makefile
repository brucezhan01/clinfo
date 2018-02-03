# Headers

# FPGA: XILINX, ALTERA
FPGA = XILINX

# Altera FPGA board: s10_ref, nalla_pcie
FPGA_BOARD = 

HDR =	src/error.h \
	src/ext.h \
	src/fmtmacros.h \
	src/memory.h \
	src/ms_support.h \
	src/strbuf.h

VPATH = src

CFLAGS += -std=c99 -g -Wall -Wextra -pedantic

SPARSE ?= sparse
SPARSEFLAGS=-Wsparse-all -Wno-decl

# BSD make does not define RM
RM ?= rm -f

ifeq ($(FPGA), ALTERA)
CFLAGS += -I$(ALTERAOCLROOT)/host/include
LDLIBS = -L$(ALTERAOCLROOT)/board/$(FPGA_BOARD)/linux64/lib -L$(ALTERAOCLROOT)/host/linux64/lib -Wl,--no-as-needed -lOpenCL -ldl -lalteracl -lalterahalmmd

ifeq ($(FPGA_BOARD), s10_ref)
LDLIBS += -laltera_s10_ref_mmd
else ifeq ($(FPGA_BOARD), nalla_pcie)
LDLIBS += -lnalla_pcie_mmd
endif

else ifeq ($(FPGA), XILINX)
CFLAGS += -I$(XILINX_SDX)/runtime/include/1_2
LDLIBS = -L$(XILINX_SDX)/runtime/lib/x86_64 -Wl,--no-as-needed -lOpenCL -lxilinxopencl -ldl

else
#CFLAGS +=
LDLIBS = -lOpenCL -ldl

endif

# OS-specific library includes
LDLIBS_Darwin = -framework OpenCL
LDLIBS_Darwin_exclude = -lOpenCL

LDLIBS += $(LDLIBS_${OS})

# Remove -lOpenCL if OS is Darwin
LDLIBS := $(LDLIBS:$(LDLIBS_${OS}_exclude)=)

clinfo: clinfo.o

clinfo.o: clinfo.c $(HDR)

clean:
	$(RM) clinfo.o clinfo

sparse: clinfo.c
	$(SPARSE) $(CPPFLAGS) $(CFLAGS) $(SPARSEFLAGS) $^

.PHONY: clean sparse
