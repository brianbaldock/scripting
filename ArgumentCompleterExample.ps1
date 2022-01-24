[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

param(
    [Parameter(Position = 0, Mandatory)]
    [ArgumentCompleter(
        {
            param($SKU)
            $ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
            Invoke-WebRequest -Uri "https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0/Product%20names%20and%20service%20plan%20identifiers%20for%20licensing.csv" -OutFile "$($ScriptDir)\SKU-List.csv"
            $Import = Import-Csv -Path "$($ScriptDir)\SKU-List.csv"
        }
    )]
    [ValidateScript(
        {
            $_ -in ($Import."String_ Id")
        }
    )]
    [string]$PreferredLicense,
    [string]$SecondaryLicense
)
