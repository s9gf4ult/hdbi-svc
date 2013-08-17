# This makefile wrote for parallel building and testing. You will need cabal-dev
# and Haskell compiller installed on your system to use this makefile

SHELL:=/bin/bash

DRIVERDEPS := hdbi hdbi-tests
DRIVERS := hdbi-postgresql hdbi-sqlite
ALL := $(DRIVERDEPS) $(DRIVERS)
DEPFLAGS := --enable-tests -p
CONFLAGS := --enable-tests -p --enable-executable-profiling
POSTGRECONNECTION := "user=test dbname=test"

BUILD_DEPS:=$(patsubst %, %_deps, $(ALL))
CLEAN:=$(patsubst %, %_clean, $(ALL))
ADD_SOURCE:=$(patsubst %, %_addsrc, $(ALL))
RETEST:=$(patsubst %, %_retest, $(ALL))

$(BUILD_DEPS):
	cd $(patsubst %_deps, %, $@) && \
	cabal-dev install-deps $(DEPFLAGS)

install-deps: $(BUILD_DEPS)

$(CLEAN):
	cd $(patsubst %_clean, %, $@) && \
	rm -rf dist cabal-dev

clean: $(CLEAN)

hdbi_addsrc:

hdbi-tests_addsrc:
	cd hdbi-tests && \
	cabal-dev add-source ../hdbi

$(patsubst %, %_addsrc, $(DRIVERS)):
	cd $(patsubst %_addsrc, %, $@) && \
	cabal-dev add-source ../hdbi && \
	cabal-dev add-source ../hdbi-tests

add-source: $(ADD_SOURCE)

$(RETEST): %_retest : %_addsrc

RETEST_REST := 	rm -rf dist && \
	cabal-dev configure $(CONFLAGS) && \
	cabal-dev build

hdbi_retest:
	cd $(patsubst %_retest, %, $@) && \
	$(RETEST_REST) && \
	dist/build/sqlvalues/sqlvalues && \
	dist/build/dummydriver/dummydriver

hdbi-tests_retest:
	cd $(patsubst %_retest, %, $@) && \
	cabal-dev install --reinstall hdbi && \
	$(RETEST_REST) && \
	cabal-dev test

hdbi-sqlite_retest:
	cd $(patsubst %_retest, %, $@) && \
	cabal-dev install --reinstall hdbi hdbi-tests && \
	$(RETEST_REST) && \
	dist/build/runtests/runtests

hdbi-postgresql_retest:
	cd $(patsubst %_retest, %, $@) && \
	cabal-dev install --reinstall hdbi hdbi-tests && \
	$(RETEST_REST) && \
	dist/build/runtests/runtests $(POSTGRECONNECTION) && \
	dist/build/puretests/puretests

retest: $(RETEST)


.PHONY: install-deps $(BTARGETS) \
	clean $(CLEAN) \
	add-source $(ADD_SOURCE) \
	retest $(RETEST)
