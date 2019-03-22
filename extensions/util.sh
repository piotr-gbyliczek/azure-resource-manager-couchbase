#!/usr/bin/env bash

adjustTCPKeepalive ()
{
# Azure public IPs have some odd keep alive behaviour

echo "Setting TCP keepalive..."
sysctl -w net.ipv4.tcp_keepalive_time=120

echo "Setting TCP keepalive permanently..."
echo "net.ipv4.tcp_keepalive_time = 120
" >> /etc/sysctl.conf
}

formatDataDisk ()
{
# This script formats and mounts the drive on lun0 as /datadisk

DISK="/dev/disk/azure/scsi1/lun0"
PARTITION="/dev/disk/azure/scsi1/lun0-part1"
MOUNTPOINT="/datadisk"

echo "Partitioning the disk."
echo "n
p
1


t
83
w"| fdisk ${DISK}

echo "Waiting for the symbolic link to be created..."
udevadm settle --exit-if-exists=$PARTITION

echo "Creating the filesystem."
mkfs -j -t ext4 ${PARTITION}

echo "Updating fstab"
LINE="${PARTITION}\t${MOUNTPOINT}\text4\tnoatime,nodiratime,nodev,noexec,nosuid\t1\t2"
echo -e ${LINE} >> /etc/fstab

echo "Mounting the disk"
mkdir -p $MOUNTPOINT
mount -a

echo "Changing permissions"
chown couchbase $MOUNTPOINT
chgrp couchbase $MOUNTPOINT
}

turnOffTransparentHugepages ()
{
if [ ! -f /etc/rc.d/rc.local ]; then
  echo "#!/bin/bash
  " > /etc/rc.d/rc.local
fi

echo "
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
" >> /etc/rc.d/rc.local

chmod 755 /etc/rc.d/rc.local
systemctl restart rc-local.service
systemctl enable rc-local.service
}

setSwappinessToZero ()
{
sysctl vm.swappiness=0
echo "
# Required for Couchbase
vm.swappiness = 0
" >> /etc/sysctl.conf
}

addCBGroup ()
{
    $username = $1
    $password = $2
    path = ${3-'/opt/couchbase/bin/'}
    cli=${path}couchbase-cli group-manage
    ls $path
    $cli --username $username --password $password --create --group-name
    #runs in the directory where couchbase is installed

}

tuneDisks ()
if [ ! -f /etc/rc.d/rc.local ]; then
  echo "#!/bin/bash
  " > /etc/rc.d/rc.local
fi
{
 for DISK in $(lsblk -dln | grep disk | grep sd | cut -c 1-4)
 do
   echo "
   echo 'deadline' > /sys/block/${DISK}/queue/scheduler
   echo '1024' > /sys/block/${DISK}/queue/nr_requests
   echo '100' > /sys/block/${DISK}/queue/iosched/read_expire
   echo '4' > /sys/block/${DISK}/queue/iosched/writes_starved
   echo '0' > /sys/block/${DISK}/queue/rotational
   echo '0' > /sys/block/${DISK}/queue/add_random
   echo '2' > /sys/block/${DISK}/queue/rq_affinity
   " >> /etc/rc.d/rc.local
 done

 chmod 755 /etc/rc.d/rc.local
 systemctl restart rc-local.service
 systemctl enable rc-local.service
}

tuneSettings ()
{
echo "
# Recommended for Couchbase
net.ipv4.tcp_keepalive_time = 120
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_tw_buckets = 1440000
vm.overcommit_memory = 0
vm.min_free_kbytes = 524288
vm.dirty_background_bytes = 1073741824
vm.dirty_bytes = 1073741824
vm.dirty_expire_centisecs = 300
vm.dirty_writeback_centisecs = 100
vm.zone_reclaim_mode = 0
fs.file-max = 2851364
" >> /etc/sysctl.conf

sysctl -p
}

userLimits ()
{
  echo "
  couchbase soft nofile 131072
  couchbase hard nofile 131072
  couchbase hard core unlimited
  " >> /etc/security/limits.conf
}

cpuTuning ()
{
  CPU=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`
  if [[ $CPU -le 4 ]]; then
    echo f > /sys/class/net/eth0/queues/rx-0/rps_cpus
  else
    echo ff+ > /sys/class/net/eth0/queues/rx-0/rps_cpus
  fi
}
