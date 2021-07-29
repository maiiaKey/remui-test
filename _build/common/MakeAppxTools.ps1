$ErrorActionPreference = "Stop"

$makeappxTools_ScriptRoot = Split-Path -Path $myInvocation.MyCommand.Definition

# ----------------------
# Includes
# ----------------------
. "$makeappxTools_ScriptRoot\CommonTools.ps1"

#* ---------------------------------------------
#* Function: Set-IdentityName
#* ---------------------------------------------
function Set-IdentityName
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [XML]
    $xmlManifestFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $identityName
  )

  "Set-IdentityName $identityName"
  $xmlManifestFile.Package.Identity.SetAttribute("Name", $identityName)
}

#* ---------------------------------------------
#* Function: Set-Publisher
#* ---------------------------------------------
function Set-Publisher
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [XML]
    $xmlManifestFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $publisher
  )

  "Set-Publisher $publisher"
  $xmlManifestFile.Package.Identity.SetAttribute("Publisher", $publisher)
}

#* ---------------------------------------------
#* Function: Add-Capability
#* ---------------------------------------------
function Add-Capability
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [XML]
    $xmlManifestFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $capabilityName
  )

  "Add-Capability $capabilityName"
  $capabilityNode = $xmlManifestFile.CreateElement("Capability", $xmlManifestFile.Package.xmlns)
  $capabilityNode.SetAttribute("Name", $capabilityName)
  $xmlManifestFile.Package.Capabilities.InsertAfter($capabilityNode, $xmlManifestFile.Package.Capabilities.Node)
}

#* ---------------------------------------------
#* Function: Remove-Capability
#* ---------------------------------------------
function Remove-Capability
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [XML]
    $xmlManifestFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $capabilityName
  )

  "Remove-Capability $capabilityName" 
  $capabilityNodes = $xmlManifestFile.Package.Capabilities.Capability | Where-Object { $_.Name -eq $capabilityName }

  if ($capabilityNodes -ne $null) {
    foreach ($item in $capabilityNodes) {
        $null = $item.ParentNode.RemoveChild($item) 
    }
  }
}


#* ---------------------------------------------
#* Function: Add-FileTypeAssociation
#* ---------------------------------------------
function Add-FileTypeAssociation
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [XML]
    $xmlManifestFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $fileTypeAssociationName,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $fileType
  )

  "Add-FileTypeAssociation $fileTypeAssociationName $filteType" 
  $fileTypeNode = $xmlManifestFile.CreateElement("FileType", $xmlManifestFile.Package.xmlns)
  $fileTypeNode.InnerText = $fileType

  $supportedFileTypesNode = $xmlManifestFile.CreateElement("SupportedFileTypes", $xmlManifestFile.Package.xmlns)
  $supportedFileTypesNode.AppendChild($fileTypeNode)
      
  $fileTypeAssociationNode = $xmlManifestFile.CreateElement("FileTypeAssociation", $xmlManifestFile.Package.xmlns)
  $fileTypeAssociationNode.SetAttribute("Name", $fileTypeAssociationName)
  $fileTypeAssociationNode.AppendChild($supportedFileTypesNode)
 
  $extensionNode = $xmlManifestFile.CreateElement("Extension", $xmlManifestFile.Package.xmlns)
  $extensionNode.SetAttribute("Category", "windows.fileTypeAssociation")
  $extensionNode.AppendChild($fileTypeAssociationNode)

  $app = $xmlManifestFile.Package.Applications.Application | Where-Object { $_.Id -eq "App" }
  $app.extensions.AppendChild($extensionNode)
}

#* ---------------------------------------------
#* Function: Remove-FileTypeAssociation
#* ---------------------------------------------
function Remove-FileTypeAssociation
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [XML]
    $xmlManifestFile,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $fileTypeAssociationName
  )

  "Remove-FileTypeAssociation $fileTypeAssociationName" 
  $nodes = $xmlManifestFile.Package.Applications.Application.Extensions.Extension | Where-Object { $_.FileTypeAssociation.Name -eq $fileTypeAssociationName }

  if ($nodes -ne $null) {
    foreach ($item in $nodes) {
        $null = $item.ParentNode.RemoveChild($item) 
    }
  }
}

