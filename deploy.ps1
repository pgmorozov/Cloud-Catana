'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'>azInstall.sh
bash 'azInstall.sh'
$resourceNames = @{
    AppName = "SOCCKPlay";
    Identity = "SOCCKPlay";
    ServerAppName = "SOCKatanaServerPlay";
    ClientAppName = "SOCKatanaClientPlay";
  }

#Install-Module AzureAD -Force -Confirm:$false
#Import-Module AzureAD -UseWindowsPowerShell

$pass = ConvertTo-SecureString 'P@ssw0rd3@CXP' -AsPlainText -Force
$creds = New-Object PSCredential ('traveleraccount@seccxpninja.onmicrosoft.com', $pass)
Connect-AzAccount -Credential $creds 
#Connect-AzureAD -Credential $creds 
az login -u $creds.UserName -p $creds.GetNetworkCredential().Password
        
$AppName = $resourceNames.AppName.ToLower()
if($AppName.Length -lt 20)
{
    $AppName = $appName + [String]::new('0', 20-$AppName.Length)
}

$tenantId = (Get-AzContext).Tenant.Id


$Script = Invoke-WebRequest "https://socckplay00000000000sa.blob.core.windows.net/template-files/resources/scripts/New-AppRegistration.ps1$token"
Invoke-Expression $Script.Content

$Script = Invoke-WebRequest "https://socckplay00000000000sa.blob.core.windows.net/template-files/resources/scripts/New-ManagedIdentity.ps1$token"
Invoke-Expression $Script.Content


#if(-not (Get-AzADApplication -DisplayName $resourceNames.ServerAppName))
#{
    New-AppRegistration -Name $resourceNames.ServerAppName -IdentifierUris "https://$AppName.azurewebsites.net" -ReplyUrls "https://$AppName.azurewebsites.net/.auth/login/aad/callback" -RequireAssignedRole -AssignAppRoleToUser 'traveleraccount@seccxpninja.onmicrosoft.com' -verbose
#}
#if(-not (Get-AzADApplication -DisplayName $resourceNames.ClientAppName))
#{
    New-AppRegistration -Name $resourceNames.ClientAppName -NativeApp -ReplyUrls 'http://localhost' -RequireAssignedRole -AssignAppRoleToUser 'traveleraccount@seccxpninja.onmicrosoft.com' -DisableImplicitGrantFlowOAuth2 -verbose
#}

#$identity = Get-AzADServicePrincipal -DisplayName $resourceNames.Identity
#if(-not $identity)
#{
    $identity = New-ManagedIdentity -Name $resourceNames.Identity -ResourceGroup 'SOC-CK-Play' -verbose
        
    Add-GraphPermissions -SvcPrincipalId $identity.principalId -PermissionsFile .\attackActions\permissions.json -verbose
#}
