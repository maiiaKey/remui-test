$ErrorActionPreference = "Stop"

#include
$ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Execute-XlsTransformation
#* ---------------------------------------------
function Execute-XlsTransformation
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $cfgFile,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $srcFile,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $dstDirectory
  )  
  
  # Running XlsTransformation
  Start-ProcessEx -executableFile "$ScriptRoot\bin\XlsTransformationTool\XlsTransformationTool.exe" -executableParams "--Config `"$cfgFile`" --Source `"$srcFile`" --OutDir `"$dstDirectory`""
}


