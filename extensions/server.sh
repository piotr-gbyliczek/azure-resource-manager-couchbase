#!/usr/bin/env bash

echo "Running server.sh"

version=$1
adminUsername=$2
adminPassword=$3
location=$4
services=$5
uniquestring=$6

echo "Using the settings:"
echo version \'$version\'
echo adminUsername \'$adminUsername\'
echo adminPassword \'$adminPassword\'
echo location \'$location\'
echo services \'$services\'
echo uniquestring \'$uniquestring\'

echo "Installing prerequisites..."
yum -y install python-httplib2 epel-release
yum -y install jq

echo "Installing Couchbase Server..."
wget http://packages.couchbase.com/releases/${version}/couchbase-server-enterprise-${version}-centos7.x86_64.rpm
yum -y install couchbase-server-enterprise-${version}-centos7.x86_64.rpm
yum -y install couchbase-server

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

# We can get the index directly with this, but unsure how to test for sucess.  Come back to later...
#nodeIndex = `curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/name?api-version=2017-04-02&format=text"`
# good example here https://github.com/bonggeek/Samples/blob/master/imds/imds.sh

nodeName="null"
while [[ $nodeName == "null" ]]
do
  nodeName=`curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute?api-version=2017-04-02" \
    | jq ".name" \
    | sed 's/"//g'`
done

nodeIndex="null"
while [[ $nodeIndex == "null" ]]
do
  nodeIndex=`echo $nodeName \
    | sed 's/.*_//'`
done

nodeName=`echo $nodeName \
    | sed 's/_.*//'`

nodeDNS='vm'$nodeIndex'.'$nodeName'-'$uniquestring'.'$location'.cloudapp.azure.com'
rallyDNS='vm0.'$nodeName'-'$uniquestring'.'$location'.cloudapp.azure.com'

#nodeDNS=`hostname -f`
#rallyDNS=`echo $nodeDNS | sed 's/[[:digit:]]\{6\}./000000./1'`

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
