/* Title: Description of all Azure resources: why need them, environment variables we need */

## Azure Resources

#### Virtual Machines

We need them to serve Cboard app (qa and prod environment)

- PROD ([cboard-vm-prod](https://portal.azure.com/#@martinbedouretoutlook.onmicrosoft.com/resource/subscriptions/8dc0229b-f14e-4a6c-8152-e7a3fd99563b/resourceGroups/cboard-group/providers/Microsoft.Compute/virtualMachines/cboard-vm-prod/overview))
- QA ([cboard-vm-qa](https://portal.azure.com/#@martinbedouretoutlook.onmicrosoft.com/resource/subscriptions/8dc0229b-f14e-4a6c-8152-e7a3fd99563b/resourceGroups/cboard-qa-group/providers/Microsoft.Compute/virtualMachines/cboard-vm-qa/overview))

#### Public IP addresses

Needed to assign each IP to each VM

- cboard-vm-prod-ip - 104.43.223.150
- cboard-vm-qa-ip - 23.99.255.67

#### Storage Service

Media storage (like images for tiles and boards)

- [cboardgroupdiag483](https://portal.azure.com/#@martinbedouretoutlook.onmicrosoft.com/resource/subscriptions/8dc0229b-f14e-4a6c-8152-e7a3fd99563b/resourceGroups/cboard-group/providers/Microsoft.Storage/storageAccounts/cboardgroupdiag483/overview)

#### Disks

Disks assigned to each VM

- PROD ([cboard-vm-prod_OsDisk_1_77523e9866704d0ba32c4a3988b683dd](https://portal.azure.com/#@martinbedouretoutlook.onmicrosoft.com/resource/subscriptions/8dc0229b-f14e-4a6c-8152-e7a3fd99563b/resourceGroups/CBOARD-GROUP/providers/Microsoft.Compute/disks/cboard-vm-prod_OsDisk_1_77523e9866704d0ba32c4a3988b683dd/overview))
- QA ([cboard-vm-qa_OsDisk_1_9d9039aa3a6747eabb0655a8f45550ea](https://portal.azure.com/#@martinbedouretoutlook.onmicrosoft.com/resource/subscriptions/8dc0229b-f14e-4a6c-8152-e7a3fd99563b/resourceGroups/CBOARD-QA-GROUP/providers/Microsoft.Compute/disks/cboard-vm-qa_OsDisk_1_9d9039aa3a6747eabb0655a8f45550ea/overview))

---

## Env Variables

- **URL**: Cboard’s top level domain (i.e: cboard.io)
- **SUBDOMAINS**: Cboard’s subdomains, comma separated, no spaces (i.e: app,api,api.app)
- **VALIDATION**: Letsencryp’t validation challenge to be done in order to obtain SSL Certificates automatically (i.e: http)
- **EMAIL**: The email of the person in charge of Cboard’s domain. (i.e: some@email.com)
- **ONLY_SUBDOMAINS**: Boolean value (default false) that avoids checking for top level domain certificates. (i.e.: true)
- **AZURE_STORAGE_CONNECTION_STRING**: Microsoft Azure Blob Service’s string connection (i.e: DefaultEndpointsProtocol=https;AccountName=cbo…)
- **SENDGRID_API_KEY**: Sendgrid’s API key to send emails (i.e.: s0MeKey...)
- **JWT_SECRET**: Just a secret string for authorization tokens (i.e.: thisisS3cre!t)
- **FACEBOOK_APP_ID**: Facebook app ID
- **FACEBOOK_APP_SECRET**: Facebook app secret
- **FACEBOOK_CALLBACK_URL**: Facebook callback url (usually Cboard's frontend url)
- **GOOGLE_APP_ID**: Google app ID
- **GOOGLE_APP_SECRET**: Google app secret
- **GOOGLE_CALLBACK_URL**: Google callback url (usually Cboard's frontend url)
