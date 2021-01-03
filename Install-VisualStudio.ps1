Write-Host ""
Write-Host "Downloading Visual Studio Installer..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
# https://github.com/microsoft/winget-pkgs/tree/master/manifests/Microsoft/VisualStudio/Community
$vsUrl = "https://download.visualstudio.microsoft.com/download/pr/9b3476ff-6d0a-4ff8-956d-270147f21cd4/76e39c746d9e2fc3eadd003b5b11440bcf926f3948fb2df14d5938a1a8b2b32f/vs_Community.exe"
Get-RemoteFile $vsUrl $PWD

Write-Host ""
Write-Host "Installing Visual Studio With vsconfig file..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Start-Process -FilePath vs_Community.exe -ArgumentList "--config", "$PWD\extra\.vsconfig", "--passive", "--wait" -Wait -PassThru