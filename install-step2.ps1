#Requires -RunAsAdministrator
. .\Set-OpenWithVisualStudioCode.ps1
. .\Add-Path.ps1
. .\Install-KernelUpdate.ps1


Write-Host ""
Write-Host "Set WSL to version 2..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Install-KernelUpdate
wsl --set-default-version 2

Write-Host ""
Write-Host "Enable Windows 10 Developer Mode..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Remote Desktop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host ""
Write-Host "Trying to set: Windows Explorer Options" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
. .\Set-WindowsExplorerOptions.ps1
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar -DisableOpenFileExplorerToQuickAccess -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess

Write-Host ""
Write-Host "Trying to set: Taskbar Options" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
. .\Set-TaskbarOptions.ps1
Set-TaskbarOptions -Size Large -Lock -Combine Always

Write-Host ""
Write-Host "Pinning folders to Quick Access" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
.\Set-QuickAccess.ps1 -Action Pin -Path "D:\Alex"
.\Set-QuickAccess.ps1 -Action Pin -Path "D:\Dev"






$wingetApps = @(
    "Microsoft.WindowsTerminal",
    #   "Git.Git",
    "Notepad++.Notepad++",
    "7zip.7zip",
    "Microsoft.VisualStudioCode",
    "Insomnia.Insomnia",
    "WinSCP.WinSCP",
    "GitHub.GitHubDesktop",
    "Docker.DockerDesktop",
    "Google.Chrome",
    "Mozilla.Firefox"
)

foreach ($app in $wingetApps) {
    $appName = $app.Split(".")[0]
    Write-Host ""
    Write-Host "Installing $appName..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green

    winget install --id $appName -e
}

Write-Host ""
Write-Host "Add 7Zip to Path..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Add-Path -String "C:\Program Files\7-Zip"

Write-Host ""
Write-Host "Add Open With Code..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-OpenWithVisualStudioCode -Scope User -File -Directory

# Powershell profile (manual)

Write-Host ""
Write-Host "Install Oh-My-Posh..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
#New-Item -path $profile -type file –force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module oh-my-posh -Scope CurrentUser -Force

$installVS = Read-Host 'Do you want to install Visual Studio (y/n)'
if ($installVS -eq "y") {
    .\install-visualstudio.ps1
}


$installOffice = Read-Host 'Do you want to install Office 365 (y/n)'
if ($installOffice -eq "y") {
    .\Install-Office365.ps1
}