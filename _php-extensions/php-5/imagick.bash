#!/usr/bin/env bash

##
# This file is part of `src-run/usr-src-builder`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

_MOD_NAME="imagick"
_MOD_PECL_DL=true
_MOD_PECL_DL_NAME="imagick-3.4.0RC4.tgz"
_MOD_PECL_FLAGS="--with-imagick=$HOME/opt/imagemagick/ --with-libdir=$HOME/opt/imagemagick/lib/ImageMagick-${_BLD_ENV_MAKE_VER_IMAGE_MAGIK}/modules-Q32HDRI/filters"

# EOF