#* ---------------------------------------------
#* Function: Set-PackageVersion
#* ---------------------------------------------
function Set-PackageVersion
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $manifestFilePath,
    [Parameter(Mandatory=$true)]
    [string]
    $version
  )

  $xmlManifestFile = New-Object -TypeName XML
  $xmlManifestFile.Load($manifestFilePath)
  $xmlManifestFile.Package.Identity.SetAttribute("Version", $version)
  $xmlManifestFile.Save($manifestFilePath)
}

#* ---------------------------------------------
#* Function: Prepare-Manifest
#* ---------------------------------------------
function Prepare-Manifest
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $manifestFilePath,
    [Switch]
    $withDocumentsCapability,
    [Parameter(Mandatory=$true)]
    [string]
    $version,
	[string]
    $identityName,
	[string]
    $publisher
  )

  $capabilityName = "documentsLibrary"
  $fileTypeAssociationName = "configuration"
  $fileType = ".xml"

  $xmlManifestFile = New-Object -TypeName XML
  $xmlManifestFile.Load($manifestFilePath)

  $xmlManifestFile.Package.Identity.SetAttribute("Version", $version)

  Remove-Capability -xmlManifestFile $xmlManifestFile -capabilityName $capabilityName
  Remove-FileTypeAssociation -xmlManifestFile $xmlManifestFile -fileTypeAssociationName $fileTypeAssociationName

  if ($withDocumentsCapability) {
    Add-Capability -xmlManifestFile $xmlManifestFile -capabilityName $capabilityName
    Add-FileTypeAssociation -xmlManifestFile $xmlManifestFile -fileTypeAssociationName $fileTypeAssociationName -fileType $fileType
  }

  Set-IdentityName -xmlManifestFile $xmlManifestFile -identityName $identityName
  Set-Publisher -xmlManifestFile $xmlManifestFile -publisher $publisher

  $xmlManifestFile.Save($manifestFilePath)
}

#* ---------------------------------------------
#* Function: Create-ProjectItem
#* ---------------------------------------------
function Create-ProjectItem
{
  Param
  (
    [XML]
    $xmlProjectFile,
    [string]
    $itemName
  )

    "creating " + $itemName
    $itemGroup = $xmlProjectFile.CreateElement("ItemGroup", $xmlProjectFile.Project.xmlns)
    $dbContent = $xmlProjectFile.CreateElement("Content", $xmlProjectFile.Project.xmlns)
    $dbContent.SetAttribute("Include", $itemName)
    $itemGroup.AppendChild($dbContent)
    $xmlProjectFile.Project.AppendChild($itemGroup)
}

#* ---------------------------------------------
#* Function: Exclude-ProjectItem
#* ---------------------------------------------
function Exclude-ProjectItem
{
  Param
  (
    [XML]
    $xmlProjectFile,
    [string]
    $itemName
  )

    $includes = $xmlProjectFile.Project.ItemGroup.Content | where-Object { $_.Include -ne $null }
    $databaseIncludes = $includes | where-object { $_.Include.StartsWith($itemName) }
    
    if ($databaseIncludes -ne $null) {

        foreach ($item in $databaseIncludes) {

            "excluding " + $item.Include

            $dbContent = $xmlProjectFile.CreateElement("None", $xmlProjectFile.Project.xmlns)
            $dbContent.SetAttribute("Include", $item.Include);

            $item.ParentNode.AppendChild($dbContent)
            $null = $item.ParentNode.RemoveChild($item)              
        }
    }
}

#* ---------------------------------------------
#* Function: Remove-ProjectItem
#* ---------------------------------------------
function Remove-ProjectItem
{
  Param
  (
    [XML]
    $xmlProjectFile,
    [string]
    $itemName
  )

    $includes = $xmlProjectFile.Project.ItemGroup.None | where-Object { $_.Include -ne $null }
    $databaseIncludes = $includes | where-object { $_.Include.StartsWith($itemName) }

    if ($databaseIncludes -ne $null) {

        foreach ($item in $databaseIncludes) {

            "removing " + $item.Include
            $null = $item.ParentNode.RemoveChild($item)              
        }
    }
}

