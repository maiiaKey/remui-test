$ErrorActionPreference = "Stop"

$visiTranslatorTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$visiTranslatorTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Constants
#* ---------------------------------------------
$mongoConnectionStr = "mongodb://VisicomTranslationUser:0PvWT2Yy@mongodb.eu-west-1.aws.glb.visicom.com:27017/VisicomTranslations?keepAlive=true&poolSize=30&autoReconnect=true&socketTimeoutMS=360000&connectTimeoutMS=360000"

#* ---------------------------------------------
#* Function: Import-Translations
#* ---------------------------------------------
function Import-Translations
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $appName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $appVersion,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $inputFile,
    [String]
    $appPrevVersion
  )
  
  $rawJobName = $env:JOB_NAME
  $jobName =  (Split-Path -Path $rawJobName -Leaf);
  $translated = $jobName.EndsWith("-Translated"); 
  if($translated)
  {
	$executableFile = "$visiTranslatorTools_ScriptRoot\bin\VisiTranslator\VTImport\VTImport.exe"
	Start-ProcessEx -executableFile "`"$executableFile`"" -executableParams "-n `"$appName`" -v `"$appVersion`" -f `"$inputFile`" -c `"$mongoConnectionStr`" -r `"$appPrevVersion`""
  }
}

#* ---------------------------------------------
#* Function: Export-Translations
#* ---------------------------------------------
function Export-Translations
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $appName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $appVersion,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $outputDir
  )

  $executableFile = "$visiTranslatorTools_ScriptRoot\bin\VisiTranslator\VTExport\VTExport.exe"
  $exportTreshold = 50
  Start-ProcessEx -executableFile "`"$executableFile`"" -executableParams "-n `"$appName`" -v `"$appVersion`" -d `"$outputDir`" -c `"$mongoConnectionStr`" -t $exportTreshold"
}