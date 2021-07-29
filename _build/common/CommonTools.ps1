$ErrorActionPreference = "Stop"

#* ---------------------------------------------
#* Function: CreateAndClearDir
#* ---------------------------------------------
function CreateAndClearDir
{
  Param
  (
    [parameter(Mandatory=$true)]
    [String]
    $path
  )

  if((Test-Path -Path $path))
  {
    Remove-Item -Path (Join-Path -Path $path -ChildPath "\*") -Recurse -Force
  }
  else
  {
    New-Item -Path $path -ItemType "Directory" -Force
  }
}

#* ---------------------------------------------
#* Function: Start-ProcessEx
#* ---------------------------------------------
function Start-ProcessEx
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $executableFile,
    [String]
    $executableParams
  )

  try
  {
    if($executableParams -eq "")
    {
      $process = Start-Process -FilePath $executableFile -PassThru -NoNewWindow
    }
    else
    {
      $process = Start-Process -FilePath $executableFile -ArgumentList $executableParams -PassThru -NoNewWindow
    }
  }
  catch
  {
    throw("Unable to execute `"$executableFile $executableParams`", executable file probably does not exists or it is not valid executable file.")
  }
  
 
  Wait-Process -InputObject $process
  
  # need to handle pre-4.0 Powershell bug
  $process.HasExited
  $exitCode = $process.GetType().GetField("exitCode", "NonPublic,Instance").GetValue($process)
  if($exitCode -ne 0)
  {
    throw("Execution of `"$executableFile $executableParams`" failed; ExitCode: " + $process.ExitCode)
  }
}

#* ---------------------------------------------
#* Function: Get-ServerRole
#* ---------------------------------------------
function Get-ServerRole
{
  Param
  (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $componentName
  )
  
  # ================
  # Description
  # ================
  # Function returns Server role for Comonent $componentName from mapping table $serverRoles
  # It can be used in Jenkins jobs to automatically get Server role for Component
  
  $jobServer = "JobServer"
  $appServer = "AppServer"
  $dbServer = "Database"
  $dwhServer = "DataWarehouse"
  $syncServer = "SyncServer"
  
  # 2D array containing mapping for Component name to Server role
  $serverRoles = @{`
                   "OtherInterface" = $jobServer; `
                   "IDocInterface"  = $jobServer; `
                   "ReportingDataIntegration" = $jobServer; `
                   "WebConsole"     = $appServer; `
                   "Reporting"      = $appServer; `
                   "Service"        = $appServer; `
                   "PrintTemplate"  = $appServer; `
                   "OrderConfig"    = $appServer; `
                   "Win"             = $appServer; `
                   "Android"        = $appServer; `
                   "Database"       = $dbServer; `
                   "ReportingDB"    = $dwhServer; `
                   "Mobilink"       = $syncServer `
                  }
  
  if($serverRoles.ContainsKey($componentName))
  {
    return $serverRoles.Get_Item($componentName)
  }
  else
  {
    throw("Unsupported Component")
  }
}
