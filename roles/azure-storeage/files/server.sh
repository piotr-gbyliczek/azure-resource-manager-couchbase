#!/usr/bin/env bash

echo "Running server.sh"

version=$1
adminUsername=$2
adminPassword=$3
services=$4

echo "Using the settings:"
echo version \'$version\'
echo adminUsername \'$adminUsername\'
echo adminPassword \'$adminPassword\'
echo services \'$services\'

echo "Installing prerequisites..."
yum -y install python-httplib2 epel-release
yum -y install jq

echo "Installing Couchbase Server..."
wget http://packages.couchbase.com/releases/${version}/couchbase-server-enterprise-${version}-centos7.x86_64.rpm
yum -y install couchbase-server-enterprise-${version}-centos7.x86_64.rpm
yum -y install couchbase-server

echo "Adding Couchbase binaries to path"
echo "
CBPATH='/opt/couchbase/bin'
if [[ ! \$PATH =~ \$CBPATH ]]; then
  PATH=\$CBPATH:\$PATH
  export PATH
fi  
" >> /etc/profile.d/sh.local

echo "Calling util.sh..."
source util.sh
formatDataDisk
turnOffTransparentHugepages
setSwappinessToZero
adjustTCPKeepalive
cpuTuning
userLimits
tuneSettings
tuneDisks

echo "Configuring Couchbase Server..."


nodeShort="null"
while [[ $nodeShort == "null" ]]
do
  nodeShort=`hostname -s`
done

nodeIndex="null"
while [[ $nodeIndex == "null" ]]
do
  nodeIndex=`echo ${nodeShort: -1}`
done

nodeDNS="null"
while [[ $nodeDNS == "null" ]]
do
  nodeDNS=`hostname -f`
done

rallyDNS="null"
while [[ $rallyDNS == "null" ]]
do
  rallyDNS=`hostname -s | sed 's/[0-9]*//g'`000000.`hostname -d`
done

echo "Adding an entry to /etc/hosts to simulate split brain DNS..."
echo "
# Simulate split brain DNS for Couchbase
127.0.0.1 ${nodeDNS}
" >> /etc/hosts

cd /opt/couchbase/bin/

echo "Running couchbase-cli node-init"
output=""
counter=0
while [[ $output != "SUCCESS: Node initialized" ]]
do
  output=`./couchbase-cli node-init \
   --cluster=$nodeDNS \
   --node-init-hostname=$nodeDNS \
   --node-init-data-path=/datadisk/data \
   --node-init-index-path=/datadisk/index \
   --user=$adminUsername \
   --pass=$adminPassword`
  echo node-init output \'$output\'
  sleep 10
  ((counter++))
  if [[ $counter == 20 ]]
  then
    exit 1
  fi
done

if [[ $nodeIndex == "0" ]]
then
  totalRAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  dataRAM=$((30 * $totalRAM / 100000))
  indexRAM=$((15 * $totalRAM / 100000))

  output=""
  counter=0
  while [[ $output != "SUCCESS: Cluster initialized" ]]
  do
    echo "Running couchbase-cli cluster-init"
    output=`./couchbase-cli cluster-init \
      --cluster=$nodeDNS \
      --cluster-ramsize=$dataRAM \
      --cluster-index-ramsize=$indexRAM \
      --cluster-username=$adminUsername \
      --cluster-password=$adminPassword \
      --services=$services`
    echo cluster-init output \'$output\'
    sleep 10
  ((counter++))
  if [[ $counter == 20 ]]
  then
    exit 1
  fi
  done
else
  echo "Running couchbase-cli server-add"
  counter=0
  output=""
  while [[ $output != "Server added" && ! $output =~ "Node is already part of cluster." ]]
  do
    output=`./couchbase-cli server-add \
      --cluster=$rallyDNS \
      --user=$adminUsername \
      --pass=$adminPassword \
      --server-add=$nodeDNS \
      --server-add-username=$adminUsername \
      --server-add-password=$adminPassword \
      --services=$services`
    echo server-add output \'$output\'
    sleep 10
    ((counter++))
    if [[ $counter == 20 ]]
    then
      exit 1
    fi
  done

  echo "Running couchbase-cli rebalance"
  output=""
  while [[ ! $output =~ "SUCCESS" ]]
  do
    output=`./couchbase-cli rebalance \
      --cluster=$rallyDNS \
      --user=$adminUsername \
      --pass=$adminPassword`
    echo rebalance output \'$output\'
    sleep 10
  done

fi
