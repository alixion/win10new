. .\Restart-Explorer.ps1
. .\Set-KnownFolderPath.ps1

Write-Host ""
Write-Host "Moving Library folders to D:" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-KnownFolderPath 'Videos' 'D:\Alex\Videos'
Set-KnownFolderPath 'Pictures' 'D:\Alex\Pictures'
Set-KnownFolderPath 'Desktop' 'D:\Alex\Desktop'
Set-KnownFolderPath 'Music' 'D:\Alex\Music'
Set-KnownFolderPath 'Downloads' 'D:\Alex\Downloads'
Set-KnownFolderPath 'Documents' 'D:\Alex\Documents'
#Set-KnownFolderPath 'OneDrive' 'D:\Alex\OneDrive'


Restart-Explorer