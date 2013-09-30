# This makefile wrote for parallel building and testing. You will need cabal-dev
# and Haskell compiller installed on your system to use this makefile

SHELL:=/bin/bash

DRIVERDEPS := hdbi hdbi-tests
DRIVERS := hdbi-postgresql hdbi-sqlite
AUXILIARY := hdbi-conduit
ALL := $(DRIVERDEPS) $(DRIVERS) $(AUXILIARY)
GHC_OPTIONS := --ghc-options="-threaded"
DEPFLAGS := --enable-tests $(GHC_OPTIONS)
CONFLAGS := --enable-tests $(GHC_OPTIONS)
POSTGRECONNECTION := "user=test dbname=test"
RTSOPTS := +RTS -N2

BUILD_DEPS:=$(patsubst %, %_deps, $(ALL))
CLEAN:=$(patsubst %, %_clean, $(ALL))
ADD_SOURCE:=$(patsubst %, %_addsrc, $(ALL))
RETEST:=$(patsubst %, %_retest, $(ALL))

$(BUILD_DEPS):
	cd $(patsubst %_deps, %, $@) && \
	cabal install --only-dependencies $(DEPFLAGS)

install-deps: $(BUILD_DEPS)

$(CLEAN):
	cd $(patsubst %_clean, %, $@) && \
	rm -rf dist .cabal-sandbox cabal.sandbox.config

clean: $(CLEAN)

hdbi_addsrc:
	cd hdbi && \
	cabal sandbox init

hdbi-tests_addsrc:
	cd hdbi-tests && \
	cabal sandbox init && \
	cabal sandbox add-source --snapshot ../hdbi

hdbi-conduit_addsrc:
	cd hdbi-conduit && \
	cabal sandbox init && \
	cabal sandbox add-source --snapshot ../hdbi && \
	cabal sandbox add-source --snapshot ../hdbi-sqlite && \
	cabal sandbox add-source --snapshot ../hdbi-tests

$(patsubst %, %_addsrc, $(DRIVERS)):
	cd $(patsubst %_addsrc, %, $@) && \
	cabal sandbox init && \
	cabal sandbox add-source --snapshot ../hdbi && \
	cabal sandbox add-source --snapshot ../hdbi-tests


add-source: $(ADD_SOURCE)

$(RETEST): %_retest : %_addsrc

RETEST_REST := 	rm -rf dist && \
	cabal configure $(CONFLAGS) && \
	cabal build

hdbi_retest:
	cd $(patsubst %_retest, %, $@) && \
	$(RETEST_REST) && \
	dist/build/sqlvalues/sqlvalues $(RTSOPTS) && \
	dist/build/dummydriver/dummydriver $(RTSOPTS)

hdbi-tests_retest:
	cd $(patsubst %_retest, %, $@) && \
	cabal install --reinstall $(DEPFLAGS) hdbi && \
	$(RETEST_REST) && \
	cabal test

hdbi-conduit_retest:
	cd $(patsubst %_retest, %, $@) && \
	cabal install --reinstall $(DEPFLAGS) hdbi hdbi-sqlite hdbi-tests && \
	$(RETEST_REST) && \
	cabal test

hdbi-sqlite_retest:
	cd $(patsubst %_retest, %, $@) && \
	cabal install --reinstall $(DEPFLAGS) hdbi hdbi-tests && \
	$(RETEST_REST) && \
	dist/build/runtests/runtests -j1 $(RTSOPTS)

hdbi-postgresql_retest:
	cd $(patsubst %_retest, %, $@) && \
	cabal install --reinstall $(DEPFLAGS) hdbi hdbi-tests && \
	$(RETEST_REST) && \
	dist/build/runtests/runtests $(POSTGRECONNECTION) -j1 $(RTSOPTS) && \
	dist/build/puretests/puretests $(RTSOPTS)

retest: $(RETEST)

retest-drivers: $(patsubst %, %_retest, $(DRIVERS))


.PHONY: install-deps $(BTARGETS) \
	clean $(CLEAN) \
	add-source $(ADD_SOURCE) \
	retest $(RETEST) retest-drivers
