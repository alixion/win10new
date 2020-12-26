function Install-KernelUpdate {
    $file = 'wsl_update_x64.msi'
    $link = "https://wslstorestorage.blob.core.windows.net/wslblob/$file"

    $tmp = "$env:TEMP\$file"
    #$client = New-Object System.Net.WebClient
    #$client.DownloadFile($link, $tmp)
    If (!(Test-Path -Path $tmp ))
    {
        Write-Host "Downloading Kernel Update for WSL2"
        Invoke-WebRequest -Uri $link -OutFile $tmp
    }
    
    
    Write-Host "Installing Kernel Update for WSL2"
    Start-Process msiexec.exe -Wait -ArgumentList "/quiet /i $tmp"
    Write-Host "Done"
    Remove-Item $tmp   
}