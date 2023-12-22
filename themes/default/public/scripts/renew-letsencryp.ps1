#######################################################################################
# Based on https://intelequia.com/blog/post/1012/automating-azure-application-gateway-ssl-certificate-renewals-with-let-s-encrypt-and-azure-automation
# Script that renews a Let's Encrypt certificate for an Azure Application Gateway
# Pre-requirements:
#      - Have a storage account in which the folder path has been created: 
#        '/.well-known/acme-challenge/', to put here the Let's Encrypt DNS check files
#      - Add "Path-based" rule in the Application Gateway with this configuration: 
#           - Path: '/.well-known/acme-challenge/*'
#           - Check the configure redirection option
#           - Choose redirection type: permanent
#           - Choose redirection target: External site
#           - Target URL: <Blob public path of the previously created storage account>
#                - Example: 'https://test.blob.core.windows.net/public'
#
#
#        Following modules are needed now: Az.Accounts, Az.Network, Az.Storage, ACME-PS
#
#######################################################################################
[CmdletBinding()]
param(
    $ExpiresInDays = 110,
    [string]$EmailAddress,
    [string]$STResourceGroupName,
    [string]$storageName,
    [string]$AGResourceGroupName,
    [string]$AGName,
    [string]$DomainString
)
$Domains = $DomainString -split ',';
# Ensures that no login info is saved after the runbook is done
Disable-AzContextAutosave
# Log in as the service principal from the Runbook
Import-Module ACME-PS
Connect-AzAccount -Identity

#Select-AzSubscription -SubscriptionId cboard-qa-sponsor

$daysFromNow = (Get-Date).AddDays($ExpiresInDays)
 
$AppGw = Get-AzApplicationGateway -Name $AGName -ResourceGroupName $AGResourceGroupName
$sslCerts = Get-AzApplicationGatewaySslCertificate -ApplicationGateway $AppGw
 
#$sslCerts = Get-AzKeyVaultCertificate -VaultName $KeyVaultName
$sslCerts | ForEach-Object {
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]([System.Convert]::FromBase64String($_.PublicCertData.Substring(60, $_.PublicCertData.Length - 60)))
    $_.Name
    $cert.NotAfter
    Write-Output "Starting script execution...";

    # Check if the certificate corresponds naming agreement (starts with 'LetsEncrypt' and whether it is expiring)
    if ($cert.NotAfter -le $daysFromNow) {
        $domain = $cert.Subject.Replace("CN=", "")
        $AGOldCertName = $_.Name
        Write-Output "Start renewing of the certificate: $AGOldCertName for $Domains"
        
        # Create a state object and save it to the harddrive
        $tempFolderPath = $env:TEMP + "\" + $domain
        
        # Preparing folder for certificate renewal
        # Remove folder used for certificate renewal if existing
        if(Test-Path $tempFolderPath -PathType Container)
        {            
            Get-ChildItem -Path $tempFolderPath -Recurse | Remove-Item -force -recurse
            Remove-Item $tempFolderPath -Force
        }        
        
        $tempFolder = New-Item -Path $tempFolderPath -ItemType "directory"
        
        $state = New-ACMEState -Path $tempFolder
        $serviceName = 'LetsEncrypt'
        
        # Fetch the service directory and save it in the state
        Get-ACMEServiceDirectory $state -ServiceName $serviceName -PassThru;
        
        # Get the first anti-replay nonce
        New-ACMENonce $state;
        
        # Create an account key. The state will make sure it's stored.
        New-ACMEAccountKey $state -PassThru;
        
        # Register the account key with the acme service. The account key will automatically be read from the state
        New-ACMEAccount $state -EmailAddresses $EmailAddress -AcceptTOS;
        
        # Load an state object to have service directory and account keys available
        $state = Get-ACMEState -Path $tempFolder;
        
        # It might be neccessary to acquire a new nonce, so we'll just do it for the sake of the example.
        New-ACMENonce $state -PassThru;
        
        # Create the identifier for the DNS name

        $identifier = $Domains | ForEach-Object { New-ACMEIdentifier $_ };
        
        # Create the order object at the ACME service.
        $order = New-ACMEOrder $state -Identifiers $identifier;
        
        # Fetch the authorizations for that order
        #$authZ = Get-ACMEAuthorization -State $state -Order $order;
        $authorizations = @(Get-ACMEAuthorization -State $state -Order $order);
        
        foreach($authz in $authorizations) {
            # Select a challenge to fullfill
            $challenge = Get-ACMEChallenge $state $authZ "http-01";
            
            # Inspect the challenge data
            $challenge.Data;
            
            # Create the file requested by the challenge
            $fileName = $tempFolderPath + '\' + $challenge.Token;
            Set-Content -Path $fileName -Value $challenge.Data.Content -NoNewline;
            $blobName = ".well-known/acme-challenge/" + $challenge.Token
            $storageAccount = Get-AzStorageAccount -ResourceGroupName $STResourceGroupName -Name $storageName
            $ctx = $storageAccount.Context
            Set-AzStorageBlobContent -File $fileName -Container "public" -Context $ctx -Blob $blobName
            
            # Signal the ACME server that the challenge is ready
            $challenge | Complete-ACMEChallenge $state;
        }

        # Wait a little bit and update the order, until we see the states
        while ($order.Status -notin ("ready", "invalid")) {
            Start-Sleep -Seconds 10;
            $order | Update-ACMEOrder $state -PassThru;
        }
        
        # We should have a valid order now and should be able to complete it
        # Therefore we need a certificate key
        $certKey = New-ACMECertificateKey -Path "$tempFolder\$domain.key.xml";
        
        # Complete the order - this will issue a certificate singing request
        Complete-ACMEOrder $state -Order $order -CertificateKey $certKey;
        
        # Now we wait until the ACME service provides the certificate url
        while (-not $order.CertificateUrl) {
            Start-Sleep -Seconds 15
            $order | Update-Order $state -PassThru
        }
        
        # As soon as the url shows up we can create the PFX
        $password = ConvertTo-SecureString -String "Passw@rd123***" -Force -AsPlainText
        Export-ACMECertificate $state -Order $order -CertificateKey $certKey -Path "$tempFolder\$domain.pfx" -Password $password;
        
        # Delete blob to check DNS
        Remove-AzStorageBlob -Container "public" -Context $ctx -Blob $blobName
        
        ### RENEW APPLICATION GATEWAY CERTIFICATE ###
        $appgw = Get-AzApplicationGateway -ResourceGroupName $AGResourceGroupName -Name $AGName
        Set-AzApplicationGatewaySSLCertificate -Name $AGOldCertName -ApplicationGateway $appgw -CertificateFile "$tempFolder\$domain.pfx" -Password $password
        Set-AzApplicationGateway -ApplicationGateway $appgw
    }
}