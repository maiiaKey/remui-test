Param
(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [String]
  $outputPath, 
  [Parameter(Mandatory = $true)]
  [Boolean]
  $debugSymbols
)

$tempDir = "$rootDir\~temp"

# Create output dir ----

CreateAndClearDir -Path "$tempDir"

# Include pdbs  --------

if ($debugSymbols) { $ext = "*" }
else { $ext = "dll" }

# Netstandard ----------

$srcDir = "$outputPath\netstandard2.0"
$dstDir = "$tempDir\lib\netstandard2.0"
CreateAndClearDir -Path "$dstDir"

Copy-Item -Path "$srcDir\REMUI.$ext" -Destination "$dstDir"

# UAP ------------------

$srcDir = "$outputPath\uap"
$dstDir = "$tempDir\lib\uap10.0.16299"
CreateAndClearDir -Path "$dstDir"

Copy-Item -Path "$srcDir\REMUI.$ext" -Destination "$dstDir"

# Android --------------

$srcDir = "$outputPath\monoandroid"
$dstDir = "$tempDir\lib\monoandroid10.0"
CreateAndClearDir -Path "$dstDir"

Copy-Item -Path "$srcDir\REMUI.$ext" -Destination "$dstDir"

# iOS ------------------

$srcDir = "$outputPath\xamarinios"
$dstDir = "$tempDir\lib\xamarinios10"
CreateAndClearDir -Path "$dstDir"

Copy-Item -Path "$srcDir\REMUI.$ext" -Destination "$dstDir"
