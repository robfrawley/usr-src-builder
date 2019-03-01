#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

#${_CMD_PRE} apt-get install build-essential;
#${_CMD_PRE} apt-get build-dep imagemagick;
#${_CMD_PRE} apt-get install libautotrace3 libautotrace-dev autotrace ghostscript gsfonts libgs-dev pslib1 libopenjpeg-dev libopenjp2-7-dev libjxr-dev libhpdf-dev libfreeimage-dev libwebp-dev libexif-dev libjasper-dev libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev libgd-dev libpng12-dev libpng++-dev libpnglite-dev libfftw3-dev libfftw3-quad3 libgxps-dev libgxps-utils liblcms2-dev liblcms2-utils gir1.2-rsvg-2.0 libgc1c2 libgraphviz-dev libgsl0ldbl libgtkspell0 liblqr-1-0-dev libnetpbm10 libplot-dev libplot2c2 librsvg2-dev libwmf-bin libwmf-dev libxaw7-dev libxdot4 libxmu-dev libxmu-headers netpbm checkinstall automake autoconf libtool pkg-config checkinstall;

_RUN_CMD_WORKING_PATH=true

_RUN_ACTION_INSTRUCTIONS_CMD=(
    "rm -fr $HOME/opt/imagemagick/ ImageMagick-$_BLD_ENV_MAKE_VER_IMAGE_MAGIK/ ImageMagick-$_BLD_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz"
    "mkdir -p $HOME/opt/imagemagick/"
    "${_BIN_CURL} -o ImageMagick-$_BLD_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz http://www.imagemagick.org/download/ImageMagick-$_BLD_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz"
    "tar xzf ImageMagick-$_BLD_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz --strip-components=1"
    "./configure --with-autotrace --with-webp --with-rsvg --with-gslib --with-jbig --with-jpeg --with-jp2 --enable-hdri --with-quantum-depth=32 --with-modules --with-fftw --without-perl --prefix=$HOME/opt/imagemagick/"
    "make -j 4"
    "make install"
);

