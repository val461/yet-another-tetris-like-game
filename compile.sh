#!/usr/bin/env sh

cd 'files'      # move into directory to set it as root of the archive
destination='../bin'
mkdir -p "${destination}"
zip -9 -r "${destination}/tetris-clone-0.1.0.love" .
