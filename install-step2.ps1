#Requires -RunAsAdministrator
. .\Set-OpenWithVisualStudioCode.ps1
. .\Add-Path.ps1
. .\Install-KernelUpdate.ps1
. .\Download-File.ps1

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






$wingetApps=@(
    "Microsoft.WindowsTerminal",
    "Git.Git",
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
    $appName=$app.Split(".")[0]
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


Write-Host ""
Write-Host "Downloading Visual Studio Installer..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
# https://github.com/microsoft/winget-pkgs/tree/master/manifests/Microsoft/VisualStudio/Community
$vsUrl="https://download.visualstudio.microsoft.com/download/pr/9b3476ff-6d0a-4ff8-956d-270147f21cd4/76e39c746d9e2fc3eadd003b5b11440bcf926f3948fb2df14d5938a1a8b2b32f/vs_Community.exe"
Download-File $vsUrl $PWD

Write-Host ""
Write-Host "Installing Visual Studio With vsconfig file..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Start-Process -FilePath vs_Community.exe -ArgumentList "--config", "$PWD\extra\.vsconfig", "--passive", "--wait" -Wait -PassThru

Write-Host ""
Write-Host "Installing Office..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Start-Process -FilePath "$PWD\office\setup.exe" -ArgumentList "/configure", "config-office365-ideal.xml" -Wait
