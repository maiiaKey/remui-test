$scriptRootDir = Split-Path -Path $myInvocation.MyCommand.Definition
$rootDir = Resolve-Path "$scriptRootDir\.."
Set-Location -Path $rootDir

. .\_build\Build.ps1

  "====================================="
  "Additional environment initialization"
  "====================================="
  .\_build\PrepareEnviroment.ps1

Build -nexusPush $false -nexusRepository "Libraries" -jenkinsConsoleFix $false -msBuildExePath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"