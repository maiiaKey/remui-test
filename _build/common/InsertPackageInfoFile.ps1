# ----------------------
# Parameters
# ----------------------
 Param
  (
    [Parameter(Mandatory=$false)]
    [String]
    $folder,
    [Parameter(Mandatory=$false)]
    [String]
    $pathInsideZipFile = '.\'
  )

# ----------------------
# Initialization
# ----------------------
$scriptFolder = Split-Path -Path $myInvocation.MyCommand.Definition

# ----------------------
# Includes
# ----------------------
. "$scriptFolder\PackageInfoTools.ps1"

# ----------------------
# Constants
# ----------------------
$packageInfoFileName = "PackageInfo.xml"
$DoNotDisplayProgressDialogBox = 12
$YesToAllDialogBox = 16
$NoUserInterfaceOnError = 1024
$SleepTimeout = 60
$packageInfoFolder = "_packageinfo"
$filter = "*.zip"
$tmpFolderName = [System.Guid]::NewGuid().ToString()

# ----------------------
# Validate and Process Parameters
# ----------------------
# if packageName is set, packageFileName is mandatory
if(!$folder)
{
    $folder = $scriptFolder
}


# ----------------------
# Process
# ----------------------
$app = new-object -com shell.application
Get-ChildItem $folder\* -include *.zip -Filter $filter | where {!$_.PSIsContainer } | `
Foreach-Object{
    $zipFileName = $_.FullName
    $sleeptime = 0
    $packageName = $_.BaseName
    
    if($zipFileName.length -ge 260)
    {
        write-host 'Warning: zipfile path is longer then 260 characters, issues may occure' -foregroundcolor yellow
    }
    
    # 'Open' zip file
    $shell = new-object -com shell.application
    $ZipFile = $shell.NameSpace($zipFileName)
    write-host "--------------------------------"
    write-host "Processing package $packageName."
    $tmpPath = join-path $env:Temp $tmpFolderName
    if($tmpPath.length -ge 260)
    {
        write-host 'Warning: temp path is longer then 260 characters, issues may occure' -foregroundcolor green
    }
    New-Item $tmpPath -type directory -force | out-null
    $packageInfoFolderPath = join-path $pathInsideZipFile $packageInfoFolder
    
    # Unzip zip file into tmp path
    foreach($item in $ZipFile.Items())
    {
        $shell.Namespace($tmpPath).MoveHere($item)
    }
    
    # Recreate empty zip file
    Remove-Item $zipFileName -force | out-null
    New-Item $zipFileName -type file -force | out-null
    set-content $zipFileName ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) 
    $ZipFile = $shell.NameSpace($zipFileName)
    # Create package info directory and file 
    $sourcePath = join-path (join-path $tmpPath $packageInfoFolderPath) $packageInfoFileName
    $value = Get-PackageInfo $packageName
    New-Item $sourcePath -type file -value $value -force | out-null
    
    # Zip back into zip file
    foreach($item in $shell.Namespace($tmpPath).Items())
    {
        $remaining = $shell.Namespace($tmpPath).Items().Count
        write-host "$remaining remaining subfolders for $packageName"
        $ZipFile.MoveHere( $item , $DoNotDisplayProgressDialogBox + $YesToAllDialogBox + $NoUserInterfaceOnError)
        do
        {
            $sleeptime = $sleeptime + 1
            start-sleep 1
        }
        while(($shell.Namespace($tmpPath).Items().Count -eq $remaining) -and 
              ($sleeptime -le $SleepTimeout))
    }
    Remove-item $tmpPath -force -recurse | out-null
    write-host "Finished package $packageName" -foregroundcolor green
    write-host "--------------------------------"
    write-host ""
}