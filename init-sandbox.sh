#! /bin/sh

cabal sandbox init
cabal sandbox add-source deps/gamenumber
cabal sandbox add-source deps/free-game
#cabal sandbox add-source deps/colors
