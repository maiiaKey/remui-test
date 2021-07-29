Function Build {
  Param
  (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $msBuildExePath,
    [Parameter(Mandatory = $false)]
    [String]
    $revisionNumber,
    [Parameter(Mandatory = $false)]
    [bool]
    $nexusPush,
    [Parameter(Mandatory = $false)]
    [String]
    $nexusRepository,
    [Parameter(Mandatory = $false)]
    [bool]
    $jenkinsConsoleFix
  )

    # ----------------------
    # Script initialization
    # ----------------------
    $ErrorActionPreference = "Stop"

    if ($jenkinsConsoleFix) {
      # (Jenkins truncating fix) Setting console buffer size (if this code is ommited console has max. 80 chars width)
      $Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (1024, $Host.UI.RawUI.WindowSize.Height)
    }
    else {
      # (Desktop console fix) Make console scrollable => BIG buffer
      $Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size ($Host.UI.RawUI.WindowSize.Width, 9999)
    }
    
    # ----------------------
    # Includes
    # ----------------------
    . "$scriptRootDir\common\CommonTools.ps1"
    . "$scriptRootDir\common\NugetTools.ps1"
    . "$scriptRootDir\common\NugetNexusTools.ps1"
    . "$scriptRootDir\common\VGenToolsCSproj.ps1"
	  . "$rootDir\_componentVersion\ComponentVersion.ps1"
    . "$scriptRootDir\ProjectTools.ps1"

    # ----------------------
    # Script body
    # ----------------------
    Write-Host "======================"
    Write-Host "MsBuild Pack"
    Write-Host "======================"

    $pathToSln = "REMUI.sln"
    $pathToOutput = "$rootDir\REMUI\bin\Release"

    # Change OutputType for UWP and iOS project to Library to generate dlls
    $pathToCsprojIOS = "$rootDir\REMUI\REMUI.iOS\REMUI.iOS.csproj"
    $pathToCsprojUWP = "$rootDir\REMUI\REMUI.UWP\REMUI.UWP.csproj"

    ChangeOutputType -pathToCsproj $pathToCsprojIOS -newOutputType "Library" 
    ChangeOutputType -pathToCsproj $pathToCsprojUWP -newOutputType "Library" 



    # Genearate version
    $packageVersion = GeneratePackageVersion -baseVersion $componentVersion -revisionNumber $revisionNumber

    # Restore and build
    Start-ProcessEx -executableFile "$msBuildExePath" -executableParams ".\$pathToSln /t:Restore"
    Start-ProcessEx -executableFile "$msBuildExePath" -executableParams ".\$pathToSln /t:Build /p:Configuration=Release /nodereuse:false /p:PackageVersion=$packageVersion /p:Version=$componentVersion /p:FileVersion=$packageVersion"
    
    # Revert OutputType for UWP and iOS project
    ChangeOutputType -pathToCsproj $pathToCsprojIOS -newOutputType "Exe" 
    ChangeOutputType -pathToCsproj $pathToCsprojUWP -newOutputType "AppContainerExe" 

    Write-Host "======================"
    Write-Host "Copy Assemblies"
    Write-Host "======================"

    .\_build\CopyAssemblies.ps1 `
      -outputPath $pathToOutput `
      -debugSymbols $true

    # ===== Copy nuget package template====
    $tempDir = "$rootDir\~temp"
    $nugetPackageTemplateDir = "$rootDir\_build\nugetPackageTemplate\*"

    Copy-Item -Path "$nugetPackageTemplateDir" -Destination "$tempDir\" -Recurse -Force

    $nuspecFile = "$tempDir\REMUI.nuspec"
    $outputDir = "$rootDir\~output"

    CreateAndClearDir -Path "$outputDir"

    Write-Host "======================"
    Write-Host "Nuget Pack"
    Write-Host "======================"
    
    Run-NugetPack -pathToNuspecFile "$nuspecFile" -outputPath "$outputDir" -version "$packageVersion"
    
    # parse nuspec
    $xml = [Xml] (Get-Content $nuspecFile)
    $packageId = ([string] $xml.package.metadata.id).Trim()

    $packageName = "$packageId.$packageVersion.nupkg"
    $packageNameAlt = "$packageId.$componentVersion.nupkg"

    $packagePath = "$outputDir\$packageName"
    $packagePathAlt = "$outputDir\$packageNameAlt"

    if ($nexusPush) {
      Write-Host "======================"
      Write-Host "Nexus Push"
      Write-Host "======================"
    }

    Write-Host "Check .nupkg exists..."
    if (![System.IO.File]::Exists($packagePath)) { 

      Write-Host "$packageName - missing."
      if ([System.IO.File]::Exists($packagePathAlt)) {

        # if revision is 0, version gets truncated 1.2.0.0 -> 1.2.0.
        Write-Host "$packageNameAlt - found." 
        Write-Host "Version got truncated. Renaming."
        Rename-Item -Path $packagePathAlt -NewName $packageName
      }
    }

    if (![System.IO.File]::Exists($packagePath)) { 
      throw "Error. Not found. ($packagePath)" 
    }
    else { 
      Write-Host "OK. ($packageName)" 
    }
    
    if ($nexusPush) {
      if ([string]::IsNullOrEmpty($nexusRepository)) { throw "Error. Nexus repository parameter null. ($packagePath)" }
      
      # Upload
      Run-NexusNugetPush -pathToNupkgFile "$packagePath" -repositoryName "$nexusRepository"
    }
}