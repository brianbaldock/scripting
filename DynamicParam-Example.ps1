class ids : System.Management.Automation.IValidateSetValuesGenerator {
     [String[]] GetValidValues() {
         $Global:scriptdir = Split-Path $script:MyInvocation.MyCommand.Path
         $Global:ids = Import-CSV -Path "$($Global:scriptdir)\SKU-List.csv"
         return ($Global:ids)."String_ Id"
     }
 }
 Function SKUids {
     Param(
         [Parameter(Mandatory)]
         [ValidateSet([ids],ErrorMessage="Value '{0}' is invalid. Try one of: {1}")]
         $ids
     )
     $ids | Foreach-Object {
        Write-Output $_."String_ Id"
     }
 }