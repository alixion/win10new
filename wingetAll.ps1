$wingetApps = @(
    "Microsoft.PowerShell"
#    "Microsoft.WindowsTerminal",
    "GNU.MidnightCommander"
    #   "Git.Git",
    "Notepad++.Notepad++",
    "7zip.7zip",
    "Microsoft.VisualStudioCode",
    "Insomnia.Insomnia",
    "WinSCP.WinSCP",
    "GitHub.GitHubDesktop",
    "Docker.DockerDesktop",
    "Google.Chrome",
    "Mozilla.Firefox",
 #   "Armin2208.WindowsAutoNightMode",
    "JetBrains.Toolbox",
#    "Logitech.Options",
    "Microsoft.PowerToys",
    "Toggl.TogglDesktop",
    "Typora.Typora",
    "VideoLAN.VLC",
    "AntibodySoftware.WizTree",
    "XnSoft.XnViewClassic",
    "Zoom.Zoom",
	"Doist.Todoist",
    "PeterPawlowski.foobar2000"
    "JanDeDobbeleer.OhMyPosh"
)

foreach ($app in $wingetApps) {
    $appName = $app.Split(".")[1]
    Write-Host ""
    Write-Host "Installing $appName..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green

    winget install --id $app -e -s winget
}