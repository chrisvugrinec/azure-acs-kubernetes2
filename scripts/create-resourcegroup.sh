#!/bin/bash
echo "resourcegroup name"
read rg
echo "read location"
read location
az group create --name $rg --location $location
