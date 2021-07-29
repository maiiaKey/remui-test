$ErrorActionPreference = "Stop"

$ilMergeTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$ilMergeTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Run-ILMerge
#* ---------------------------------------------
function Run-ILMerge
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
    [ValidateNotNullOrEmpty()]
    [String]
    $targetPlatform
  )

  Start-ProcessEx -executableFile "$ilMergeTools_ScriptRoot\bin\ILMerge\ILMerge.exe" -executableParams "/ndebug /targetplatform:$targetPlatform /out:`"$outputFile`" /wildcards `"$primaryAssembly`" `"$otherAssemblies`""
}