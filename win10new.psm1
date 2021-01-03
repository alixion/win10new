function Get-RemoteFile {

    # Usage: Download-File -url 'https://chocolateypackages.s3.amazonaws.com/borderlessgaming.8.2.nupkg' -path 'D:\SkyDrive\Scripts' -IgnoreSSLCertErrors
  
    param(
        [System.Uri]$url,
        [string]$path,
        [switch]$IgnoreSSLCertErrors
    )

    <#
    .SYNOPSIS
        Downloads a file from a remote URI.

    .DESCRIPTION
        Downloads a file via HTTP or HTTPs to the specified location on the computer. Supports HTTP, HTTPS, and
        HTTPS while ignoring certificate errors for 3rd party verification if you're using self-signed certs.

    .PARAMETER url
        The address of the file you wish to download.

    .PARAMETER path
        The path on the local computer you want to same the file to.

    .PARAMETER IgnoreSSLCertErrors
        Allows you to bypass cert errors when connecting to servers with self-signed certificates.

    .EXAMPLE
        Download-File 'http://www.file.com/file.zip' 'c:\users\JourneyOver\Downloads\'
        Download-File 'https://www.secure.com/file.zip' 'c:\users\JourneyOver\Downloads\'
        Download-File 'https://localhost/file.zip' 'c:\users\JourneyOver\Downloads\' -IgnoreSSLCertErrors

    .INPUTS

    .OUTPUTS

    .LINK

        https://github.com/JourneyOver/
    #>
  
    # Validate the URL, if it's not a proper URL, throw an Error
    if (-not (Valid-UrlFormat($url))) {
        Write-Error "$url is not a valid URL.";
        return;
    }
  
    $numSegments = ([System.Uri]$url).Segments.Length;
    $filename = ([System.Uri]$url).Segments[$numSegments - 1];
  
    # Validate the path, if it doesn't exist, create it.
    if (Test-Path $path) {
        if (-not ($path.EndsWith('\'))) {
            $path = $path + '\' + $filename;
        }
        else {
            $path = $path + $filename;
        }
    }
    else {
        Write-Warning "$path did not exist, so we created it for you."
        mkdir $path;
        if (-not ($path.EndsWith('\'))) {
            $path = $path + '\' + $filename;
        }
        else {
            $path = $path + $filename;
        }
    }
  
    # Try to download the data at the given URL
    $client = new-object System.Net.WebClient;
    if ($url.Scheme -eq 'https') {
        if ($IgnoreSSLCertErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true };
        }
        $client.Headers.Add("Accept-Language", "en-us,en;q=0.5");
        $client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.4) Gecko/20060508 Firefox/1.5.0.4");
    }
  
    $client.DownloadFile( $url, $path );

    function Test-ValidUrlFormat {
        param(
            [System.Uri]$url
        )
        return ($null -ne $url.AbsoluteURI -and $url.Scheme -match '[http|https]');
    }
}
function Restart-Explorer {
    <#
  .SYNOPSIS
  Restarts the Explorer.exe process in Windows.
  Author: @mwrock
  
  .DESCRIPTION
  Restarts Explorer.exe in Windows after making changes to it's configuration.
  
  .EXAMPLE
  Restart-Explorer
  
  .INPUTS None
  
  .OUTPUTS None
  
  .LINK
  
  https://github.com/mwrock
  #>
  
  
    try {
        Write-Output "Restarting the Windows Explorer process..."
        $user = Get-CurrentUser
        try { $explorer = Get-Process -Name explorer -ErrorAction stop -IncludeUserName }
        catch { $global:error.RemoveAt(0) }
  
        if ($null -ne $explorer) {
            $explorer | Where-Object { $_.UserName -eq "$($user.Domain)\$($user.Name)" } | Stop-Process -Force -ErrorAction Stop | Out-Null
        }
  
        Start-Sleep 1
  
        if (!(Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
            $global:error.RemoveAt(0)
            start-Process -FilePath explorer
        }
    }
    catch { $global:error.RemoveAt(0) }
}

function Install-KernelUpdate {
    param (
        [String] $FileName,
        [String] $Url
    )
    <#
    .SYNOPSIS
        Installs WSL 2 Kernel Update
    .DESCRIPTION
        Downloads to temp folder, installs the update and deletes the downloaded installer
    .EXAMPLE
        PS C:\> Install-KernelUpdate -FileName "wsl_update_x64.msi" -Url "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    .PARAMETER FileName
        Local FileName, without Path
    .PARAMETER Url
        Url of installer to download

    #>
    $tmp = "$env:TEMP\$FileName"

    If (!(Test-Path -Path $tmp )) {
        Write-Host "Downloading Kernel Update for WSL2"
        #Invoke-WebRequest -Uri $Url -OutFile $tmp
        Get-RemoteFile -url $Url -path $tmp
    }
    
    
    Write-Host "Installing Kernel Update for WSL2"
    Start-Process msiexec.exe -Wait -ArgumentList "/quiet /i $tmp"
    Write-Host "Done"
    Remove-Item $tmp   
}

function Move-UserShellFolder {
    <#
    .SYNOPSIS
    Change the location of the each user folder using SHSetKnownFolderPath function
    Изменить расположение каждой пользовательской папки, используя функцию "SHSetKnownFolderPath"
    https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
    .PARAMETER RemoveDesktopINI
    The RemoveDesktopINI argument removes desktop.ini in the old user shell folder
    Аргумент "RemoveDesktopINI" удаляет файл desktop.ini из старой пользовательской папки
    .EXAMPLE
    Move-UserShellFolder -UserFolder Desktop -FolderPath "$env:SystemDrive:\Desktop" -RemoveDesktopINI
    .NOTES
    User files or folders won't me moved to a new location
    Пользовательские файлы не будут перенесены в новое расположение
    .LINK
	https://github.com/farag2/Windows-10-Sophia-Script
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos")]
        [string]
        $UserFolder,

        [Parameter(Mandatory = $true)]
        [string]
        $FolderPath,

        [Parameter(Mandatory = $false)]
        [switch]
        $RemoveDesktopINI
    )

    function Set-KnownFolderPath {
        <#
        .SYNOPSIS
        Redirect user folders to a new location
        .EXAMPLE
        Set-KnownFolderPath -KnownFolder Desktop -Path "$env:SystemDrive:\Desktop"
    #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [ValidateSet("Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos")]
            [string]
            $KnownFolder,

            [Parameter(Mandatory = $true)]
            [string]
            $Path
        )

        $KnownFolders = @{
            "Desktop"   = @("B4BFCC3A-DB2C-424C-B029-7FE99A87C641");
            "Documents"	= @("FDD39AD0-238F-46AF-ADB4-6C85480369C7", "f42ee2d3-909f-4907-8871-4c22fc0bf756");
            "Downloads"	= @("374DE290-123F-4565-9164-39C4925E467B", "7d83ee9b-2244-4e70-b1f5-5393042af1e4");
            "Music"     = @("4BD8D571-6D19-48D3-BE97-422220080E43", "a0c69a99-21c8-4671-8703-7934162fcf1d");
            "Pictures"  = @("33E28130-4E1E-4676-835A-98395C3BC3BB", "0ddd015d-b06c-45d5-8c4c-f59713854639");
            "Videos"    = @("18989B1D-99B5-455B-841C-AB7C74E4DDFC", "35286a68-3c57-41a1-bbb1-0eae73d76c95");
        }

        $Signature = @{
            Namespace        = "WinAPI"
            Name             = "KnownFolders"
            Language         = "CSharp"
            MemberDefinition = @"
[DllImport("shell32.dll")]
public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
"@
        }
        if (-not ("WinAPI.KnownFolders" -as [type])) {
            Add-Type @Signature
        }

        foreach ($guid in $KnownFolders[$KnownFolder]) {
            [WinAPI.KnownFolders]::SHSetKnownFolderPath([ref]$guid, 0, 0, $Path)
        }
        (Get-Item -Path $Path -Force).Attributes = "ReadOnly"
    }

    $UserShellFoldersRegName = @{
        "Desktop"   =	"Desktop"
        "Documents"	=	"Personal"
        "Downloads"	=	"{374DE290-123F-4565-9164-39C4925E467B}"
        "Music"     =	"My Music"
        "Pictures"  =	"My Pictures"
        "Videos"    =	"My Video"
    }

    $UserShellFoldersGUID = @{
        "Desktop"   =	"{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}"
        "Documents"	=	"{F42EE2D3-909F-4907-8871-4C22FC0BF756}"
        "Downloads"	=	"{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}"
        "Music"     =	"{A0C69A99-21C8-4671-8703-7934162FCF1D}"
        "Pictures"  =	"{0DDD015D-B06C-45D5-8C4C-F59713854639}"
        "Videos"    =	"{35286A68-3C57-41A1-BBB1-0EAE73D76C95}"
    }

    # Contents of the hidden desktop.ini file for each type of user folders
    # Содержимое скрытого файла desktop.ini для каждого типа пользовательских папок
    $DesktopINI = @{
        "Desktop"   =	"",
        "[.ShellClassInfo]",
        "LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21769",
        "IconResource=%SystemRoot%\system32\imageres.dll,-183"
        "Documents"	=	"",
        "[.ShellClassInfo]",
        "LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21770",
        "IconResource=%SystemRoot%\system32\imageres.dll,-112",
        "IconFile=%SystemRoot%\system32\shell32.dll",
        "IconIndex=-235"
        "Downloads"	=	"",
        "[.ShellClassInfo]", "LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21798",
        "IconResource=%SystemRoot%\system32\imageres.dll,-184"
        "Music"     =	"",
        "[.ShellClassInfo]", "LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21790",
        "InfoTip=@%SystemRoot%\system32\shell32.dll,-12689",
        "IconResource=%SystemRoot%\system32\imageres.dll,-108",
        "IconFile=%SystemRoot%\system32\shell32.dll", "IconIndex=-237"
        "Pictures"  =	"",
        "[.ShellClassInfo]",
        "LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21779",
        "InfoTip=@%SystemRoot%\system32\shell32.dll,-12688",
        "IconResource=%SystemRoot%\system32\imageres.dll,-113",
        "IconFile=%SystemRoot%\system32\shell32.dll",
        "IconIndex=-236"
        "Videos"    =	"",
        "[.ShellClassInfo]",
        "LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21791",
        "InfoTip=@%SystemRoot%\system32\shell32.dll,-12690",
        "IconResource=%SystemRoot%\system32\imageres.dll,-189",
        "IconFile=%SystemRoot%\system32\shell32.dll", "IconIndex=-238"
    }

    # Determining the current user folder path
    # Определяем текущее значение пути пользовательской папки
    $UserShellFolderRegValue = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $UserShellFoldersRegName[$UserFolder]
    if ($UserShellFolderRegValue -ne $FolderPath) {
        
        # Creating a new folder if there is no one
        # Создаем новую папку, если таковая отсутствует
        if (-not (Test-Path -Path $FolderPath)) {
            New-Item -Path $FolderPath -ItemType Directory -Force
        }

        $ROBOCOPY_COMMAND = "robocopy /e /MOVE /copyall /r:0 /mt:4 /b /nfl /xj /xjd /xjf $UserShellFolderRegValue $FolderPath"
        Invoke-Expression $ROBOCOPY_COMMAND

        # Removing old desktop.ini
        # Удаляем старый desktop.ini
        if ($RemoveDesktopINI.IsPresent -and (Test-Path "$UserShellFolderRegValue\desktop.ini")) {
            Remove-Item -Path "$UserShellFolderRegValue\desktop.ini" -Force
        }

        Set-KnownFolderPath -KnownFolder $UserFolder -Path $FolderPath
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $UserShellFoldersGUID[$UserFolder] -PropertyType ExpandString -Value $FolderPath -Force

        Set-Content -Path "$FolderPath\desktop.ini" -Value $DesktopINI[$UserFolder] -Encoding Unicode -Force
        (Get-Item -Path "$FolderPath\desktop.ini" -Force).Attributes = "Hidden", "System", "Archive"
        (Get-Item -Path "$FolderPath\desktop.ini" -Force).Refresh()

        Write-Host "$FolderPath moved from $UserShellFolderRegValue to $FolderPath"
    }
}

function Add-Path {
    #Requires -Version 4
    #Requires -RunAsAdministrator
    
    <# 
     .SYNOPSIS
      Function to append string(s) to PATH environment variable
    
     .DESCRIPTION
      Function to append string(s) to PATH environment variable.
      The function will filter out duplicates in the input string, and existing PATH duplicates
      The function will not add a string if that path does not exist
      This affects the Machine PATH which is permanent, not just session PATH
    
     .PARAMETER String
      The string/path to be added to the PATH environment variable
    
     .EXAMPLE
      Add-Path -String 'D:\Sandbox','bla' -Verbose
    
     .LINK
      https://superwidgets.wordpress.com/category/powershell/
    
     .NOTES
      Function by Sam Boutros - v1.0 - 6 January, 2017
    #>
    
    [CmdletBinding(ConfirmImpact = 'Low')] 
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeLine = $true,
            ValueFromPipeLineByPropertyName = $true,
            Position = 0)]
        [String[]]$String
    )
    
    Begin {
        # Identify current Path components
        $Paths = $env:Path.Split(';').ToLower() | Select-Object -Unique | Sort-Object
        Write-Verbose "Identified the following $($Paths.Count) path components on the computer $($env:COMPUTERNAME)"
        Write-Verbose ($Paths | Out-String)
    
        # Identify input, remove duplicates and bad paths
        $InputList = $String.ToLower() | Select-Object -Unique 
        $CleanedInputList = @()
        $InputList | ForEach-Object { if (Test-Path $_) { $CleanedInputList += $_ } }
        Write-Verbose "Processing the following new paths (removed duplicates and bad paths):"
        Write-Verbose ($CleanedInputList | Out-String)
    }
    
    Process {
        $OutputList = $Paths + $CleanedInputList | Select-Object -Unique
        Write-Verbose "Committing the following $($OutputList.Count) path components:"
        Write-Verbose ($OutputList | Out-String)
    
        [Environment]::SetEnvironmentVariable( "Path", $($OutputList -join ';'), [System.EnvironmentVariableTarget]::Machine )
        # This changes the registry key HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment which requires elevation
    }
    
    End {}
}

