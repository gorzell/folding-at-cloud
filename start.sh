#!/bin/sh

#/ Usage: start.sh -n <name> [-g -h -r]
#/
#/ Start a GPU VM in Azure that will automatically process work for Folding@HOME
#/ https://foldingathome.org/
#/ https://github.com/gorzell/folding-at-azure
#/
#/ OPTIONS:
#/   -h | --help    Show this message.
#/   -g | --resource-group Azure resource group name. DEFAULT: foldingathome
#/   -n | --name      Name for the VM (must be unique within the region).
#/   -p | --public    Attach a public IP with port 22 open. DEFAULT: false
#/   -r | --region    Azure region. DEFAULT: eastus
#/

set -e

usage () {
  grep '^#/' <"$0" | cut -c 4-
}

RESOURCE_GROUP=foldingathome
LOCATION=eastus
USER=$(whoami)

NAME=

while [ "$#" -gt 0 ]; do
  case "$1" in
    -g|--resource-group)
      RESOURCE_GROUP=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 2
      ;;
    -n|--name)
      NAME=$2
      shift 2
      ;;
    -r|--region)
      LOCATION=$2
      shift 2
      ;;
    *)
      echo "Unknown argument: $arg. Use -h or --help for details on available arguments." 1>&2
      exit 2
  esac
done

# Require the name flag.
if [ -z "$NAME" ]; then
  echo "You must set a name.\n" 1>&2
  usage
  exit 2
fi

az group create --name $RESOURCE_GROUP --location $LOCATION

az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $NAME-Vnet \
    --address-prefix 192.168.0.0/16 \
    --subnet-name $NAME-Subnet \
    --subnet-prefix 192.168.1.0/24

az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $NAME-PublicIP \
    --dns-name $NAME-publicdns

az network nsg create \
    --resource-group $RESOURCE_GROUP \
    --name $NAME-NetworkSecurityGroup

az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NAME-NetworkSecurityGroup \
    --name $NAME-NetworkSecurityGroupRuleSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

az network nic create \
    --resource-group $RESOURCE_GROUP \
    --name $NAME-Nic \
    --vnet-name $NAME-Vnet \
    --subnet $NAME-Subnet \
    --public-ip-address $NAME-PublicIP \
    --network-security-group $NAME-NetworkSecurityGroup

#--size Standard_NC6_Promo \
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $NAME-vm \
  --size Standard_NC6_Promo \
  --image Canonical:UbuntuServer:18.04-LTS:latest \
  --custom-data cloud-init.yaml \
  --admin-username $USER \
  --generate-ssh-keys \
  --nics $NAME-Nic
