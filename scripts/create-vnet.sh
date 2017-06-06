#!/bin/bash
echo "which resourcegroup"
read resourcegroup
name=$resourcegroup"-vnet"
az group deployment create --name $name --resource-group $resourcegroup --template-file vnet-template.json
