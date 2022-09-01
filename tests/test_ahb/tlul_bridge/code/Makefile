TOPLEVEL_LANG ?= verilog

ifneq ($(TOPLEVEL_LANG),verilog)

all:
	@echo "Skipping test due to TOPLEVEL_LANG=$(TOPLEVEL_LANG) not being verilog"
clean::

else

TOPLEVEL := test_harness

PWD=$(shell pwd)

COCOTB?=$(PWD)/../../../..
RTL=$(COCOTB)/rtl

ifeq ($(SIM),verilator)
EXTRA_ARGS += --trace --trace-structs --trace-fst -O3
endif

VERILOG_SOURCES += $(RTL)/Default_pkg.sv
VERILOG_SOURCES += $(RTL)/AHB_pkg.sv
VERILOG_SOURCES += $(RTL)/TileLinkUL_pkg.sv
VERILOG_SOURCES += $(RTL)/AHB_TileLinkUL_Same_Size_Bridge.sv
VERILOG_SOURCES += $(RTL)/AHB_TileLinkUL_Bridge.sv
VERILOG_SOURCES += $(COCOTB)/tests/test_ahb/tlul_bridge/rtl/test_harness.sv

include $(shell cocotb-config --makefiles)/Makefile.sim

endif

MODULE = 'test_TLUL_bridge'
