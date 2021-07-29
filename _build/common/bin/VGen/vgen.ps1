#==============================================================================
# root folder and script ErrorActionPreference
#==============================================================================
$ErrorActionPreference = "Stop"
$rootFolder = (Split-Path -Path $myInvocation.MyCommand.Definition)

#==============================================================================
# UpdateRCVersionInfo - creates binary version info file based on .rc template
#==============================================================================
function UpdateRCVersionInfo
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $configScriptPath,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $versionInfoPath,
	[parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $buildNumber
  )

  #______________________________________________
  # load global macro values
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  . (Join-Path -Path $rootFolder -ChildPath "\cfg\global_values.ps1")

  #______________________________________________
  # load VersionInfo configuration script
  # (cobfigured macro values)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  . $configScriptPath

  #______________________________________________
  # override some macro values (if you want)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $intRevNum = [convert]::ToInt64($buildNumber, 10)%65535
  $_buildVer = $intRevNum

  #______________________________________________
  # load VersionInfo template
  # (macros are replaced during load)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  . (Join-Path -Path $rootFolder -ChildPath "\cfg\version_info.ps1")

  #______________________________________________
  # write VersionInfo template to temp file
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $vInfoTmp = [IO.Path]::GetTempFileName()
  Set-Content -Path $vInfoTmp -Value $_versionInfo

  #______________________________________________
  # build VersionInfo from template
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  Start-Process -FilePath $VI_Builder -ArgumentList "`"$vInfoTmp`"" -Wait

  #______________________________________________
  # copy generated VersionInfo to its destination
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  # get path to currently created VersionInfo
  $tmpName = Split-Path -Leaf -Path $vInfoTmp
  $tmpFolder = Split-Path -Parent -Path $vInfoTmp
  $tmpName = $tmpName.Replace(".tmp", ".res")
  $vInfoBinTmp = Join-Path -Path $tmpFolder -ChildPath $tmpName

  # move Version Info to its final destination
  Move-Item $vInfoBinTmp $versionInfoPath -Force

  # remove temporary file
  Remove-Item $vInfoTmp
}


#==============================================================================
# UpdateAssemblyInfo - modifies AssemblyInfo.cs
#==============================================================================
function UpdateAssemblyInfo
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $configScriptPath,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $assemblyInfoPath,
	[parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $buildNumber
  )

  #______________________________________________
  # load global macro values
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  . (Join-Path -Path $rootFolder -ChildPath "\cfg\global_values.ps1")

  #______________________________________________
  # load AssemblyInfo configuration script
  # (cobfigured macro values)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  . $configScriptPath

  #______________________________________________
  # override some macro values (if you want)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $_buildVer = $buildNumber

  $_int16buildVer = [convert]::ToInt64($_buildVer, 10)%65535
  $actualBuildVer = [convert]::ToInt64($_buildVer)
  $intRelaseVersionNum = $_releaseVer + ([convert]::ToInt64([Math]::Floor($actualBuildVer / 65535)) * 100)

  #______________________________________________
  # load AssemblyInfo file (AssemblyInfo.cs)
  # and modify its content (according to configuration)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $assemblyInfo = Get-Content -Path $assemblyInfoPath | Out-String
  #$aiOrig  = [System.IO.File]::ReadAllText($assemblyInfoPath)

  if ($_title -is [String] -and $_title.Length -gt 0)
  {
    $assemblyInfo = UpdateAssemblyInfoAttribute -assemblyInfo $assemblyInfo `
      -attributeName "AssemblyTitle" -attributeContent $_title
  }

  if ($_fileDescription -is [String] -and $_fileDescription.Length -gt 0)
  {
    $assemblyInfo = UpdateAssemblyInfoAttribute -assemblyInfo $assemblyInfo `
      -attributeName "AssemblyDescription" -attributeContent $_fileDescription
  }

  $assemblyInfo = UpdateAssemblyInfoAttribute -assemblyInfo $assemblyInfo `
    -attributeName "AssemblyCompany" -attributeContent $_companyName

  $assemblyInfo = UpdateAssemblyInfoAttribute -assemblyInfo $assemblyInfo `
    -attributeName "AssemblyProduct" -attributeContent $_productName

  $assemblyInfo = UpdateAssemblyInfoAttribute -assemblyInfo $assemblyInfo `
    -attributeName "AssemblyCopyright" -attributeContent $_copyright

  $assemblyInfo = UpdateAssemblyInfoAttribute -assemblyInfo $assemblyInfo `
    -attributeName "AssemblyVersion" -attributeContent "$_majorVer.$_minorVer.$intRelaseVersionNum.$_int16buildVer"

  $assemblyInfo = UpdateAssemblyInfoAttribute -assemblyInfo $assemblyInfo `
    -attributeName "AssemblyFileVersion" -attributeContent "$_majorVer.$_minorVer.$intRelaseVersionNum.$_int16buildVer"

  #______________________________________________
  # write new content to AssemblyInfo file
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  Set-Content -Path $assemblyInfoPath -Value $assemblyInfo
}


