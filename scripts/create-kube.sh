#!/bin/bash
echo "which resourcegroup"
read resourcegroup

echo "name of your cluster (should be unique in reqion):"
read name

subscription=$(az account show | jq --raw-output  ".id")
location=$(az group show --name $resourcegroup | jq --raw-output ".location")

# check if name already exists in this region
lookup=$(nslookup $name.$location.cloudapp.azure.com)
if [[ $lookup != *"can't find"* ]]
then
  echo "dns $name.$location.cloudapp.azure.com is already taken, choose another one"
  exit 0
fi

# network
vnet=$(az network vnet list --resource-group $resourcegroup | jq --raw-output ".[].name")
subnet=$(az network vnet list --resource-group $resourcegroup | jq --raw-output ".[].subnets[].name")
firstIP=$(az network vnet list --resource-group $resourcegroup | jq --raw-output ".[].subnets[].addressPrefix" | sed 's/0\/24/10/')
echo "using vnet $vnet and subnet $subnet 1st IP addres is: $firstIP"

# ssh key
ssh-keygen -t rsa -f  ~/.ssh/id_rsa -P ""
tmpkey=`echo $(cat ~/.ssh/id_rsa.pub)`
sshKey=$(echo "$tmpkey" | sed 's/\//\\\//g')

# make working copy
cp kube-template.json kube-deploy.json


# create service principal
echo "creating service prinicipal for subscription: "$subscription
id=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/"$subscription"/resourceGroups/"$resourcegroup)
appId=$(echo $id | jq --raw-output ".appId")
password=$(echo $id | jq --raw-output ".password")


sed -in 's/XXX_NAME_XXX/'$name'/' kube-deploy.json
sed -in 's/XXX_SUBSCRIPTION_XXX/'$subscription'/' kube-deploy.json
sed -in 's/XXX_VNET_XXX/'$vnet'/' kube-deploy.json
sed -in 's/XXX_SUBNET_XXX/'$subnet'/' kube-deploy.json
sed -in 's/XXX_FIRSTIP_XXX/'$firstIP'/' kube-deploy.json
sed -in "s/XXX_SSHKEY_XXX/$sshKey/" kube-deploy.json
sed -in 's/XXX_SPCLIENT_ID_XXX/'$appId'/' kube-deploy.json
sed -in 's/XXX_SPCLIENT_SECRET_XXX/'$password'/' kube-deploy.json

# generating kube deployment with acs engine
echo "create ACS template"
acs-engine generate kube-deploy.json

# createing the kube cluster
az group deployment create --name $name --resource-group $resourcegroup --template-file _output/$name/azuredeploy.json --parameters @_output/$name/azuredeploy.parameters.json

# message
echo "now do: scp azureuser@$name.$location.cloudapp.azure.com:~/.kube/config ~/.kube/config"
