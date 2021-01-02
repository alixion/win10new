Write-Host ""
Write-Host "Installing Office..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Start-Process -FilePath "$PWD\office\setup.exe" -ArgumentList "/configure", "config-office365-ideal.xml" -Wait