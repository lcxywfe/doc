#/bin/bash

set -e

sudo rm -rf /opt/3fs/

sudo mkdir -p /opt/3fs/{bin,etc}
sudo cp build/bin/hf3fs_fuse_main /opt/3fs/bin
sudo cp configs/{hf3fs_fuse_main_launcher.toml,hf3fs_fuse_main.toml,hf3fs_fuse_main_app.toml} /opt/3fs/etc

sudo echo ${TOKEN} >/opt/3fs/etc/token.txt
sudo sed -i "s/^cluster_id.*/cluster_id = \"${CLUSTER_ID:-stage}\"/" /opt/3fs/etc/*
sudo sed -i "s|mgmtd_server_addresses = \[\]|mgmtd_server_addresses = [\"${MGMTD_SERVER_ADDRESSES//,/\",\"}\"]|g" /opt/3fs/etc/hf3fs_fuse_main_launcher.toml
sudo sed -i "s|mountpoint = ''|mountpoint = '/3fs'|g" /opt/3fs/etc/hf3fs_fuse_main_launcher.toml
sudo sed -i "s|token_file = ''|token_file = '/opt/3fs/etc/token.txt'|g" /opt/3fs/etc/hf3fs_fuse_main_launcher.toml
sudo sed -i "s|remote_ip = ''|remote_ip = \"${REMOTE_IP}\"|g" /opt/3fs/etc/hf3fs_fuse_main.toml
sudo sed -i "s|mgmtd_server_addresses = \[\]|mgmtd_server_addresses = [\"${MGMTD_SERVER_ADDRESSES//,/\",\"}\"]|g" /opt/3fs/etc/hf3fs_fuse_main.toml

sudo mkdir -p /3fs/
sudo cp deploy/systemd/hf3fs_fuse_main.service /usr/lib/systemd/system
sudo systemctl start hf3fs_fuse_main
df -hT | grep 3fs
