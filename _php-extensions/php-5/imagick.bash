#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

MOD_NAME="imagick"
MOD_PECL_DL=true
MOD_PECL_DL_NAME="imagick-3.4.0RC4.tgz"
MOD_PECL_FLAGS="--with-imagick=$HOME/opt/imagemagick/ --with-libdir=$HOME/opt/imagemagick/lib/ImageMagick-${BLD_ENV_MAKE_VER_IMAGE_MAGIK}/modules-Q32HDRI/filters"

# EOF
