# About goes here


# Functions:
function Get-ActiveAADConnection{
    param(
        [int16]$ConCheck
    )
    try{
        switch($ConCheck){
            1 {Import-Module AzureAD}
            2 {Import-Module AzureADPreview}
            3 {
                Write-Output "Please install the Azure AD powershell module by following the instructions at this link: https://aka.ms/AAau56t"
                break
            }
        }
    }
    catch{
        return $_.Exception.Message
    }            
    #Check if already connected to AAD:
    try{
        $TestConnection = Get-AzureADTenantDetail
    }
    catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException]{
        try{
            Connect-AzureAD -AccountId $Admin | Out-Null
        }
        catch{
            return $_.Exception.Message
        }
    }
}
function Get-AADModules{
    try{
        #Test for AzureAD or AzureADPreview Module
        if(Get-Module -ListAvailable -Name "AzureAD"){
            Get-ActiveAADConnection -ConCheck 1
        }
        elseif(Get-Module -ListAvailable -Name "AzureADPreview"){
            Get-ActiveAADConnection -ConCheck 2
        }
        else{
            Get-ActiveAADConnection -ConCheck 3
        }
    }
    catch{
        return $_.Exception.Message
    }
}

function Get-LicenseInfo{
    param (
        [Parameter(Mandatory=$True,
        HelpMessage='Enter the admin account for the tenant - Example "admin@domain.com".')]
        [String]$Admin,

        [Parameter(Mandatory=$True,
        HelpMessage='Enter the Subscription Name - Example "SPE_E5".')]
        [String]$SubscriptionName
    )
    
    process {
        try{
            if($SubList = Get-AzureADSubscribedSku | Where-Object {$_.SKUPartNumber -eq $($SubscriptionName)}){
                if($Sub.PrepaidUnits.Enabled -gt 0){
                    $EnabledUnits = $Sub.PrepaidUnits.Enabled
                }
                Else{
                    $EnabledUnits = 0
                }
                $Table = New-Object PSObject -Property @{
                    SKUPartNumber = $SubList.SKUPartNumber
                    ConsumedUnits = $SubList.ConsumedUnits
                    TotalUnits = $EnabledUnits
                }
                $SubTable += $Table
            }
            else{
                Write-Output "No subscription by the name $($SubscriptionName) found."
                break
            }
        }
        catch{
            return $_.Exception.Message
            break
        }
    }

    end {
        return $SubTable | Format-Table -Property SKUPartNumber, ConsumedUnits, TotalUnits
    }
}

function Get-LicenseUsage{
    param(
        [Parameter(Mandatory=$True,
        HelpMessage="Provide preferred license name.")]
        [String]$PreferredLicense,

        [Parameter(Mandatory=$True,
        HelpMessage="Provide backup license name.")]
        [string]$BackupLicense,

        [Parameter(Mandatory=$True,
        HelpMessage='Enter the admin account for the tenant - Example "admin@domain.com".')]
        [String]$Admin
    )
    try{
        Get-AADModules
        if($PreferredLicense = Get-LicenseInfo -Admin $Admin -SubscriptionName $PreferredLicense){
            if($BackupLicense = Get-LicenseInfo -Admin $Admin -SubscriptionName $BackupLicense){
                if($PreferredLicense.ConsumedUnits -lt $PreferredLicense.TotalUnits){
                    <#
                        Do stuff here, 
                        Example: Assign a user to a specific group if the preferred license isn't available.
                        Add a specific AD attribute etc.
                    #>
                    Write-Output "There are $($PreferredLicense.TotalUnits - $PreferredLicense.ConsumedUnits) preferred $($PreferredLicense.SkuPartNumber) left."
                    break
                }
                else{
                    if($BackupLicense.ConsumedUnits -lt $BackupLicense.TotalUnits){
                        <#
                            Do other stuff here, 
                            Example: Assign a user to a specific group if the preferred license isn't available.
                            Add a specific AD attribute etc.
                        #>
                        Write-Output "There are not enough $($PreferredLicens.SkuPartNumber) licences left. Use $($BackupLicense.SkuPartNumber) instead."
                        break
                    }
                    else{
                        
                    }
                }
            }
        }
        else{
            Write-Output "You're not getting into Get-LicenseInfo yo!"
        }
    }
    catch{
        return $_.Exception.Message
        break
    }
}