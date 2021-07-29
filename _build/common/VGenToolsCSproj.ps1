
#* ---------------------------------------------
#* Function: Generate_Version
#* ---------------------------------------------
function GeneratePackageVersion {
  Param
  (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $baseVersion,
    [Parameter(Mandatory = $false)]
    [String]
    $revisionNumber
  )

  Write-Host "Generating PackageVersion (baseVersion:$baseVersion, revision:$revisionNumber)"

  $splitNumber = $baseVersion.Split(".")

  if ( $splitNumber.Count -ge 3 -and $splitNumber.Count -le 4) {
    $majorNumber = $splitNumber[0]
    $minorNumber = $splitNumber[1]
    $patchNumber = $splitNumber[2]

    if ($splitNumber.Count -eq 4 -and $splitNumber[3] -ne 0) {
      throw "ERROR: version contains build number!"
    }

    if ([string]::IsNullOrEmpty($revisionNumber)) {
      $revisionNumber = 0
    }

    $packageVersion = $majorNumber + "." + $minorNumber + "." + $patchNumber + "." + $revisionNumber
    Write-Host "PackageVersion:$packageVersion"
    return $packageVersion
  }
  else {
    throw "ERROR: Something was wrong with the build number"
  }
}