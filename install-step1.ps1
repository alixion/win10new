Import-Module -Name .\win10new.psm1 -PassThru -Force

$computerName = Read-Host 'Enter New Computer Name'
Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
Rename-Computer -NewName $computerName

# create folders
New-Item -ItemType Directory -Force -Path D:\Dev
Set-QuickAccess -Action Pin -Path "D:\Dev"


Write-Host ""
Write-Host "Moving Library folders to D:" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$confirm = Read-Host "Do you want to move the profile folders for the current user (Y/N)?"
if ($confirm -match "[yY]") {
    $toFolder = Read-Host "Enter new location for profile folders"
    $itemsToMove = "Desktop", "Downloads", "Pictures", "Documents", "Music", "Videos"


    foreach ($item in $itemsToMove) {
        Move-UserShellFolder -UserFolder $item -FolderPath "$toFolder\$item" -RemoveDesktopINI
    }
    Set-QuickAccess -Action Pin -Path $toFolder
    Restart-Explorer    
}


Write-Host ""
Write-Host "Congfiguring Power scheme to High performance" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-PowerScheme


Write-Host ""
Write-Host "Add Feature Hyper-V" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

Write-Host ""
Write-Host "Enable WSL 2..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

Restart-Computer