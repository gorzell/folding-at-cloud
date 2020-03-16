# Folding@Cloud

Scripts to setup a Folding@Home GPU instance in Azure.

**Note:** Azure was the best place for **me** to set this up, but it should be possible to use at least the cloud-init on any cloud. I will happily take PRs to add support for other cloud providers.

## Prerequisites
1. An [Azure account](https://azure.microsoft.com/en-us/free/).
1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
1. Login your Azure account [via the CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest).

## Getting Started
1. Update the Folding@Home configuration in [cloud-init.yaml](https://github.com/gorzell/folding-at-cloud/blob/master/cloud-init.yaml).
1. Run `start.sh -h`
1. Run `start.sh` with any customizations that you want.
1. Check the logs: `ssh <public_dns> tail -f /var/lib/fahclient/log.txt`

## Folding At Home Configuration
**User:** This can be any unique identifier that you want to use to track your work contribution. [Read more about users](https://foldingathome.org/support/faq/stats-teams-usernames/).

**Team:** The team that you want to associate your work with. The existing identifier is for the `github` team. [Read more about teams](https://foldingathome.org/support/faq/stats-teams-usernames/).

**Passkey:** A unique identifier that ties your contributions directly to you (not just those with your username). [Read more about passkeys](https://foldingathome.org/support/faq/points/passkey/).
