#!/bin/bash

DIR="$( dirname "${BASH_SOURCE[0]}" )"
cd $DIR
sudo rm -r build
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
sudo make install
