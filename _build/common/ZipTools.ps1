$ErrorActionPreference = "Stop"

$zipTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$zipTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Zip-File
#* ---------------------------------------------
function Zip-File
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $dataFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $archiveName,
    [String]
    $archiveDirName = ""
  )

  $execParams = "-f `"$dataFile`" -a `"$archiveName`""
  if($archiveDirName -ne "")
  {
   $execParams += " -n `"$archiveDirName`""
  }


  Start-ProcessEx -executableFile "$zipTools_ScriptRoot\bin\Zip\ZipFile.exe" -executableParams "$execParams"
}

#* ---------------------------------------------
#* Function: Unzip-File
#* ---------------------------------------------
function Unzip-File
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $archiveFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $destinationFolder
  )

  $execParams = "-a `"$archiveFile`" -d `"$destinationFolder`""
  
  Start-ProcessEx -executableFile "$zipTools_ScriptRoot\bin\Zip\UnzipFile.exe" -executableParams "$execParams"
}

#* ---------------------------------------------
#* Function: Zip-Dir
#* ---------------------------------------------
function Zip-Dir
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $dataDir,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $archiveName,
    [String]
    $archiveDirName = ""
  )

  $execParams = "-d `"$dataDir`" -a `"$archiveName`""
  if($archiveDirName -ne "")
  {
   $execParams += " -n `"$archiveDirName`""
  }

  Start-ProcessEx -executableFile "$zipTools_ScriptRoot\bin\Zip\ZipDir.exe" -executableParams "$execParams"
}

#* ---------------------------------------------
#* Function: Create-SfxArchive
#* ---------------------------------------------
function Create-SfxArchive
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $dataDir,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $archiveName,
    [String]
    $archiveDirName = "",
    [String]
    $postExtractCmd = ""
  )

  $execParams = "-d `"$dataDir`" -a `"$archiveName`""
  if($archiveDirName -ne "")
  {
   $execParams += " -n `"$archiveDirName`""
  }
  if($postExtractCmd -ne "")
  {
   $execParams += " -e `"$postExtractCmd`""
  }

  Start-ProcessEx -executableFile "$zipTools_ScriptRoot\bin\Zip\CreateSfxArchive.exe" -executableParams "$execParams"
}