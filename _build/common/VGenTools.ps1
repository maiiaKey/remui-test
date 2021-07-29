$ErrorActionPreference = "Stop"

$vGenTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$vGenTools_ScriptRoot\bin\VGen\vgen.ps1"

#* ---------------------------------------------
#* Function: Run-VGen
#* ---------------------------------------------
function Run-VGen
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $projectRoot,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $buildNumber
  )

  GenerateVersionInfo -ProjectRoot "$projectRoot" -BuildNr "$buildNumber"
}