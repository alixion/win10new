function Add-Path {
#Requires -Version 4
#Requires -RunAsAdministrator

<# 
 .SYNOPSIS
  Function to append string(s) to PATH environment variable

 .DESCRIPTION
  Function to append string(s) to PATH environment variable.
  The function will filter out duplicates in the input string, and existing PATH duplicates
  The function will not add a string if that path does not exist
  This affects the Machine PATH which is permanent, not just session PATH

 .PARAMETER String
  The string/path to be added to the PATH environment variable

 .EXAMPLE
  Add-Path -String 'D:\Sandbox','bla' -Verbose

 .LINK
  https://superwidgets.wordpress.com/category/powershell/

 .NOTES
  Function by Sam Boutros - v1.0 - 6 January, 2017
#>

    [CmdletBinding(ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
            [String[]]$String
    )

    Begin {
        # Identify current Path components
        $Paths = $env:Path.Split(';').ToLower() | Select-Object -Unique | Sort-Object
        Write-Verbose "Identified the following $($Paths.Count) path components on the computer $($env:COMPUTERNAME)"
        Write-Verbose ($Paths | Out-String)

        # Identify input, remove duplicates and bad paths
        $InputList = $String.ToLower() | Select-Object -Unique 
        $CleanedInputList = @()
        $InputList | ForEach-Object { if (Test-Path $_) { $CleanedInputList += $_ } }
        Write-Verbose "Processing the following new paths (removed duplicates and bad paths):"
        Write-Verbose ($CleanedInputList | Out-String)
    }

    Process{
        $OutputList = $Paths + $CleanedInputList | Select-Object -Unique
        Write-Verbose "Committing the following $($OutputList.Count) path components:"
        Write-Verbose ($OutputList | Out-String)

        [Environment]::SetEnvironmentVariable( "Path", $($OutputList -join ';'), [System.EnvironmentVariableTarget]::Machine )
        # This changes the registry key HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment which requires elevation
    }

    End {}
}