#==============================================================================
# UpdateAssemblyInfoAttribute - modifies content of specified attribute in AsseblyInfo
#==============================================================================
function UpdateAssemblyInfoAttribute
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $assemblyInfo,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $attributeName,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $attributeContent
  )
  $multilineChar = ""

  # search pattern
  # (?s) -- singleline => . (dot) also matches newline
  # (?<!\s*//\s*) -- Negative Lookbehind => pattern doesn't start with // (singleline comment)
  $s = "(?s)(?<!\s*//[^\n]*)(\[\s*assembly\s*:\s*$attributeName\s*\()(.*?)(\)\s*\])"

  # there is a multiline text - prefix it with @
  if ($attributeContent -match "`n") {
    $multilineChar = "@"
  }

  # replace with
  $r = "`$1$multilineChar`"$attributeContent`"`$3"

  # do it
  $assemblyInfo -ireplace $s, $r
}

#==============================================================================
# UpdateAndroidManifest - modifies AndroidManifest.xml
#==============================================================================
function UpdateAndroidManifest
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $configScriptPath,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $androidManifestPath,
	[parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $buildNumber
  )

  #______________________________________________
  # set default values
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $_useBuildNumberForVersionCode = $false
  
  #______________________________________________
  # load global macro values
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  . (Join-Path -Path $rootFolder -ChildPath "\cfg\global_values.ps1")

  #______________________________________________
  # load AndroidManifest configuration script
  # (cobfigured macro values)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  . $configScriptPath

  #______________________________________________
  # override some macro values (if you want)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $_buildVer = $buildNumber

  #______________________________________________
  # load AndroidManifest file (AndroidManifest.xml)
  # and modify its content (according to configuration)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $androidManifest = New-Object XML
  $androidManifest.Load($androidManifestPath)
  $versionName = "$_majorVer.$_minorVer.$_releaseVer.$_buildVer"
  if ($_useBuildNumberForVersionCode)
  {
    $versionCode = $_buildVer
  }
  else
  {
    $versionCode = [int]((Get-Date).Subtract((Get-Date "2012/01/01 00:00:00.000Z")).TotalSeconds / 10)
  }
 
  #$androidManifest | Get-Member
  $androidManifestNamespaceURI = "http://schemas.android.com/apk/res/android"
  $androidManifest.manifest.SetAttribute("versionName", $androidManifestNamespaceURI, $versionName)
  $androidManifest.manifest.SetAttribute("versionCode", $androidManifestNamespaceURI, $versionCode)
  
  #______________________________________________
  # write new content to AndroidManifest file
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $androidManifest.Save($androidManifestPath)
}

