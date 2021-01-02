Param(
    [string] $toFolder = "D:\Users\" + ($env:APPDATA).Split("\")[-3]
)

. .\Restart-Explorer.ps1

Write-Host ""
Write-Host "Moving Library folders to D:" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$confirm = Read-Host "Do you want to move the profile folders for the current user to $toFolder (Y/N)?"
if ($confirm -notmatch "[yY]") {
    Exit
}

$itemsToMove = "{374DE290-123F-4565-9164-39C4925E467B}", "Desktop", "My Pictures", "Personal", "My Music", "My Video"


foreach ($item in $itemsToMove) {
    $oldPath = $(Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "$item")
    $folderName = $oldPath.Split("\")[-1]
    
    $newPath = $toFolder + "\" + $folderName
    if (!(Test-Path $newPath)) {
        New-Item -ItemType Directory -Force -Path $newPath
    }
    $ROBOCOPY_COMMAND = "robocopy /e /MOVE /copyall /r:0 /mt:4 /b /nfl /xj /xjd /xjf $oldPath $newPath > robocopy_$folderName.log"
    Invoke-Expression $ROBOCOPY_COMMAND
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "$item" -Value $newPath


    Write-Host "$folderName moved from $oldPath to $newPath"
}
Restart-Explorer