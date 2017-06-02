#!/bin/bash
echo "resourcegroup name"
read rg
echo "read location"
read location
azure group create $rg $location
