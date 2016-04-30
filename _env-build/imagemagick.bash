#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

#${CMD_PRE} apt-get install build-essential;
#${CMD_PRE} apt-get build-dep imagemagick;
#${CMD_PRE} apt-get install libautotrace3 libautotrace-dev autotrace ghostscript gsfonts libgs-dev pslib1 libopenjpeg-dev libopenjp2-7-dev libjxr-dev libhpdf-dev libfreeimage-dev libwebp-dev libexif-dev libjasper-dev libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev libgd-dev libpng12-dev libpng++-dev libpnglite-dev libfftw3-dev libfftw3-quad3 libgxps-dev libgxps-utils liblcms2-dev liblcms2-utils gir1.2-rsvg-2.0 libgc1c2 libgraphviz-dev libgsl0ldbl libgtkspell0 liblqr-1-0-dev libnetpbm10 libplot-dev libplot2c2 librsvg2-dev libwmf-bin libwmf-dev libxaw7-dev libxdot4 libxmu-dev libxmu-headers netpbm checkinstall automake autoconf libtool pkg-config checkinstall;

RT_ENV_MAKE_ENTER_DIR=true

RT_COMMANDS_ACT=(
    "rm -fr $HOME/opt/imagemagick/ ImageMagick-$RT_ENV_MAKE_VER_IMAGE_MAGIK/ ImageMagick-$RT_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz"
    "mkdir -p $HOME/opt/imagemagick/"
    "${BIN_CURL} -o ImageMagick-$RT_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz http://www.imagemagick.org/download/ImageMagick-$RT_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz"
    "tar xzf ImageMagick-$RT_ENV_MAKE_VER_IMAGE_MAGIK.tar.gz --strip-components=1"
    "./configure --with-autotrace --with-webp --with-rsvg --with-gslib --with-jbig --with-jpeg --with-jp2 --enable-hdri --with-quantum-depth=32 --with-modules --with-fftw --without-perl --prefix=$HOME/opt/imagemagick/"
    "make -j 4"
    "make install"
);

# EOF #
