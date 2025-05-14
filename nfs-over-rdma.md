### Server
* Download ofed driver from https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/
* `sudo ./mlnxofedinstall --add-kernel-support --with-nfsrdma`
* `echo "rdma 20049" | sudo tee -a /proc/fs/nfsd/portlist`
* Edit /etc/nfs.conf
  > rdma=y  
  > rdma-port=20049
* Edit /etc/exports
  > /nvme/data0 10.10.10.0/24(ro,sync,no_root_squash)  
  > /nvme/data1 10.10.10.0/24(ro,sync,no_root_squash)  
  > /nvme/data2 10.10.10.0/24(ro,sync,no_root_squash)  
  > /nvme/data3 10.10.10.0/24(ro,sync,no_root_squash)
* `echo 2048 | sudo tee /sys/block/hptblock0n0p/queue/read_ahead_kb (optional)`
* `sudo systemctl restart opensm`
* `sudo modprobe xprtrdma`
* `sudo systemctl restart nfs-server`

### Client
* Download ofed driver from https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/
* `sudo ./mlnxofedinstall --add-kernel-support --with-nfsrdma`
* `mkdir -p /nvme/data0`
* `mkdir -p /nvme/data1`
* `mkdir -p /nvme/data2`
* `mkdir -p /nvme/data3`
* `sudo mount -o rdma,port=20049,vers=4.1,rsize=1048576,wsize=1048576,noatime 10.10.10.72:/nvme/data0 /nvme/data0`
* `sudo mount -o rdma,port=20049,vers=4.1,rsize=1048576,wsize=1048576,noatime 10.10.10.72:/nvme/data1 /nvme/data1`
* `sudo mount -o rdma,port=20049,vers=4.1,rsize=1048576,wsize=1048576,noatime 10.10.10.72:/nvme/data2 /nvme/data2`
* `sudo mount -o rdma,port=20049,vers=4.1,rsize=1048576,wsize=1048576,noatime 10.10.10.72:/nvme/data3 /nvme/data3`
