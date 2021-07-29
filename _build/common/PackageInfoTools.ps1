$ErrorActionPreference = "Stop"

#* ---------------------------------------------
#* Function: Import-Translations
#* ---------------------------------------------
function Get-PackageName
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $targetSystem,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $componentName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $componentVersion,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $revisionNumber
  )
  
  return "$targetSystem-$componentName-$componentVersion.$revisionNumber-" + (Get-Date -Format "yyMMddHHmm");
}


function Get-PackageInfo
{
    Param
    (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $packageName
    )

    return "<PackageInfo><PackageName>$packageName</PackageName></PackageInfo>"
}

function Create-PackageInfoXml
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $targetSystem,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $componentName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $componentVersion,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $revisionNumber,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $pathToPackageInfoDir
  )
  
  #create 
  $packageName = Get-PackageName $targetSystem $componentName $componentVersion $revisionNumber
  $value = Get-PackageInfo $packageName
  New-Item (join-path $pathToPackageInfoDir "_packageInfo") -type directory
  New-Item (join-path $pathToPackageInfoDir (join-path "_packageInfo" "PackageInfo.xml")) -type file -value $value
}