function Set-PowerScheme {
    PowerCfg /SetActive "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    PowerCfg /Change monitor-timeout-ac 0
    PowerCfg /Change disk-timeout-ac 0
    PowerCfg /Change standby-timeout-ac 0
}

function Set-WindowsExplorerOptions {
    <#
  .SYNOPSIS
  Sets options on the Windows Explorer shell
  
  .PARAMETER EnableShowHiddenFilesFoldersDrives
  If this flag is set, hidden files will be shown in Windows Explorer
  
  .PARAMETER DisableShowHiddenFilesFoldersDrives
  Disables the showing on hidden files in Windows Explorer, see EnableShowHiddenFilesFoldersDrives
  
  .PARAMETER EnableShowProtectedOSFiles
  If this flag is set, hidden Operating System files will be shown in Windows Explorer
  
  .PARAMETER DisableShowProtectedOSFiles
  Disables the showing of hidden Operating System Files in Windows Explorer, see EnableShowProtectedOSFiles
  
  .PARAMETER EnableShowFileExtensions
  Setting this switch will cause Windows Explorer to include the file extension in file names
  
  .PARAMETER DisableShowFileExtensions
  Disables the showing of file extension in file names, see EnableShowFileExtensions
  
  .PARAMETER EnableShowFullPathInTitleBar
  Setting this switch will cause Windows Explorer to show the full folder path in the Title Bar
  
  .PARAMETER DisableShowFullPathInTitleBar
  Disables the showing of the full path in Windows Explorer Title Bar, see EnableShowFullPathInTitleBar
  
  .PARAMETER EnableExpandToOpenFolder
  Setting this switch will cause Windows Explorer to expand the navigation pane to the current open folder
  
  .PARAMETER DisableExpandToOpenFolder
  Disables the expanding of the navigation page to the current open folder in Windows Explorer, see EnableExpandToOpenFolder
  
  .PARAMETER EnableOpenFileExplorerToQuickAccess
  Setting this switch will cause Windows Explorer to open itself to the Computer view, rather than the Quick Access view
  
  .PARAMETER DisableOpenFileExplorerToQuickAccess
  Disables the Quick Access location and shows Computer view when opening Windows Explorer, see EnableOpenFileExplorerToQuickAccess
  
  .PARAMETER EnableShowRecentFilesInQuickAccess
  Setting this switch will cause Windows Explorer to show recently used files in the Quick Access pane
  
  .PARAMETER DisableShowRecentFilesInQuickAccess
  Disables the showing of recently used files in the Quick Access pane, see EnableShowRecentFilesInQuickAccess
  
  .PARAMETER EnableShowFrequentFoldersInQuickAccess
  Setting this switch will cause Windows Explorer to show frequently used directories in the Quick Access pane
  
  .PARAMETER DisableShowFrequentFoldersInQuickAccess
  Disables the showing of frequently used directories in the Quick Access pane, see EnableShowFrequentFoldersInQuickAccess
  
  .PARAMETER EnableShowRibbon
  Setting this switch will cause Windows Explorer to show the Ribbon menu so that it is always expanded
  
  .PARAMETER DisableShowRibbon
  Disables the showing of the Ribbon menu in Windows Explorer so that it shows only the tab names, see EnableShowRibbon
  
  .LINK
  
  http://boxstarter.org
  #>
  
    [CmdletBinding()]
    param(
        [switch]$EnableShowHiddenFilesFoldersDrives,
        [switch]$DisableShowHiddenFilesFoldersDrives,
        [switch]$EnableShowProtectedOSFiles,
        [switch]$DisableShowProtectedOSFiles,
        [switch]$EnableShowFileExtensions,
        [switch]$DisableShowFileExtensions,
        [switch]$EnableShowFullPathInTitleBar,
        [switch]$DisableShowFullPathInTitleBar,
        [switch]$EnableExpandToOpenFolder,
        [switch]$DisableExpandToOpenFolder,
        [switch]$EnableOpenFileExplorerToQuickAccess,
        [switch]$DisableOpenFileExplorerToQuickAccess,
        [switch]$EnableShowRecentFilesInQuickAccess,
        [switch]$DisableShowRecentFilesInQuickAccess,
        [switch]$EnableShowFrequentFoldersInQuickAccess,
        [switch]$DisableShowFrequentFoldersInQuickAccess,
        [switch]$EnableShowRibbon,
        [switch]$DisableShowRibbon
    )
  
    $PSBoundParameters.Keys | ForEach-Object {
        if ($_ -like "En*") { $other = "Dis" + $_.Substring(2) }
        if ($_ -like "Dis*") { $other = "En" + $_.Substring(3) }
        if ($PSBoundParameters[$_] -and $PSBoundParameters[$other]) {
            throw new-Object -TypeName ArgumentException "You may not set both $_ and $other. You can only set one."
        }
    }
  
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
    $advancedKey = "$key\Advanced"
    $cabinetStateKey = "$key\CabinetState"
    $ribbonKey = "$key\Ribbon"
  
    Write-Output "Setting Windows Explorer options..."
  
    if (Test-Path -Path $key) {
        if ($EnableShowRecentFilesInQuickAccess) { Set-ItemProperty $key ShowRecent 1 }
        if ($DisableShowRecentFilesInQuickAccess) { Set-ItemProperty $key ShowRecent 0 }
  
        if ($EnableShowFrequentFoldersInQuickAccess) { Set-ItemProperty $key ShowFrequent 1 }
        if ($DisableShowFrequentFoldersInQuickAccess) { Set-ItemProperty $key ShowFrequent 0 }
    }
  
    if (Test-Path -Path $advancedKey) {
        if ($EnableShowHiddenFilesFoldersDrives) { Set-ItemProperty $advancedKey Hidden 1 }
        if ($DisableShowHiddenFilesFoldersDrives) { Set-ItemProperty $advancedKey Hidden 0 }
  
        if ($EnableShowFileExtensions) { Set-ItemProperty $advancedKey HideFileExt 0 }
        if ($DisableShowFileExtensions) { Set-ItemProperty $advancedKey HideFileExt 1 }
  
        if ($EnableShowProtectedOSFiles) { Set-ItemProperty $advancedKey ShowSuperHidden 1 }
        if ($DisableShowProtectedOSFiles) { Set-ItemProperty $advancedKey ShowSuperHidden 0 }
  
        if ($EnableExpandToOpenFolder) { Set-ItemProperty $advancedKey NavPaneExpandToCurrentFolder 1 }
        if ($DisableExpandToOpenFolder) { Set-ItemProperty $advancedKey NavPaneExpandToCurrentFolder 0 }
  
        if ($EnableOpenFileExplorerToQuickAccess) { Set-ItemProperty $advancedKey LaunchTo 2 }
        if ($DisableOpenFileExplorerToQuickAccess) { Set-ItemProperty $advancedKey LaunchTo 1 }
    }
  
    if (Test-Path -Path $cabinetStateKey) {
        if ($EnableShowFullPathInTitleBar) { Set-ItemProperty $cabinetStateKey FullPath  1 }
        if ($DisableShowFullPathInTitleBar) { Set-ItemProperty $cabinetStateKey FullPath  0 }
    }
  
    if (Test-Path -Path $ribbonKey) {
        if ($EnableShowRibbon) { Set-ItemProperty $ribbonKey MinimizedStateTabletModeOff 0 }
        if ($DisableShowRibbon) { Set-ItemProperty $ribbonKey MinimizedStateTabletModeOff 1 }
    }
  
    Restart-Explorer
}

