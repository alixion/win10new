


# create folders
New-Item -ItemType Directory -Force -Path D:\Dev
New-Item -ItemType Directory -Force -Path D:\Alex

.\Move-ProfileFolders.ps1

Write-Host ""
Write-Host "Congfiguring Power scheme to High performance" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
PowerCfg /SetActive "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
PowerCfg /Change monitor-timeout-ac 0
PowerCfg /Change disk-timeout-ac 0
PowerCfg /Change standby-timeout-ac 0

$computerName = Read-Host 'Enter New Computer Name'
Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
Rename-Computer -NewName $computerName

Write-Host "Add Feature Hyper-V" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

Write-Host ""
Write-Host "Enable WSL 2..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart


Restart-Computer