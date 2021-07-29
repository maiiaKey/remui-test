$ErrorActionPreference = "Stop"

$ilRepackTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$ilRepackTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Run-ILRepack
#* ---------------------------------------------
function Run-ILRepack
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $primaryAssembly,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $otherAssemblies,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $outputFile,
    [Parameter(Mandatory=$true)]
    [String]
    $pathToPlatformLibs
  )
  Start-ProcessEx -executableFile "$ilRepackTools_ScriptRoot\bin\ILRepack\ILRepack.exe" -executableParams "/lib:`"$pathToPlatformLibs`" /out:`"$outputFile`" /wildcards `"$primaryAssembly`" $otherAssemblies"
}