#!/bin/bash

# Symlink in the tars.
if [ $ROOT != $BASE ]; then
    for i in $ROOT/tars/*; do
        i=$(basename $i)

        if [ ! -e $BASE/tars/$i ]; then
            ln -s $ROOT/tars/$i $BASE/tars/$i
        fi
    done
fi

# Build the dependencies.
pushd $BASE
./all.sh
popd


link () {
    if [ ! -L $2 ]; then
        ln -s $1 $2
    fi
}

pushd $BASE/renpy

# Update the README.
cp /home/tom/ab/renpy-deps/scripts/README.nightly /home/tom/ab/WWW.nightly/README.txt

# Activate the virtualenv for the prebuild.
. /home/tom/.virtualenvs/nightlyrenpy/bin/activate

# Run the after checkout script.
# ./after_checkout.sh

link $BASE/pygame_sdl2 pygame_sdl2
link /home/tom/ab/WWW.nightly dl
link /home/tom/ab/renpy/atom atom
link /home/tom/ab/renpy/jedit jedit
link /home/tom/ab/renpy/editra editra

# Rapt is needed to run distribute.py.
mkdir -p rapt
link /home/tom/ab/android/buildlib rapt/buildlib


# Figure out a reasonable version name.
REV=$(git rev-parse --short HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

export RENPY_NIGHTLY="nightly-$(date +%Y-%m-%d)-$REV"

# Generate source.

export RENPY_CYTHON=cython
export RENPY_DEPS_INSTALL=/usr::/usr/lib/x86_64-linux-gnu/
export RENPY_SIMPLE_EXCEPTIONS=1

./renpy.sh tutorial quit

# Build the documentation.
# pushd $BASE/renpy/sphinx
# ./build.sh
# popd

# Build the distribution.
./lib/linux-x86_64/python -O distribute.py "$RENPY_NIGHTLY" --pygame $BASE/pygame_sdl2 $DISTRIBUTE_ARGS

popd
