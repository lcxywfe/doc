## meta node
### click-house
* `docker pull ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/clickhouse:25.3.1.2703-ubuntu22.04`
* `docker run -d --network=host --name clickhouse-server --ulimit nofile=262144:262144 ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/clickhouse:25.3.1.2703-ubuntu22.04`

### foundation db
* `docker pull ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/fdb:7.3.63-ubuntu22.04`
* `docker run -d --network=host --name fdb ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/fdb:7.3.63-ubuntu22.04`

### monitor
* `docker pull ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04`
* `docker run -d --network=host --name monitor --ulimit memlock=-1 --privileged --device=/dev/infiniband/uverbs0 --device=/dev/infiniband/rdma_cm ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04 ./monitor.sh`

### mgmtd
* `docker run -d --network=host --name mgmtd --ulimit memlock=-1 --privileged --device=/dev/infiniband/uverbs0 --device=/dev/infiniband/rdma_cm --env FDB_CLUSTER=`docker exec fdb cat /etc/foundationdb/fdb.cluster` --env REMOTE_IP="192.168.0.72:10000" --env MGMTD_SERVER_ADDRESSES="RDMA://192.168.0.72:8000" ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04 ./mgmtd.sh`
  * `REMOTE_IP`
  * `MGMTD_SERVER_ADDRESSES`

### meta
* `docker run -d --network=host --name meta --ulimit memlock=-1 --privileged --device=/dev/infiniband/uverbs0 --device=/dev/infiniband/rdma_cm --env FDB_CLUSTER=`docker exec fdb cat /etc/foundationdb/fdb.cluster` --env META_NODE_ID=100 --env REMOTE_IP="192.168.0.72:10000" --env MGMTD_SERVER_ADDRESSES="RDMA://192.168.0.72:8000" ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04 ./meta.sh`
  * `META_NODE_ID`
  * `REMOTE_IP`
  * `MGMTD_SERVER_ADDRESSES`

## storage node
### prepare storage docker
* `docker pull ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04`
* `docker run --name 3fs-tmp -it ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04`
  * `vim /opt/3fs/etc/storage_main.toml`
  * set `enable_io_uring = false`
* `docker commit 3fs-tmp ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04-no-io-uring`

### mount disk
* `mkfs.xfs -L data0 /dev/nvme0n1`
* `mount -o noatime,nodiratime -L data0 /nvme0`
* `mkfs.xfs -L data1 /dev/nvme1n1`
* `mount -o noatime,nodiratime -L data1 /nvme1`
* ...

### storage
* `docker run -d --network=host --name storage --ulimit memlock=-1 --privileged -v /nvme0:/nvme0 -v /nvme1:/nvme1 -v /nvme2:/nvme2 -v /nvme3:/nvme3 -v /nvme4:/nvme4 -v /nvme5:/nvme5 -v /nvme6:/nvme6 -v /nvme7:/nvme7 --device=/dev/infiniband/uverbs0 --device=/dev/infiniband/rdma_cm --env STORAGE_NODE_ID=10001 --env TARGET_PATHS="/nvme1","/nvme2","/nvme3","/nvme4","/nvme5","/nvme6","/nvme7" --env REMOTE_IP="192.168.0.72:10000" --env MGMTD_SERVER_ADDRESSES="RDMA://192.168.0.72:8000" ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04-no-io-uring ./storage.sh`
  * `-v`
  * `TARGET_PATHS`
  * `STORAGE_NODE_ID`
  * `REMOTE_IP`
  * `MGMTD_SERVER_ADDRESSES`

## meta node
* `docker exec --env STORAGE_NODE_NUM=4 --env STORAGE_NODE_BEGIN=10001 --env STORAGE_NODE_END=10004 --env REPLICATION_FACTOR=3 --env NUM_DISKS_PER_NODE=8 --env MGMTD_SERVER_ADDRESSES="RDMA://192.168.0.72:8000" meta ./config_3fs.sh`
  * `STORAGE_NODE_NUM`
  * `STORAGE_NODE_BEGIN`
  * `STORAGE_NODE_END`
  * `REPLICATION_FACTOR`
  * `NUM_DISKS_PER_NODE`
  * `MGMTD_SERVER_ADDRESSES`
  * `NUM_TARGETS_PER_DISK` default 12
  * `MIN_TARGETS_PER_DISK` default 12
* save token
 
## client
### use 3fs docker
* `docker run -d --network=host --name fuse --shm-size=200g --ulimit memlock=-1 --privileged --device=/dev/infiniband/uverbs0 --device=/dev/infiniband/rdma_cm --env REMOTE_IP="192.168.0.72:10000" --env MGMTD_SERVER_ADDRESSES="RDMA://192.168.0.72:8000" --env TOKEN="AAD+ioV78QDeStEe2wCnbOhW" ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/3fs:b71ffc55-fdb7.3.63-fuse3.16.2-ubuntu22.04 ./fuse.sh`
  * `--shm-size`
  * `REMOTE_IP`
  * `MGMTD_SERVER_ADDRESSES`
  * `TOKEN`

### custom
#### mount dir
* [install dependencies](https://github.com/deepseek-ai/3FS/blob/main/README.md#install-dependencies)
* `git clone https://github.com/deepseek-ai/3FS.git`
* [build 3fs](https://github.com/deepseek-ai/3FS/blob/main/README.md#build-3fs)
* `mkdir -p /opt/3fs/{bin,etc}`
* `cp ~/3fs/build/bin/hf3fs_fuse_main /opt/3fs/bin`
* `cp ~/3fs/configs/{hf3fs_fuse_main_launcher.toml,hf3fs_fuse_main.toml,hf3fs_fuse_main_app.toml} /opt/3fs/etc`
* save token to `/opt/3fs/etc/token.txt`
* edit `hf3fs_fuse_main_launcher.toml`
  ```
  cluster_id = "stage"
  mountpoint = '/3fs'
  token_file = '/opt/3fs/etc/token.txt'
  [mgmtd_client]
  mgmtd_server_addresses = ["RDMA://192.168.0.72:8000"]
  ```
* edit `hf3fs_fuse_main.toml`
  ```
  [mgmtd]
  mgmtd_server_addresses = ["RDMA://192.168.0.72:8000"]
  [common.monitor.reporters.monitor_collector]
  remote_ip = "192.168.0.72:10000"
  ```
* needless if run 3fs fuse image first
  ~~`/opt/3fs/bin/admin_cli -cfg /opt/3fs/etc/admin_cli.toml --config.mgmtd_client.mgmtd_server_addresses '["RDMA://192.168.0.72:8000"]' "set-config --type FUSE --file /opt/3fs/etc/hf3fs_fuse_main.toml"`~~
* `mkdir -p /3fs/`
* `cp ~/3fs/deploy/systemd/hf3fs_fuse_main.service /usr/lib/systemd/system`
* `systemctl start hf3fs_fuse_main`
* `df -hT | grep 3fs`

#### python
* `python3 setup.py install`
* [demo](https://github.com/deepseek-ai/3FS/blob/main/hf3fs_fuse/fuse_demo.py)
