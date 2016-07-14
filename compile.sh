#!/usr/bin/env sh

cd 'files'      # move into directory to set it as root of the archive
destination='../bin'
mkdir -p "${destination}"
zip -9 -r "${destination}/yet-another-tetris-like-game.love" .
