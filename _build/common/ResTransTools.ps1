$ErrorActionPreference = "Stop"

$resTransTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$resTransTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Constants
#* ---------------------------------------------
$netExecutable = "$resTransTools_ScriptRoot\bin\ResTrans\ResTrans-Net.exe"
$androidExecutable = "$resTransTools_ScriptRoot\bin\ResTrans\ResTrans-Android.exe"

#* ---------------------------------------------
#* Function: Extract-DefLngFile
#* ---------------------------------------------
function Extract-DefLngFile
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $projectDir,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $outputFile,
    [ValidateSet("Android", "Net")]
    [String]
    $platform
  )

  # String comparison in powershell is case insensitive by default
  if($platform -eq "Net")
  {
    $executableFile = $netExecutable
  }
  else
  {
    $executableFile = $androidExecutable
  }

  Start-ProcessEx -executableFile "`"$executableFile`"" -executableParams "-e -p `"$projectDir`" -f `"$outputFile`""
}

#* ---------------------------------------------
#* Function: Import-LngFiles
#* ---------------------------------------------
function Import-LngFiles
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $projectDir,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $lngFilesDir,
    [ValidateSet("Android", "Net")]
    [String]
    $platform
  )

  # String comparison in powershell is case insensitive by default
  if($platform -eq "Net")
  {
    $executableFile = $netExecutable
  }
  else
  {
    $executableFile = $androidExecutable
  }
  Start-ProcessEx -executableFile "`"$executableFile`"" -executableParams "-i -p `"$projectDir`" -d `"$lngFilesDir`""
}