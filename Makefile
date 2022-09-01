.PHONY: all
all: test

SIM?=verilator

test:
	$(MAKE) -k -C tests SIM=$(SIM)

clean:
	-@find . -name "obj" | xargs rm -rf
	-@find . -name "*.pyc" | xargs rm -rf
	-@find . -name "*results.xml" | xargs rm -rf
	$(MAKE) -C tests clean

