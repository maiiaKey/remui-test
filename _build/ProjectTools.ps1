Function GetCurrentOutputType {
  Param
  (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $pathToCsproj
  )
  $xml = [Xml] (Get-Content $pathToCSProj)
  return ([string] $xml.Project.PropertyGroup.OutputType).Trim()
}

Function ChangeOutputType {
  Param
  (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $pathToCsproj,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $newOutputType
  )

  $currentOutputType = (GetCurrentOutputType -pathToCsproj $pathToCsproj)

  $content = (Get-Content $pathToCsproj)
  $content | % { $_.Replace("<OutputType>$($currentOutputType)</OutputType>", "<OutputType>$($newOutputType)</OutputType>") } | Set-Content $pathToCsproj

  Write-Host "Changed OutputType for $($pathToCsproj) from $($currentOutputType) to $($newOutputType)"
}