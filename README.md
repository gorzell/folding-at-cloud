# Folding@Cloud

Scripts to setup a Folding@Home GPU instance in Azure.

**Note:** Azure was the best place for **me** to set this up, but it should be possible to use at least the cloud-init on any cloud. I will happily take PRs to add support for other cloud providers.

## Prerequisites
1. An [Azure account](https://azure.microsoft.com/en-us/free/).
1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
1. Login your Azure account [via the CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest).

## Getting Started
1. Update the Folding@Home configuration in [cloud-init.yaml](https://github.com/gorzell/folding-at-cloud/blob/master/cloud-init.yaml). _See the [`Folding At Home Configuration` section](#folding-at-home-configuration) below for more detail._
1. Run `start.sh -h`
1. Run `start.sh --name NAME` with any customizations that you want. Name is required and must be lowercase alphanumeric (plus - characters).
1. Wait a few moments, it can take some time to evaluate the `cloud-init.yml` and install the appropriate software.
1. Check the logs: `ssh <public_dns> tail -f /var/lib/fahclient/log.txt`

*Note:* You may not be able to get resources in the default region of `eastus`.
- If this is the case, you can pass `--region REGION` to the `start.sh` command. REGION can be any `name` attribute listed by this command: `az account list-locations`.
- If you are denied resources in one area, you will need to delete the resource group on azure's online GUI.

## Folding At Home Configuration

These values are located in the `cloud-init.yaml` file under the `write_files:` section. The values can be found in your Folding@Home account.

1. **User:**

- This can be any unique identifier that you want to use to track your work contribution. [Read more about users](https://foldingathome.org/support/faq/stats-teams-usernames/).
- This was chosen when you set up your Folding@Home account.
- This is the `<user value='gorzell'/>` line in the `cloud-init.yaml` file.

2. **Team:**

- The team that you want to associate your work with. The existing identifier is for the `github` team. [Read more about teams](https://foldingathome.org/support/faq/stats-teams-usernames/).
- This was optionally setup when you made your Folding@Home account. If you aren't sure, you can change this to `<team value=''/>`
- This is the `<team value='236463'/>` line in the `cloud-init.yaml` file.

3. **Passkey:**

- A unique identifier that ties your contributions directly to you (not just those with your username). [Read more about passkeys](https://foldingathome.org/support/faq/points/passkey/).
- This was optionally setup when you made your Folding@Home account. If you aren't sure, you can change this to `<passkey value=''/>`
- This is the `<passkey value=''/>` line in the `cloud-init.yaml` file.
