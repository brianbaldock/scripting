[CmdletBinding()]
Param([string]$Name, [string]$Path)

DynamicParam{
    if ($Path.StartsWith("HKLM:")){
    $parameterAttribute = [System.Management.Automation.ParameterAttribute]@{
        ParameterSetName = "ByRegistryPath"
        Mandatory = $false
    }

    $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
    $attributeCollection.Add($parameterAttribute)

    $dynParam1 = [System.Management.Automation.RuntimeDefinedParameter]::new(
    'KeyCount', [Int32], $attributeCollection
    )

    $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
    $paramDictionary.Add('KeyCount', $dynParam1)
    return $paramDictionary
    }
}