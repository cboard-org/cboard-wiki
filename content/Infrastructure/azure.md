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

#### SSL Certificate with Let's Encrypt

To provide an SSL certificate to Azure App Gateway, an HTTPS listener with a Let's Encrypt certificate should be set up and renewed every 3 months or less. The following steps provide a detailed explanation of how to approach this. This guide is based on [this post](https://intelequia.com/es/blog/post/automating-azure-application-gateway-ssl-certificate-renewals-with-let-s-encrypt-and-azure-automation) by David Rodríguez on Inteliquia.

##### Issuing and Installing the Let’s Encrypt Certificate for the First Time

###### Step 1: Create a Storage Account or Use an Existing One
1. Set up an Azure Storage account to host the challenge requests for the DNS domain ownership check. Choose the most cost-effective parameters such as “Standard performance” and LRS. 

2. After the storage account is ready, create a “public” container with “public blob” permissions.
![2](/images/ssl-autorenew-images/6c913dfa-681e-4c31-b986-c805c6c08ad9.png)

3. Use the Storage Explorer tool to create the virtual directory “\.well-known\acme-challenge”.
![3](/images/ssl-autorenew-images/d5923013-af23-49ae-97a3-354750084039.png)

###### Step 2: Modify the Application Gateway to Redirect ACME Challenge Requests to the Storage Account

4. If a HTTP rule was specified when creating the Azure Application Gateway, delete that rule. It will be replaced by a Path-based rule in the next step.
![4](/images/ssl-autorenew-images/d94b0fee-541d-4f92-819f-7c3967e533f3.png)

5. Create a new path-based rule that redirects the requests made by Let’s Encrypt during the renewal process. Use the following configuration:
![5](/images/ssl-autorenew-images/da00d758-665d-43cc-9e98-9b60f02b5b4d.png)

6. Enter the parameters from the http rule, and click on “Add Configuration”.
![6](/images/ssl-autorenew-images/dd6ee5f2-1511-4e12-a90c-f5718cb1add0.png)

7. Specify the configuration parameters with the path “/.well-known/acme-challenge/*” with a redirection (Permanent), targeting an external site with the storage account container URL created earlier:
![6](/images/ssl-autorenew-images/6294fcad-45c8-443e-9e06-c9b37fde26d4.png)
![7](/images/ssl-autorenew-images/19fbcc55-b935-48fc-804a-43a9abb1b190.png)

8. Test the rule by creating a file called “test.html” on the storage account and browsing the URL /.well-known/acme-challenge/test.html">/.well-known/acme-challenge/test.html">http://<yourdomain>/.well-known/acme-challenge/test.html
![9](/images/ssl-autorenew-images/a25dbf84-c632-4012-80f9-2957dd69d086.png)

If the setup is correct, the application gateway should redirect the browser to the storage account as shown below. Ensure the redirection rule is successfully set up before proceeding. 
![10](/images/ssl-autorenew-images/2066c740-bd7b-43d3-b2c5-af198e3a0222.png)

###### Step 3: Install the Let’s Encrypt Certificate on the Gateway for the First Time

Open a bash console. With Python installed, use “sudo apt-get install certbot”. Execute the following command to issue the certificate locally in manual mode, by registering an account with an email address on Let’s Encrypt service and issuing a certificate for the domain, agreeing to the Terms of Service:

`sudo certbot certonly --email <email> -d <domain> --agree-tos --manual`

![11](/images/ssl-autorenew-images/b2772023-72ff-4ccd-94a8-5a56a1c683b2.png)

Create the file on the storage account with the required contents using this command:

`echo "<content>" > ./<filename>`

To check if the certificate has been successfully issued, use:

`sudo ls /etc/letsencrypt/live/<domain>`

The output should be:

README  cert.pem  chain.pem  fullchain.pem  privkey.pem

The certificate, chain, and key are issued in .pem format. To upload the certificate in .pfx, use OpenSSL to convert from PEM to PFX:

`sudo openssl pkcs12 -export -in /etc/letsencrypt/live/<domain>/fullchain.pem -inkey /etc/letsencrypt/live/<domain>/privkey.pem -out <domain>.pfx`

Finally, modify the current HTTPS listener to use the Let's Encrypt certificate.
![11](/images/ssl-autorenew-images/1190c74b-d5e9-4637-86c5-2d85c5959e83.png)

After applying the changes, verify that the Let's Encrypt SSL certificate is working properly by browsing a resource via HTTPS.

#### Implementing the Renewal Process

1. Create an Azure Automation account (or use an existing one) on the Azure Portal to host the runbook.
![1](/images/ssl-autorenew-images/7ce18f74-9168-4c4a-8fe5-adc5e94feda7.png)

2. Open the Modules inside the Automation resource and browse the gallery to import the following modules:  Az.Accounts, Az.Network, Az.Storage, ACME-PS. Use all as V 5.1.

3. Create a PowerShell runbook called LetsEncryptCertificateRenewal on the Azure Automation account.

4.On the Automation account add permissions using Azure role assignments. use owner role for subscription and resource group. (this is used by the runbook to have acces to the resources)

5. Edit the PowerShell runbook and paste the contents of https://github.com/cboard-org/cboard-wiki/blob/master/themes/default/public/scripts/renew-letsencryp.ps1. Click on the “Publish” button to make it available for scheduling.

Test the runbook on the Test pane, and pass the required parameters (Expires Days, domain with subdomains separeted with "," like `app.qa.cboard.io,api.app.qa.cboard.io,wiki.qa.cboard.io` , email address used on Let's Encrypt, resource group names, storage account name, application gateway name when setting up the https listener). It takes around 15 minutes to complete. After browsing the site again with https, the certificate should be updated correctly.

6. Create an Azure Automation Schedule to renew the SSL certificate. For example, a schedule for renewing it every 3 weeks can be created.
![6](/images/ssl-autorenew-images/f2d4bf48-e355-4a20-9ef8-2a0a624e0b8d.png)

7. Set up the parameters to schedule the runbook with the schedule created earlier. 

And that concludes the process. 

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
