#Requires -RunAsAdministrator
Import-Module -Name .\win10new.psm1 -PassThru -Force

Write-Host ""
Write-Host "Set WSL to version 2..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Install-KernelUpdate -FileName "wsl_update_x64.msi" -Url "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
wsl --set-default-version 2

Write-Host ""
Write-Host "Enable Windows 10 Developer Mode..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

Write-Host ""
Write-Host "Enable Remote Desktop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host ""
Write-Host "Trying to set: Windows Explorer Options" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar -DisableOpenFileExplorerToQuickAccess -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess

Write-Host ""
Write-Host "Trying to set: Taskbar Options" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-TaskbarOptions -Size Large -Lock -Combine Always


$wingetApps = @(
    "Microsoft.PowerShell"
    "Microsoft.WindowsTerminal",
    "GNU.MidnightCommander"
    #   "Git.Git",
    "Notepad++.Notepad++",
    "7zip.7zip",
    "Microsoft.VisualStudioCode",
    "Insomnia.Insomnia",
    "WinSCP.WinSCP",
    "GitHub.GitHubDesktop",
    "Docker.DockerDesktop",
    "Google.Chrome",
    "Mozilla.Firefox",
    #"Armin2208.WindowsAutoNightMode",
    "JetBrains.Toolbox",
    "Logitech.Options",
    "Microsoft.PowerToys",
    "Toggl.TogglDesktop",
    "Typora.Typora",
    "VideoLAN.VLC",
    "AntibodySoftware.WizTree",
    "XnSoft.XnViewClassic",
    "Zoom.Zoom",
    "Doist.Todoist",
    "PeterPawlowski.foobar2000"
    "JanDeDobbeleer.OhMyPosh",
    
)

foreach ($app in $wingetApps) {
    $appName = $app.Split(".")[1]
    Write-Host ""
    Write-Host "Installing $appName..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green

    winget install --id $app -e
}

Write-Host ""
Write-Host "Add 7Zip to Path..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Add-Path -String "C:\Program Files\7-Zip"

Write-Host ""
Write-Host "Add Open With Code..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-OpenWithVisualStudioCode -Scope User -File -Directory # changes location, must reset to script path

Write-Host ""
Write-Host "Copy Windows Terminal settings.json ..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
New-Item -Path $HOME\WindowsTerminalAssets -ItemType Directory -Force
Copy-Item -Path  $PWD\extra\WindowsTerminal\prime-logo.png -Destination $HOME\WindowsTerminalAssets
Copy-Item -Path  $PWD\extra\WindowsTerminal\settings.json -Destination "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"

Get-RemoteFile "https://gist.githubusercontent.com/shanselman/1f69b28bfcc4f7716e49eb5bb34d7b2c/raw/ohmyposhv3-v2.json" $env:LocalAppData\Programs\oh-my-posh\themes


$installVS = Read-Host 'Do you want to install Visual Studio (y/n)'
if ($installVS -eq "y") {
    .\install-visualstudio.ps1
}

$installOffice = Read-Host 'Do you want to install Office 365 (y/n)'
if ($installOffice -eq "y") {
    .\Install-Office365.ps1
}