function Set-TaskbarOptions {
    <#
  .SYNOPSIS
  Sets options for the Windows Task Bar
  
  .PARAMETER Lock
  Locks the taskbar
  
  .PARAMETER UnLock
  Unlocks the taskbar
  
  .PARAMETER Size
  Changes the size of the Taskbar Icons.  Valid inputs are Small and Large.
  
  .PARAMETER Dock
  Changes the location in which the Taskbar is docked.  Valid inputs are Top, Left, Bottom and Right.
  
  .PARAMETER Combine
  Changes the Taskbar Icon combination style. Valid inputs are Always, Full, and Never.
  
  .PARAMETER AlwaysShowIconsOn
  Turn on always show all icons in the notification area
  
  .PARAMETER AlwaysShowIconsOff
  Turn off always show all icons in the notification area
  
  .EXAMPLE
  Set-TaskbarOptions -Size Small
  
  .LINK
  
  http://boxstarter.org
  #>
  
    [CmdletBinding(DefaultParameterSetName = 'unlock')]
    param(
        [Parameter(ParameterSetName = 'lock')]
        [switch]$Lock,
        [Parameter(ParameterSetName = 'unlock')]
        [switch]$UnLock,
        [Parameter(ParameterSetName = 'AlwaysShowIconsOn')]
        [switch]$AlwaysShowIconsOn,
        [Parameter(ParameterSetName = 'AlwaysShowIconsOff')]
        [switch]$AlwaysShowIconsOff,
        [ValidateSet('Small', 'Large')]
        $Size,
        [ValidateSet('Top', 'Left', 'Bottom', 'Right')]
        $Dock,
        [ValidateSet('Always', 'Full', 'Never')]
        $Combine
    )
  
    $explorerKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $dockingKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2'
  
    if (-not (Test-Path -Path $dockingKey)) {
        $dockingKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    }
  
    if (Test-Path -Path $key) {
        if ($Lock) {
            Set-ItemProperty $key TaskbarSizeMove 0
        }
        if ($UnLock) {
            Set-ItemProperty $key TaskbarSizeMove 1
        }
  
        switch ($Size) {
            "Small" { Set-ItemProperty $key TaskbarSmallIcons 1 }
            "Large" { Set-ItemProperty $key TaskbarSmallIcons 0 }
        }
  
        switch ($Combine) {
            "Always" { Set-ItemProperty $key TaskbarGlomLevel 0 }
            "Full" { Set-ItemProperty $key TaskbarGlomLevel 1 }
            "Never" { Set-ItemProperty $key TaskbarGlomLevel 2 }
        }
  
        Restart-Explorer
    }
  
    if (Test-Path -Path $dockingKey) {
        switch ($Dock) {
            "Top" { Set-ItemProperty -Path $dockingKey -Name Settings -Value ([byte[]] (0x28, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x07, 0x00, 0x00, 0x2e, 0x00, 0x00, 0x00)) }
            "Left" { Set-ItemProperty -Path $dockingKey -Name Settings -Value ([byte[]] (0x28, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0xb0, 0x04, 0x00, 0x00)) }
            "Bottom" { Set-ItemProperty -Path $dockingKey -Name Settings -Value ([byte[]] (0x28, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x02, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x04, 0x00, 0x00, 0x80, 0x07, 0x00, 0x00, 0xb0, 0x04, 0x00, 0x00)) }
            "Right" { Set-ItemProperty -Path $dockingKey -Name Settings -Value ([byte[]] (0x28, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x02, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x42, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x07, 0x00, 0x00, 0xb0, 0x04, 0x00, 0x00)) }
        }
  
        Restart-Explorer
    }
  
    if (Test-Path -Path $explorerKey) {
        if ($AlwaysShowIconsOn) { Set-ItemProperty -Path $explorerKey -Name 'EnableAutoTray' -Value 0 }
        if ($alwaysShowIconsOff) { Set-ItemProperty -Path $explorerKey -Name 'EnableAutoTray' -Value 1 }
    }
}

