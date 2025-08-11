#/bin/bash

set -e

[ "$(id -u)" -eq 0 ] && dnf install sudo -y

sudo dnf install -y epel-release
sudo dnf install -y wget
sudo dnf install -y cmake
sudo dnf install -y lz4-devel
sudo dnf install -y xz-devel
sudo dnf install -y libdwarf-devel
sudo dnf install -y libunwind-devel
sudo dnf install -y libaio-devel
sudo dnf install -y gflags-devel
sudo dnf install -y glog-devel
sudo dnf install -y gtest-devel
sudo dnf install -y gmock-devel
sudo dnf install -y clang-tools-extra
sudo dnf install -y clang
sudo dnf install -y lld
sudo dnf install -y gperftools-devel
sudo dnf install -y gperftools
sudo dnf install -y gcc
sudo dnf install -y gcc-c++
sudo dnf install -y boost-devel

sudo dnf config-manager --set-enabled crb
sudo dnf install -y libuv-devel
sudo dnf install -y double-conversion-devel

sudo dnf install -y libevent libevent-devel

sudo systemctl restart sshd

# fuse
sudo dnf install -y meson
# wget https://github.com/libfuse/libfuse/releases/download/fuse-3.16.1/fuse-3.16.1.tar.gz
tar xzf fuse-3.16.1.tar.gz && cd fuse-3.16.1/
mkdir build && cd build
meson setup ..
ninja
sudo ninja install
cd ../../
rm -rf fuse-3.16.1/

# foundation db
# wget https://github.com/apple/foundationdb/releases/download/7.3.63/foundationdb-clients-7.3.63-1.el7.x86_64.rpm
# wget https://github.com/apple/foundationdb/releases/download/7.3.63/foundationdb-server-7.3.63-1.el7.x86_64.rpm
sudo dnf install -y foundationdb-clients-7.3.63-1.el7.x86_64.rpm
sudo dnf install -y foundationdb-server-7.3.63-1.el7.x86_64.rpm

# rust
export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# 3fs
sudo dnf install -y git
sudo dnf install -y unzip
sudo dnf install -y autoconf
sudo dnf install -y numactl-devel
sudo dnf install -y python3-devel
sudo dnf install -y rdma-core-devel
[ -f /usr/lib64/libatomic.so ] || ln -s /usr/lib64/libatomic.so.1.2.0 /usr/lib64/libatomic.so

unzip 3FS-clang-19.zip
cd 3FS
cmake -S . -B build -DCMAKE_CXX_COMPILER=clang++-19 -DCMAKE_C_COMPILER=clang-19 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build -j $(nproc)

CMAKE_BUILD_PARALLEL_LEVEL=$(nproc) sudo python3 setup.py install

