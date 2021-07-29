# -----------------------
# Script initialization
# -----------------------
$ErrorActionPreference = "Stop"

$nugetNexusTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$nugetNexusTools_ScriptRoot\NugetTools.ps1"


$nugetApiKey = "d97c09f1-ad96-365c-8de8-8877ad0bf33d"
$repositoryBaseUrl = "http://nexus-test.glb.visicom.com:8081/repository/"


#* ---------------------------------------------
#* Function: Run-NexusNugetPush
#* ---------------------------------------------
function Run-NexusNugetPush
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $pathToNupkgFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $repositoryName
  )

  $repositoryUrl = $repositoryBaseUrl + $repositoryName + "/"

  Run-NugetSetApiKey -repositoryUrl "$repositoryUrl" -apikey "$nugetApiKey" 
  Run-NugetPush -pathToNupkgFile "$pathToNupkgFile" -repositoryUrl $repositoryUrl
}

#* ---------------------------------------------
#* Function: Run-NugetUpdate
#* ---------------------------------------------
function Run-NexusNugetUpdate
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $configPath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $packageId,
	[Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $repositoryName
  )
  
  $repositoryUrl = $repositoryBaseUrl + $repositoryName + "/"
  
  Run-NugetUpdate -configPath "$configPath" -packageId "$packageId" -repositoryUrl $repositoryUrl
}