function Set-QuickAccess {
    <#
.SYNOPSIS
Pin or Unpin folders to/from Quick Access in File Explorer.

.DESCRIPTION
Pin or Unpin folders to/from Quick Access in File Explorer.

.PARAMETER None

.EXAMPLE
.\Set-QuickAccess.ps1 -Action Pin -Path "\\server\share\redirected_folders\$env:USERNAME\Links"
Pin the specified UNC server share to Quick Access in File Explorer.

.EXAMPLE
.\Set-QuickAccess.ps1 -Action Unpin -Path "\\server\share\redirected_folders\$env:USERNAME\Links"
Unpin the specified UNC server share from Quick Access in File Explorer.

.INPUTS

.OUTPUTS

.LINK

https://github.com/JourneyOver/
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Pin or Unpin folder to/from Quick Access in File Explorer.")]
        [ValidateSet("Pin", "Unpin")]
        [string]$Action,
        [Parameter(Mandatory = $true, Position = 2, HelpMessage = "Path to the folder to Pin or Unpin to/from Quick Access in File Explorer.")]
        [string]$Path
    )

    Write-Host "$Action to/from Quick Access: $Path.. " -NoNewline

    # Check if specified path is valid
    If ((Test-Path -Path $Path) -ne $true) {
        Write-Warning "Path does not exist."
        return
    }
    # Check if specified path is a folder
    If ((Test-Path -Path $Path -PathType Container) -ne $true) {
        Write-Warning "Path is not a folder."
        return
    }

    # Pin or Unpin
    $QuickAccess = New-Object -ComObject shell.application
    $TargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | Where-Object { $_.Path -eq "$Path" }
    If ($Action -eq "Pin") {
        If ($null -ne $TargetObject) {
            Write-Warning "Path is already pinned to Quick Access."
            return
        }
        Else {
            $QuickAccess.Namespace("$Path").Self.InvokeVerb("pintohome")
        }
    }
    ElseIf ($Action -eq "Unpin") {
        If ($null -eq $TargetObject) {
            Write-Warning "Path is not pinned to Quick Access."
            return
        }
        Else {
            $TargetObject.InvokeVerb("unpinfromhome")
        }
    }

    Write-Host "Done"
}

