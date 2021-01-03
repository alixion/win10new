Install-Module posh-git -Scope CurrentUser -Force
Install-Module oh-my-posh -Scope CurrentUser -Force

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}
Copy-Item -Path $PWD\extra\Microsoft.PowerShell_profile.ps1 -Destination $PROFILE 