#* ---------------------------------------------
#* Function: Include-ProjectItem
#* ---------------------------------------------
function Include-ProjectItem
{
  Param
  (
    [XML]
    $xmlProjectFile,
    [string]
    $itemName,
    [switch]
    $include,
    [switch]
    $create,
    [switch]
    $delete
  )

  if ($include) {
    $includes = $xmlProjectFile.Project.ItemGroup.None | where-Object { $_.Include -ne $null }
    $databaseIncludes = $includes | where-object { $_.Include.StartsWith($itemName) }
    
    if ($databaseIncludes -ne $null) {

        foreach ($item in $databaseIncludes) {

            "including " + $item.Include
            $dbContent = $xmlProjectFile.CreateElement("Content", $xmlProjectFile.Project.xmlns)
            $dbContent.SetAttribute("Include", $item.Include);
            $item.ParentNode.AppendChild($dbContent)
            $null = $item.ParentNode.RemoveChild($item)              
        }
     }
     else 
     {
         if ($create)
         {
            Exclude-ProjectItem -xmlProjectFile $xmlProjectFile -itemName $itemName
            Remove-ProjectItem -xmlProjectFile $xmlProjectFile -itemName $itemName
            Create-ProjectItem -xmlProjectFile $xmlProjectFile -itemName $itemName
         }
     }
  }
  else {
    Exclude-ProjectItem -xmlProjectFile $xmlProjectFile -itemName $itemName

    if ($delete)
    {
        Remove-ProjectItem -xmlProjectFile $xmlProjectFile -itemName $itemName
    }
  }
}

#* ---------------------------------------------
#* Function: Prepare-ProjectFile
#* ---------------------------------------------
function Prepare-ProjectFile
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $projectFilePath,
    [Parameter(Mandatory=$true)]
    [string]
    $certificateKeyFile,
    [Parameter(Mandatory=$true)]
    [string]
    $certifcateThumbPrint,
    [switch]
    $includeDemoDatabase,
    [switch]
    $includeStoreAssociation
  )

  $xmlProjectFile = New-Object -TypeName XML
  $xmlProjectFile.Load($projectFilePath)

  $propertyGroups = $xmlProjectFile.Project.PropertyGroup | Where-Object { $_.PackageCertificateKeyFile -ne $null }

  if ($propertyGroups -ne $null) {
    foreach ($item in $propertyGroups) {
        "Set PackageCertificateKeyFile = $certificateKeyFile"
        $item.PackageCertificateKeyFile = $certificateKeyFile
        "Set PackageCertificateThumbprint = $certifcateThumbPrint"
        $item.PackageCertificateThumbprint = $certifcateThumbPrint
    }
  }

  if ($includeDemoDatabase)
  {   
    Include-ProjectItem -xmlProjectFile $xmlProjectFile -itemName "DB\demo_" -include
  }
  else
  {
    Include-ProjectItem -xmlProjectFile $xmlProjectFile -itemName "DB\demo_"
  }

  if ($includeStoreAssociation)
  {
    Include-ProjectItem -xmlProjectFile $xmlProjectFile -itemName "Package.StoreAssociation.xml" -include -create
  }
  else
  {
    Include-ProjectItem -xmlProjectFile $xmlProjectFile -itemName "Package.StoreAssociation.xml" -delete
  }

  $xmlProjectFile.Save($projectFilePath)
}

#* ---------------------------------------------
#* Function: Add-SignListItem
#* ---------------------------------------------
function Add-SignListItem
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $signListPath,
    [Parameter(Mandatory=$true)]
    [string]
    $item
  )

  "Adding sign list item: $item to $signListPath"

  $doc = New-Object -TypeName XML
  $fileNameNode = $doc.CreateElement("FileName")
  $fileNameNode.InnerText = $item

  if (Test-Path ($signListPath)) {
    $doc.Load($signListPath)
    $doc.FileNames.AppendChild($fileNameNode);
  }
  else {
    $decl = $doc.CreateXmlDeclaration("1.0", "utf-8", $null)
    $doc.InsertBefore($decl, $doc.DocumentElement)

    $fileNamesNode = $doc.CreateElement("FileNames")
    $fileNamesNode.AppendChild($fileNameNode);

    $doc.AppendChild($FileNamesNode)
  }

  $doc.Save($signListPath);
}

