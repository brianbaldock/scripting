

[CmdletBinding(DefaultParameterSetName='All')]
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
    
    begin {
        function CheckModules{
            try{
                #Test for AzureAD or AzureADPreview Module
                if(Get-Module -ListAvailable -Name "AzureAD"){
                    return 1
                }
                elseif(Get-Module -ListAvailable -Name "AzureADPreview"){
                    return 2
                }
                else{
                    return 3
                }
            }
            catch{
                return $_.Exception.Message
            }
        }
        try{
            switch(CheckModules){
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
    
    process {
        try{
            $SubTable = @()
            if($PSCmdlet.ParameterSetName -eq "All"){
                $SubList = Get-AzureADSubscribedSku
                foreach($Sub in $SubList){
                    $Table = New-Object PSObject -Property @{
                        SKUPartNumber = $Sub.SKUPartNumber
                        ConsumedUnits = $Sub.ConsumedUnits
                        TotalUnits = ($Sub | Select-Object -ExpandProperty PrepaidUnits).Enabled
                    }
                    $SubTable += $Table
                }
            }

            if ($PSCmdlet.ParameterSetName -eq "Sub"){
                try{
                    if($SubList = Get-AzureADSubscribedSku | Where-Object {$_.SKUPartNumber -eq $($SubscriptionName)}){
                        $Table = New-Object PSObject -Property @{
                            SKUPartNumber = $SubList.SKUPartNumber
                            ConsumedUnits = $SubList.ConsumedUnits
                            TotalUnits = ($Sublist | Select-Object -ExpandProperty PrepaidUnits).Enabled
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
            
        catch{
            return $_.Exception.Message
        }

    end {
        return $SubTable | Format-Table -Property SKUPartNumber, ConsumedUnits, TotalUnits
    }