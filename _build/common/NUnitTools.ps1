$ErrorActionPreference = "Stop"

$nunitTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$nunitTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Run-NUnit
#* ---------------------------------------------
function Run-NUnit
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $assembly,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $resultsXml,
    [String]
    $configName = ""
  )

  $executableParams = "/result:`"$resultsXml`" /noshadow `"$assembly`""
  if(($configName -ne $null) -and
     ($configName -ne ""))
  {
    $executableParams+= " /config=`"$configName`""
  }

  Start-ProcessEx -executableFile "$nunitTools_ScriptRoot\bin\Nunit\bin\nunit-console.exe" -executableParams $executableParams
}