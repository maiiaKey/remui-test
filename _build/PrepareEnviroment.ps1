# -----------------------
# Script initialization
# -----------------------
$ErrorActionPreference = "Stop"

$scriptRootDir = Split-Path -Path $myInvocation.MyCommand.Definition
$rootDir = Resolve-Path "$scriptRootDir\.."

# ----------------------
# Includes
# ----------------------
. "$scriptRootDir\common\CommonTools.ps1"

# ----------------------
# Script body
# ----------------------
# Script setting
$outputDir = "$rootDir\~output"
$tempDir = "$rootDir\~temp"

# Creating necessary folders
CreateAndClearDir -Path $tempDir
CreateAndClearDir -Path $outputDir