$scriptRootDir = Split-Path -Path $myInvocation.MyCommand.Definition
$rootDir = Resolve-Path "$scriptRootDir\.."
Set-Location -Path $rootDir

. .\_build\Build.ps1

$returnCode = "0"

try
{
  "====================================="
  "Additional environment initialization"
  "====================================="
  .\_build\PrepareEnviroment.ps1
  
  if($returnCode -eq 0){
	Build -msBuildExePath $env:MSBuild_v16_x86 -revisionNumber $env:SVN_REVISION -nexusPush $true -nexusRepository "Libraries" -jenkinsConsoleFix $true
  }
}
catch
{
  $returnCode = "1"
  Write-Host $_
  throw $_
}
$returnCodeString = [string]$returnCode;
$returnCode = $returnCodeString.Substring($returnCodeString.Length-1)
Write-Host "Main ReturnCode: " $returnCode
$host.SetShouldExit($returnCode)