$ErrorActionPreference = "Stop"

$checkFileTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition
. "$checkFileTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Check-XmlFile
#* ---------------------------------------------
function Check-XmlFile
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $file
  )

  Start-ProcessEx -executableFile "$checkFileTools_ScriptRoot\bin\FileChecker\XmlFileChecker.exe" -executableParams $file
}

#* ---------------------------------------------
#* Function: Check-UTF8File
#* ---------------------------------------------
function Check-UTF8File
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $file
  )

  Start-ProcessEx -executableFile "$checkFileTools_ScriptRoot\bin\FileChecker\UTF8FileChecker.exe" -executableParams $file
}

#* ---------------------------------------------
#* Function: Check-UTF8Files
#* ---------------------------------------------
function Check-UTF8Files
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $directory,
    [Parameter(Mandatory=$false)]
    [String[]]
    $exclude
  )
  
  Get-ChildItem -Recurse -path $directory -include *.sql -exclude $exclude | Where-Object { -not $_.PSIsContainer } |
    Foreach-Object {
        Check-UTF8File -file $_.FullName
    }
}

#* ---------------------------------------------
#* Function: Add-ContentEx
#* ---------------------------------------------
function Add-ContentEx
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $srcFile,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $dstFile 
  ) 
 	 
	#check file - must be UTF8 with bom
    Check-UTF8File -file $srcFile
		
	#add-content to dst file
	Get-Content -Path $srcFile | Add-Content -Path $dstFile -Encoding UTF8
}

#* ---------------------------------------------
#* Function: Add-ContentEx
#* ---------------------------------------------
function Add-ContentExWithCache
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $srcFile,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $dstFile,
    [parameter(Mandatory=$true)]
    [System.Collections.Generic.HashSet[string]]    
    $cache
  ) 
 	if(-not $cache.Contains($srcFile)) {
        Check-UTF8File -file $srcFile
        $cache.Add($srcFile);
    }
	#check file - must be UTF8 with bom
    
		
	#add-content to dst file
	Get-Content -Path $srcFile | Add-Content -Path $dstFile -Encoding UTF8
}


#* ---------------------------------------------
#* Function: Add-ContentEx
#* ---------------------------------------------
function Add-ContentExWoCheck
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $srcFile,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]    
    $dstFile 
  ) 

  #add-content to dst file
  Get-Content -Path $srcFile | Add-Content -Path $dstFile -Encoding UTF8
}

