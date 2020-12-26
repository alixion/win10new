. ./Set-OpenWithVisualStudioCode.ps1
. ./Add-Path.ps1


# winget essentials
Write-Host ""
Write-Host "Installing Windows Terminal..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
winget install --id Microsoft.WindowsTerminal
Write-Host "Installing Notepad++..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
winget install Notepad++
Write-Host "Installing 7zip and adding it to path..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
winget install 7Zip
# add 7zip to path
# todo: make AddToPath function
#$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
#$newpath = “$oldpath;C:\Program Files\7-Zip”
#Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
Add-Path -String "C:\Program Files\7-Zip"

Write-Host "Install VS Code..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
winget install Microsoft.VisualStudioCode -e
Write-Host "Add Open With Code..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-OpenWithVisualStudioCode -Scope User -File -Directory



Write-Host "Set WSL to version 2..." -ForegroundColor Green
wsl --set-default-version 2 # requires kernel update

#Install-Package NuGet -Force



