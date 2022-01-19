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
        ParameterSetName='SUB',
        HelpMessage='Enter the admin account for the tenant - Example "admin@domain.com".')]
        [Parameter(Mandatory=$True,
        ParameterSetName='All',
        HelpMessage='Enter the admin account for the tenant - Example "admin@domain.com".')]
        [String]$Admin,
        
        [Parameter(Mandatory=$false,
        ParameterSetName='All',
        HelpMessage='This is the default parameter, will list all subscriptions and how many licenses are available.')]
        [switch]$All,

        [Parameter(Mandatory=$false,
        ParameterSetName='SUB',
        HelpMessage='Enter the Subscription Name - Example "Microsoft 365 E5".')]
        [String]$SubscriptionName
    )
    
    process {
        try{
            $SubTable = @()
            if($PSCmdlet.ParameterSetName -eq "All"){
                $SubList = Get-AzureADSubscribedSku
                foreach($Sub in $SubList){
                    if($Sub.PrepaidUnits.Enabled -gt 0){
                        $EnabledUnits = $Sub.PrepaidUnits.Enabled
                    }
                    Else{
                        $EnabledUnits = 0
                    }
                    
                    $Table = New-Object PSObject -Property @{
                        SKUPartNumber = $Sub.SKUPartNumber
                        ConsumedUnits = $Sub.ConsumedUnits
                        TotalUnits = $EnabledUnits
                    }
                    $SubTable += $Table
                }
            }

            if ($PSCmdlet.ParameterSetName -eq "Sub"){
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
                        Write-Output "`nNo license by the name $($SubscriptionName) has been found. Verify license name by running Get-LicenseInfo.`n"
                        break
                    }
                }
                catch{
                    return $_.Exception.Message
                    break
                }
            }
        }   
        catch{
            return $_.Exception.Message
        }
    }
    end {
        return $SubTable
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
        Set-PSDebug -Step
        Get-AADModules
        if($PreferredLicense = Get-LicenseInfo -Admin $Admin -SubscriptionName $PreferredLicense){
            if($BackupLicense = Get-LicenseInfo -Admin $Admin -SubscriptionName $BackupLicense){
                Set-PSDebug -Step
                if($PreferredLicense.ConsumedUnits -lt $PreferredLicense.TotalUnits){
                    #Do stuff here like assign user to a group that gets this license
                    Write-Output "There are enough $($PreferredLicense) left."
                    break
                }
                else{
                    if($BackupLicense.ConsumedUnits -lt $BackupLicense.TotalUnits){
                        #Do other stuff here, like assign the user to this group because the preferred license has no licenses left etc...
                        Write-Output "There are not enough $($PreferredLicense) licences left. Use $($BackupLicense) instead."
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
Get-LicenseUsage