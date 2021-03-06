#!/usr/bin/env bash

echo "Running syncGateway.sh"

version=$1

echo "Using the settings:"
echo version \'$version\'

echo "Installing Couchbase Sync Gateway..."
wget https://packages.couchbase.com/releases/couchbase-sync-gateway/${version}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm
yum -i couchbase-sync-gateway-enterprise_${version}_x86_64.rpm

echo "Calling util.sh..."
source util.sh
adjustTCPKeepalive

echo "Configuring Couchbase Sync Gateway..."
file="/home/sync_gateway/sync_gateway.json"
echo '
{
  "interface": "0.0.0.0:4984",
  "adminInterface": "0.0.0.0:4985",
  "log": ["*"]
}
' > ${file}
chmod 755 ${file}
chown sync_gateway ${file}
chgrp sync_gateway ${file}

# Need to restart to load the changes
service sync_gateway stop
service sync_gateway start
