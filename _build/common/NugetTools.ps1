$ErrorActionPreference = "Stop"

$nugetTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$nugetTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Run-NugetPack
#* ---------------------------------------------
function Run-NugetSourcesRemove
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $repositoryName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $repositoryUrl,
    [Parameter(Mandatory=$false)]
    [String]
    $userName,
    [Parameter(Mandatory=$false)]
    [String]
    $password
  )
  Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "sources Remove -name `"$repositoryName`" -source `"$repositoryUrl`" -UserName `"$userName`" -Password `"$password`" -NonInteractive"
}

#* ---------------------------------------------
#* Function: Run-NugetPack
#* ---------------------------------------------
function Run-NugetSourcesAdd
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $repositoryName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $repositoryUrl,
    [Parameter(Mandatory=$false)]
    [String]
    $userName,
    [Parameter(Mandatory=$false)]
    [String]
    $password
  )
  Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "sources Add -name `"$repositoryName`" -source `"$repositoryUrl`" -UserName `"$userName`" -Password `"$password`" -NonInteractive"
}

#* ---------------------------------------------
#* Function: Run-NugetPack
#* ---------------------------------------------
function Run-NugetPack
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $pathToNuspecFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $outputPath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $version,
    [Parameter(Mandatory=$false)]
    [String]
    $suffix
  )
  if ([string]::IsNullOrEmpty($suffix)) {
    Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "pack `"$pathToNuspecFile`" -OutputDirectory `"$outputPath`" -Version `"$version`" -NonInteractive"
  }
  else {
    Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "pack `"$pathToNuspecFile`" -OutputDirectory `"$outputPath`" -Version `"$version`" -Suffix `"$suffix`" -NonInteractive"
  }
}

#* ---------------------------------------------
#* Function: Run-NugetPack
#* ---------------------------------------------
function Run-NugetPush
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
    $repositoryUrl
  )
  Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "push `"$pathToNupkgFile`" -source `"$repositoryUrl`" -NonInteractive"
}

#* ---------------------------------------------
#* Function: Run-NugetUpdate
#* ---------------------------------------------
function Run-NugetUpdate
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
    $repositoryUrl
  )
  Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "update `"$configPath`" -id `"$packageId`" -source `"$repositoryUrl`" -NonInteractive -MSBuildVersion 14"
}

#* ---------------------------------------------
#* Function: Run-NugetClearLocals
#* ---------------------------------------------
function Run-NugetClearLocals
{
  Param
  ()
  Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "locals all -clear"
}

#* ---------------------------------------------
#* Function: Run-NugetRestore
#* ---------------------------------------------
function Run-NugetRestore
{
  Param
  (
	[Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $projectPath
  )
  Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "restore `"$projectPath`""
}

#* ---------------------------------------------
#* Function: Run-NugetSetApiKey
#* ---------------------------------------------
function Run-NugetSetApiKey
{
  Param
  (
	[Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $repositoryUrl,
	[Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $apikey
  )
  Start-ProcessEx -executableFile "$nugetTools_ScriptRoot\bin\Nuget\nuget.exe" -executableParams "setapikey `"$apikey`" -source `"$repositoryUrl`" -NonInteractive"
}