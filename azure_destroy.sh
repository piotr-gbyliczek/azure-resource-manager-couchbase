#!/usr/bin/bash

source .env

# Delete resource group 

az group delete  --name $RG_NAME --yes --output table
