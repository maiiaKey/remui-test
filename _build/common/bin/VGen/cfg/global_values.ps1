#==============================================================================
# Global settings
#==============================================================================

$_companyName = "Exceedra by TELUS"
$_copyright = "Copyright ©" + (&{If((Get-Date).year -eq "2021") {(Get-Date).year} Else {"2021-"+(Get-Date).year}}) + " Exceedra by TELUS"

$_buildVer = ""