Function Set-OpenWithVisualStudioCode {
    <#
.SYNOPSIS
    Will set Open with for Visual Studio Code

.DESCRIPTION
    Will set Open with for Visual Studio Code.

.PARAMETER Scope
    For User or System installation
    
.PARAMETER File
    Will set Open with for files

.PARAMETER Directory
    Will set Open with for directory

.EXAMPLE
    Set-OpenWithVisualStudioCode -Scope User -File -Directory

.EXAMPLE
    Set-OpenWithVisualStudioCode -Scope System -File -Directory

.NOTES
    NAME:       Set-OpenWithVisualStudioCode
    AUTHOR:     Fredrik Wall, fredrik@poweradmin.se
    TWITTER:    @walle75
    BLOG:       https://www.fredrikwall.se/
    CREATED:    2020-01-01
    VERSION:    1.0

.LINK
    https://github.com/FredrikWall
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('User', 'System')]
        $Scope,
        [Parameter(Mandatory = $false)]
        [Switch]$File,
        [Parameter(Mandatory = $false)]
        [Switch]$Directory
    )
    
    
    New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR | Out-Null
    

    if ($Scope -eq "User") {
        $PathToVSCode = "$env:LOCALAPPDATA\Programs\Microsoft VS Code"
        if (!(Test-Path "$PathToVSCode\Code.exe")) {
            Write-Output "No User installation found"
            Break
        }
    }

    if ($Scope -eq "System") {
        $PathToVSCode = "$env:ProgramFiles\Microsoft VS Code"
        if (!(Test-Path "$PathToVSCode\Code.exe")) {
            Write-Output "No System installation found"
            Break
        }
    }

    if ($File) {
        If (!(Test-Path -LiteralPath "HKCR:\*\shell\VSCode")) {
            # Right click on a file
            try {
                Set-Location -LiteralPath "HKCR:\*"
                New-Item -Path ".\shell" -Name "VSCode" -Force | Out-Null
                New-Item -Path ".\shell\VSCode" -Name "command" -Force | Out-Null
                Set-ItemProperty -Path ".\shell\VSCode" -Name '(Default)' -Value "Open with Code" -Type ExpandString
                New-ItemProperty -Path ".\shell\VSCode" -Name 'Icon' -PropertyType ExpandString -Value "$PathToVSCode\Code.exe" | Out-Null
                Set-ItemProperty -Path ".\shell\VSCode\command" -Name '(Default)' -Value "`"$PathToVSCode\Code.exe`" `"%1`"" -Type ExpandString
                Write-Output "Open with Code set for files"
            }
            catch {
                Write-Output "Error: Open with Code not set for files"
                Write-Output "$_"
            }
                    
        }
        else {
            Write-Output "Open with Code already set for files"
        }
    }

    if ($Directory) {
        If (!(Test-Path -LiteralPath "HKCR:\Directory\shell\VSCode")) {
            # Right click on a folder
            try {
                Set-Location -LiteralPath "HKCR:\Directory"
                New-Item -Path ".\shell" -Name "VSCode" -Force | Out-Null
                New-Item -Path ".\shell\VSCode" -Name "command" -Force | Out-Null
                Set-ItemProperty -Path ".\shell\VSCode" -Name '(Default)' -Value "Open with Code" -Type ExpandString
                New-ItemProperty -Path ".\shell\VSCode" -Name 'Icon' -PropertyType ExpandString -Value "$PathToVSCode\Code.exe" | Out-Null
                Set-ItemProperty -Path ".\shell\VSCode\command" -Name '(Default)' -Value "`"$PathToVSCode\Code.exe`" `"%V`"" -Type ExpandString

                # Right click inside a folder
                Set-Location -LiteralPath "HKCR:\Directory\Background"
                New-Item -Path ".\shell" -Name "VSCode" -Force | Out-Null
                New-Item -Path ".\shell\VSCode" -Name "command" -Force | Out-Null
                Set-ItemProperty -Path ".\shell\VSCode" -Name '(Default)' -Value "Open with Code" -Type ExpandString
                New-ItemProperty -Path ".\shell\VSCode" -Name 'Icon' -PropertyType ExpandString -Value "$PathToVSCode\Code.exe" | Out-Null
                Set-ItemProperty -Path ".\shell\VSCode\command" -Name '(Default)' -Value "`"$PathToVSCode\Code.exe`" `"%V`"" -Type ExpandString

                Write-Output "Open with Code set for directory"
            }
            catch {
                Write-Output "Error: Open with Code not set for files"
                Write-Output "$_"
            }
        }
        else {
            Write-Output "Open with Code already set for directory"
        }
    }
}
