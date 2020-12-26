Function Set-OpenWithVisualStudioCode {
        <#
	.SYNOPSIS
		Will set Open with for Visual Studio Code
	
	.DESCRIPTION
        Will set Open with for Visual Studio Code.
	
	.PARAMETER Scope
        For User or System installation
        
	.PARAMETER File
        Will set Open with for files

	.PARAMETER Directory
        Will set Open with for directory

	.EXAMPLE
		Set-OpenWithVisualStudioCode -Scope User -File -Directory
	
	.EXAMPLE
        Set-OpenWithVisualStudioCode -Scope System -File -Directory

    .NOTES
		NAME:       Set-OpenWithVisualStudioCode
		AUTHOR:     Fredrik Wall, fredrik@poweradmin.se
		TWITTER:    @walle75
		BLOG:       https://www.fredrikwall.se/
		CREATED:    2020-01-01
		VERSION:    1.0

	.LINK
		https://github.com/FredrikWall
#>
        [CmdletBinding()]
        Param (
                [Parameter(Mandatory = $true)]
                [ValidateSet('User', 'System')]
                $Scope,
                [Parameter(Mandatory = $false)]
                [Switch]$File,
                [Parameter(Mandatory = $false)]
                [Switch]$Directory
        )
        
        
        New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR | Out-Null
        

        if ($Scope -eq "User") {
                $PathToVSCode = "$env:LOCALAPPDATA\Programs\Microsoft VS Code"
                if (!(Test-Path "$PathToVSCode\Code.exe")) {
                        Write-Output "No User installation found"
                        Break
                }
        }

        if ($Scope -eq "System") {
                $PathToVSCode = "$env:ProgramFiles\Microsoft VS Code"
                if (!(Test-Path "$PathToVSCode\Code.exe")) {
                        Write-Output "No System installation found"
                        Break
                }
        }

        if ($File) {
                If (!(Test-Path -LiteralPath "HKCR:\*\shell\VSCode")) {
                        # Right click on a file
                        try {
                                Set-Location -LiteralPath "HKCR:\*"
                                New-Item -Path ".\shell" -Name "VSCode" -Force | Out-Null
                                New-Item -Path ".\shell\VSCode" -Name "command" -Force | Out-Null
                                Set-ItemProperty -Path ".\shell\VSCode" -Name '(Default)' -Value "Open with Code" -Type ExpandString
                                New-ItemProperty -Path ".\shell\VSCode" -Name 'Icon' -PropertyType ExpandString -Value "$PathToVSCode\Code.exe" | Out-Null
                                Set-ItemProperty -Path ".\shell\VSCode\command" -Name '(Default)' -Value "`"$PathToVSCode\Code.exe`" `"%1`"" -Type ExpandString
                                Write-Output "Open with Code set for files"
                        }
                        catch {
                                Write-Output "Error: Open with Code not set for files"
                                Write-Output "$_"
                        }
                        
                }
                else {
                        Write-Output "Open with Code already set for files"
                }
        }
 
        if ($Directory) {
                If (!(Test-Path -LiteralPath "HKCR:\Directory\shell\VSCode")) {
                        # Right click on a folder
                        try {
                                Set-Location -LiteralPath "HKCR:\Directory"
                                New-Item -Path ".\shell" -Name "VSCode" -Force | Out-Null
                                New-Item -Path ".\shell\VSCode" -Name "command" -Force | Out-Null
                                Set-ItemProperty -Path ".\shell\VSCode" -Name '(Default)' -Value "Open with Code" -Type ExpandString
                                New-ItemProperty -Path ".\shell\VSCode" -Name 'Icon' -PropertyType ExpandString -Value "$PathToVSCode\Code.exe" | Out-Null
                                Set-ItemProperty -Path ".\shell\VSCode\command" -Name '(Default)' -Value "`"$PathToVSCode\Code.exe`" `"%V`"" -Type ExpandString

                                # Right click inside a folder
                                Set-Location -LiteralPath "HKCR:\Directory\Background"
                                New-Item -Path ".\shell" -Name "VSCode" -Force | Out-Null
                                New-Item -Path ".\shell\VSCode" -Name "command" -Force | Out-Null
                                Set-ItemProperty -Path ".\shell\VSCode" -Name '(Default)' -Value "Open with Code" -Type ExpandString
                                New-ItemProperty -Path ".\shell\VSCode" -Name 'Icon' -PropertyType ExpandString -Value "$PathToVSCode\Code.exe" | Out-Null
                                Set-ItemProperty -Path ".\shell\VSCode\command" -Name '(Default)' -Value "`"$PathToVSCode\Code.exe`" `"%V`"" -Type ExpandString

                                Write-Output "Open with Code set for directory"
                        }
                        catch {
                                Write-Output "Error: Open with Code not set for files"
                                Write-Output "$_"
                        }
                }
                else {
                        Write-Output "Open with Code already set for directory"
                }
        }
}
