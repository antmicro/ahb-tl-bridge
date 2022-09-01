export PYTHONWARNINGS = error,ignore::DeprecationWarning:distutils,ignore::DeprecationWarning:site

regression_tests :=  $(shell ls test_ahb/)

.PHONY: $(regression_tests)

SIM?=verilator

all: $(regression_tests)

$(regression_tests):
	cd test_ahb/$@/code && $(MAKE) SIM=$(SIM)



clean:
	$(foreach TEST, $(regression_tests), $(MAKE) -C test_ahb/$(TEST)/code clean;)

regression:
	$(foreach TEST, $(regression_tests), $(MAKE) -C test_ahb/$(TEST)/code regression;)
