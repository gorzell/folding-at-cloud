#!/bin/sh

#/ Usage: start.sh [-g -h -n -r]
#/
#/ Start a GPU VM in Azure that will automatically process work for Folding@HOME
#/ https://foldingathome.org/
#/ https://github.com/gorzell/folding-at-azure
#/
#/ OPTIONS:
#/   -h | --help    Show this message.
#/   -g | --resource-group Azure resource group name. DEFAULT: foldingathome
#/   -n | --name      Name for the VM. DEFAULT: folding
#/   -s | --size      Number of instances to start in the scale group. DEFAULT: 3
#/   -r | --region    Azure region. DEFAULT: eastus
#/

set -e

usage () {
  grep '^#/' <"$0" | cut -c 4-
}

RESOURCE_GROUP=foldingathome-scale
LOCATION=eastus
USER=$(whoami)
SIZE=3

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
    -s|--size)
      SIZE=$2
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

az vmss create \
  --resource-group $RESOURCE_GROUP \
  --name $NAME-ScaleSet \
  --upgrade-policy-mode automatic \
  --image Canonical:UbuntuServer:18.04-LTS:latest \
  --vm-sku Standard_NC6_Promo \
  --custom-data cloud-init.yaml \
  --admin-username $USER \
  --nsg $NAME-NetworkSecurityGroup \
  --public-ip-address-allocation dynamic \
  --public-ip-per-vm \
  --instance-count 3 \
  --generate-ssh-keys \
  --verbose

az vmss list-instances \
  --resource-group $RESOURCE_GROUP \
  --name $NAME-ScaleSet \
  --output table

az vmss list-instance-connection-info \
    --resource-group $RESOURCE_GROUP \
    --name $NAME-ScaleSet
