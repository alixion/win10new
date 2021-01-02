. .\Restart-Explorer.ps1
. .\Move-UserShellFolders.ps1

Write-Host ""
Write-Host "Moving Library folders to D:" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Move-LibraryDirectory 'My Video' 'D:\Alex\Videos'
Move-LibraryDirectory 'My Pictures' 'D:\Alex\Pictures'
Move-LibraryDirectory 'Desktop' 'D:\Alex\Desktop'
Move-LibraryDirectory 'My Music' 'D:\Alex\Music'
Move-LibraryDirectory 'Downloads' 'D:\Alex\Downloads'
Move-LibraryDirectory 'Personal' 'D:\Alex\Documents'
#Move-LibraryDirectory 'OneDrive' 'D:\Alex\OneDrive'