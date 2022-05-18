<#
    .DESCRIPTION
        This script will let you export all the current enterprise vulnerabilities and vulnerable devices using Graph API

        The sample scripts are not supported under any Microsoft standard support 
        program or service. The sample scripts are provided AS IS without warranty  
        of any kind. Microsoft further disclaims all implied warranties including,  
        without limitation, any implied warranties of merchantability or of fitness for 
        a particular purpose. The entire risk arising out of the use or performance of  
        the sample scripts and documentation remains with you. In no event shall 
        Microsoft, its authors, or anyone else involved in the creation, production, or 
        delivery of the scripts be liable for any damages whatsoever (including, 
        without limitation, damages for loss of business profits, business interruption, 
        loss of business information, or other pecuniary loss) arising out of the use 
        of or inability to use the sample scripts or documentation, even if Microsoft 
        has been advised of the possibility of such damages.

        Author: Brian Baldock - brian.baldock@microsoft.com

        Requirements: 
            
    
    .PARAMETER name

    .EXAMPLE

#>



$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

## Variables
$systemmessagecolor = "cyan"
$processmessagecolor = "green"

# Application (client) ID, tenant ID and secret
$clientid = "26179577-ab75-47ef-b076-0503a82b9e6e"
$tenantid = "6e00d973-41f0-483c-a664-a98bd018a6fe"
$clientsecret = "PY98Q~zAh-ad-BT9qrhn4t_Jh36Hs_VDaTIoqbw1"

Clear-Host

write-host -foregroundcolor $systemmessagecolor "Script started`n"

# Construct URI
$uri = "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/token"

# Construct Body
$body = @{
    client_id     = $clientId
    scope         = "https://api.securitycenter.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

write-host -foregroundcolor $processmessagecolor "Get OAuth 2.0 Token"
# Get OAuth 2.0 Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Access Token
$token = ($tokenRequest.Content | ConvertFrom-Json).access_token

# Graph API call in PowerShell using obtained OAuth token (see other gists for more details)

# Specify the URI to call and method
$uri1 = "https://api.securitycenter.microsoft.com/api/machines/SoftwareVulnerabilitiesByMachine"
$uri2 = "https://api.securitycenter.microsoft.com/api/Vulnerabilities"
$method = "GET"

write-host -foregroundcolor $processmessagecolor "Run Graph API Query"
# Run Graph API query 
$query1 = Invoke-WebRequest -Method $method -Uri $uri1 -ContentType "application/json" -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop -UseBasicParsing
$query2 = Invoke-WebRequest -Method $method -Uri $uri2 -ContentType "application/json" -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop -UseBasicParsing
## Screen output
write-host -foregroundcolor $processmessagecolor "Parse results"
$ConvertedOutput1 = $query1.content | ConvertFrom-Json -AsHashtable
$ConvertedOutput2 = $query2.content | ConvertFrom-Json -AsHashtable

$MachineData = $ConvertedOutput1.value | select-object Devicename, cveid,lastseentimestamp,softwarename,softwarevendor, softwareversion,vulnerabilityseveritylevel
$CVEData = $ConvertedOutput2.value | select-object id,name,severity,cvssv3,publishedon,updatedon


write-host -foregroundcolor $systemmessagecolor "`nScript Completed`n"