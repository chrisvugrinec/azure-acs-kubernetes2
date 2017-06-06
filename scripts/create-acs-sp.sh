#!/bin/bash
echo "resourcegroup"
read rg
subid=$(az account show | jq --raw-output ".id")
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subid/resourceGroups/$rg"
