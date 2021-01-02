<#
	.SYNOPSIS
	Change the location of the user folders to any disks root of your choice using the interactive menu
	.PARAMETER Root
	Change the location of the user folders to any disks root of your choice using the interactive menu
	.PARAMETER Custom
	Select a folder for the location of the user folders manually using a folder browser dialog
	.PARAMETER Default
	Change the location of the user folders to the default values
	.EXAMPLE
	SetUserShellFolderLocation -Root
	.EXAMPLE
	SetUserShellFolderLocation -Custom
	.EXAMPLE
	SetUserShellFolderLocation -Default
	.NOTES
	User files or folders won't me moved to a new location
	Current user only
#>
function SetUserShellFolderLocation {
    Param(
        [string] $toFolder = "D:\Users\" + ($env:APPDATA).Split("\")[-3]
    )

    function UserShellFolder {
        <#
		.SYNOPSIS
		Change the location of the each user folder using SHSetKnownFolderPath function
		Изменить расположение каждой пользовательской папки, используя функцию "SHSetKnownFolderPath"
		https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
		.PARAMETER RemoveDesktopINI
		The RemoveDesktopINI argument removes desktop.ini in the old user shell folder
		Аргумент "RemoveDesktopINI" удаляет файл desktop.ini из старой пользовательской папки
		.EXAMPLE
		UserShellFolder -UserFolder Desktop -FolderPath "$env:SystemDrive:\Desktop" -RemoveDesktopINI
		.NOTES
		User files or folders won't me moved to a new location
		Пользовательские файлы не будут перенесены в новое расположение
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

        function KnownFolderPath {
            <#
			.SYNOPSIS
			Redirect user folders to a new location
			.EXAMPLE
			KnownFolderPath -KnownFolder Desktop -Path "$env:SystemDrive:\Desktop"
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
            if ($RemoveDesktopINI.IsPresent) {
                Remove-Item -Path "$UserShellFolderRegValue\desktop.ini" -Force
            }

            KnownFolderPath -KnownFolder $UserFolder -Path $FolderPath
            New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $UserShellFoldersGUID[$UserFolder] -PropertyType ExpandString -Value $FolderPath -Force

            Set-Content -Path "$FolderPath\desktop.ini" -Value $DesktopINI[$UserFolder] -Encoding Unicode -Force
            (Get-Item -Path "$FolderPath\desktop.ini" -Force).Attributes = "Hidden", "System", "Archive"
            (Get-Item -Path "$FolderPath\desktop.ini" -Force).Refresh()
        }
    }

    UserShellFolder -UserFolder Desktop -FolderPath "$toFolder\Desktop" -RemoveDesktopINI
    UserShellFolder -UserFolder Documents -FolderPath "$toFolder\Documents" -RemoveDesktopINI
    UserShellFolder -UserFolder Downloads -FolderPath "$toFolder\Downloads" -RemoveDesktopINI
    UserShellFolder -UserFolder Music -FolderPath "$toFolder\Music" -RemoveDesktopINI
    UserShellFolder -UserFolder Pictures -FolderPath "$toFolder\Pictures" -RemoveDesktopINI
    UserShellFolder -UserFolder Videos -FolderPath "$toFolder\Videos" -RemoveDesktopINI
}