#==============================================================================
# GenerateVersionInfo - main function
#==============================================================================
function GenerateVersionInfo
{
  Param
  (
    [parameter(
      Mandatory=$true,
      HelpMessage = "Project root directory"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $ProjectRoot,
    [parameter(
        Mandatory=$true,
        HelpMessage = "Build number (for example: SVN revision number)"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $BuildNr
  )

  #______________________________________________
  # set environment
  # (file system paths to 3rd party executables)
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  # Resource builder
  $VI_Builder = Join-Path -Path $rootFolder -ChildPath "\bin\RC.exe"

  # trim last '\' or '/' -- only for output fomatting purposes
  $PR_tmp = $ProjectRoot.trimEnd("\/ ").Replace("\", "\\")

  $cnt = 0

  Write-Host "Starting Version Info Generator" -ForegroundColor Green
  Write-Host "  Project root = $ProjectRoot"
  Write-Host "  Build number = $BuildNr"
  Write-Host ""

  #______________________________________________
  # find all VersionInfo.ps1 files (configurations)
  # and generate Version.res files
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  Get-ChildItem -Path $ProjectRoot -Recurse -Include "VersionInfo.ps1" -Name |% {
    $cfgFile = (Join-Path -Path $ProjectRoot -ChildPath $_)
    $dstFile = (Join-Path -Path (Split-Path -Parent -Path $cfgFile) -ChildPath "Version.res")
    $cfgFile_out = $cfgFile -ireplace $PR_tmp, "[ProjectRoot]"
    $dstFile_out = $dstFile -ireplace $PR_tmp, "[ProjectRoot]"
    $cnt++
    Write-Host "$cnt. Generating Version Info" -ForegroundColor Green
    Write-Host "  CFG: $cfgFile_out"
    Write-Host "  DST: $dstFile_out"
    Write-Host ""
    UpdateRCVersionInfo -configScriptPath $cfgFile -versionInfoPath $dstFile -buildNumber $BuildNr
  }


  #______________________________________________
  # find all AssemblyInfo.ps1 files (configurations)
  # and modify AssemblyInfo.cs files
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  Get-ChildItem -Path $ProjectRoot -Recurse -Include "AssemblyInfo.ps1" -Name |% {
    $cfgFile = (Join-Path -Path $ProjectRoot -ChildPath $_)
    $dstFile = (Join-Path -Path (Split-Path -Parent -Path $cfgFile) -ChildPath "AssemblyInfo.cs")
    $cfgFile_out = $cfgFile -ireplace $PR_tmp, "[ProjectRoot]"
    $dstFile_out = $dstFile -ireplace $PR_tmp, "[ProjectRoot]"
    $cnt++
    Write-Host "$cnt. Updating Assembly Info" -ForegroundColor Green
    Write-Host "  CFG: $cfgFile_out"
    Write-Host "  DST: $dstFile_out"
    Write-Host ""
    UpdateAssemblyInfo -configScriptPath $cfgFile -assemblyInfoPath $dstFile -buildNumber $BuildNr
  }


  #______________________________________________
  # find all VersionInfoCustom.ps1 files
  # to generate custom version infos
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  Get-ChildItem -Path $ProjectRoot -Recurse -Include "VersionInfoCustom.ps1" -Name |% {
    $scriptFile = (Join-Path -Path $ProjectRoot -ChildPath $_)
    $cnt++

    Write-Host "$cnt. Generating Custom Version Info" -ForegroundColor Green
    Write-Host "  SCR: $scriptFile"
    Write-Host ""
    & $scriptFile -buildNumber $BuildNr
  }

  #______________________________________________
  # find all AndroidManifest.ps1 files (configurations)
  # and modify AndroidManifest.xml files
  #¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  Get-ChildItem -Path $ProjectRoot -Recurse -Include "AndroidManifest.ps1" -Name |% {
    $cfgFile = (Join-Path -Path $ProjectRoot -ChildPath $_)
    $dstFile = (Join-Path -Path (Split-Path -Parent -Path $cfgFile) -ChildPath "AndroidManifest.xml")
    $cfgFile_out = $cfgFile -ireplace $PR_tmp, "[ProjectRoot]"
    $dstFile_out = $dstFile -ireplace $PR_tmp, "[ProjectRoot]"
    $cnt++
    Write-Host "$cnt. Updating Android Manifest" -ForegroundColor Green
    Write-Host "  CFG: $cfgFile_out"
    Write-Host "  DST: $dstFile_out"
    Write-Host ""
    UpdateAndroidManifest -configScriptPath $cfgFile -androidManifestPath $dstFile -buildNumber $BuildNr
  }
  
  Write-Host "Completed..." -ForegroundColor Green
  Write-Host ""
}