#* ---------------------------------------------
#* Function: Run-MakeAppx
#* ---------------------------------------------
function Run-MakeAppx
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $inputDirectoryPath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $filepath
  )

  $executableParams = "pack /v /o /d `"$inputDirectoryPath`" /p `"$filepath`" /l"

  Start-ProcessEx -executableFile "$makeappxTools_ScriptRoot\bin\MakeAppx\makeappx.exe" -executableParams $executableParams
}

#* ---------------------------------------------
#* Function: Run-MakePriCreateConfig
#* ---------------------------------------------
function Run-MakePriCreateConfig
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $configXmlFilePath
  )

  $executableParams = "createconfig /o /cf `"$configXmlFilePath`" /dq lang-en"

  Start-ProcessEx -executableFile "$makeappxTools_ScriptRoot\bin\MakeAppx\makepri.exe" -executableParams $executableParams
}

#* ---------------------------------------------
#* Function: Run-MakePriNew
#* ---------------------------------------------
function Run-MakePriNew
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $projectRootDirectoryPath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $manifestFilePath,	
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $configXmlFilePath,	
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $outputFilePath	
  )

  $executableParams = "new /o /pr `"$projectRootDirectoryPath`" /mn `"$manifestFilePath`" /cf `"$configXmlFilePath`" /of `"$outputFilePath`""

  Start-ProcessEx -executableFile "$makeappxTools_ScriptRoot\bin\MakeAppx\makepri.exe" -executableParams $executableParams
}

#* ---------------------------------------------
#* Function: Run-PublicPDBCopy
#* ---------------------------------------------
function Run-PublicPDBCopy
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $oldPDBfilepath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $newPDBfilepath
  )

  $executableParams = "`"$oldPDBfilepath`" `"$newPDBfilepath`" -p "

  Start-ProcessEx -executableFile "$makeappxTools_ScriptRoot\bin\MakeAppx\pdbcopy.exe" -executableParams $executableParams
}

#* ---------------------------------------------
#* Function: Run-SignTool
#* ---------------------------------------------
function Run-SignTool
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $keyPath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $appxPath
  )

  $executableParams = "sign /a /v /fd SHA256 /f `"$keyPath`" `"$appxPath`""

  Start-ProcessEx -executableFile "$makeappxTools_ScriptRoot\bin\MakeAppx\signtool.exe" -executableParams $executableParams
}

#* ---------------------------------------------
#* Function: Run-MakeAppxBundle
#* ---------------------------------------------
function Run-MakeAppxBundle
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $inputDirectoryPath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $filepath
  )

  $executableParams = "bundle /v /o /d `"$inputDirectoryPath`" /p `"$filepath`""

  Start-ProcessEx -executableFile "$makeappxTools_ScriptRoot\bin\MakeAppx\makeappx.exe" -executableParams $executableParams
}

#* ---------------------------------------------
#* Function: Copy-Root
#* ---------------------------------------------
function Copy-RootItem
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Source,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $DestRoot
  )   
    # Construct destination filename using relative path and destination root
    $Destination = '{0}\{1}' -f $DestRoot, (Resolve-Path -Relative -Path:$Source).TrimStart('.\')

    # If new destination doesn't exist, create it
    If(-Not (Test-Path ($DestDir = Split-Path -Parent -Path:$Destination))) { 
        New-Item -Type:Directory -Path:$DestDir -Force -Verbose 
    }

    # Copy old item to new destination
    Copy-Item -Path:$Source -Destination:$Destination -Verbose
}

#* ---------------------------------------------
#* Function: Copy-Root
#* ---------------------------------------------
function Copy-Root
{
  Param
  (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
     $OldRoot,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
     $DestRoot,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $include,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $exclude
  )   

    # Go to old root so relative paths are correct
    Set-Location $OldRoot

    Get-ChildItem -Recurse -Include $include -Exclude $exclude| 
    ForEach-Object { 
        # Save full name to avoid issues later
        $Source = $_.FullName

        Copy-RootItem -Source $_.FullName -DestRoot $DestRoot
    }
}