#/bin/bash

set -e

sudo apt update

sudo apt install -y cmake libuv1-dev liblz4-dev liblzma-dev libdouble-conversion-dev libdwarf-dev libunwind-dev \
  libaio-dev libgflags-dev libgoogle-glog-dev libgtest-dev libgmock-dev clang-format-14 clang-14 clang-tidy-14 lld-14 \
  libgoogle-perftools-dev google-perftools libssl-dev gcc-12 g++-12 libboost-all-dev build-essential

# fuse
sudo apt install meson
# wget https://github.com/libfuse/libfuse/releases/download/fuse-3.16.1/fuse-3.16.1.tar.gz
tar xzf fuse-3.16.1.tar.gz && cd fuse-3.16.1/
mkdir build && cd build
meson setup ..
ninja
sudo ninja install
cd ../../
rm -rf fuse-3.16.1/

# foundation db
# wget https://github.com/apple/foundationdb/releases/download/7.3.63/foundationdb-clients_7.3.63-1_amd64.deb
# wget https://github.com/apple/foundationdb/releases/download/7.3.63/foundationdb-server_7.3.63-1_amd64.deb
sudo apt install ./foundationdb-clients_7.3.63-1_amd64.deb
sudo apt install ./foundationdb-server_7.3.63-1_amd64.deb

# rust
export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# 3fs
# git clone https://github.com/deepseek-ai/3FS.git
# cd 3FS
# git submodule update --init --recursive
# ./patches/apply.sh

unzip 3FS-ubuntu22.zip && cd 3FS

cmake -S . -B build -DCMAKE_CXX_COMPILER=clang++-19 -DCMAKE_C_COMPILER=clang-19 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build -j $(nproc)

sudo python3 setup.py install

