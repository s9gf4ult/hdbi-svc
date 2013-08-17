hdbi-svc
========

repository for maintainance of HDBI

how to use 
==========

after git clone you will need to checkout submodules with 
`git submodule update` command. Then execute 

```
make add-source
make -j3 install-deps
make retest
```

add-source target perform `cabal-dev add-source` command for each repository. For example 

```
cabal-dev add-source ../hdbi
cabal-dev add-source ../hdbi-tests 
```

will be performed for for hdbi-sqlite, because hdbi and hdbi-tests is direct dependencies of hdbi-sqlite. If you want to build hdbi-sqlite with just modified hdbi but not with hdbi from the Hackage, then you will need `add-source`

install-deps target execute `cabal-dev install-deps` in each submodule.

retest target rebuild direct dependencies (hdbi and hdbi-tests for hdbi-sqlite), then rebuild the project and execute tests.

There is also configuration variables in Makefile, 
like DEPFLAGS, CONFLAGS, POSTGRECONNECTION
