Function Install-OSPlatformServer {
    <#
    .SYNOPSIS
    Installs or updates the Outsystems Platform server.

    .DESCRIPTION
    This will installs or updates the platform server.
    If the platform is already installed it will check if version to be installed is higher than the current one.
    If the platform is already installed with an higher version it will throw an exception.


    .PARAMETER InstallDir
    Where the platform will be installed. If the platform is already installed, this parameter has no effect.
    If not specified will default to %ProgramFiles%\Outsystems

    .PARAMETER SourcePath
    If specified, the function will use the sources in that path. If not specified it will download the sources from the Outsystems repository.

    .PARAMETER Version
    The version to be installed.

    .EXAMPLE
    Install-OSPlatformServer -Version "10.0.823.0"
    Install-OSPlatformServer -Version "10.0.823.0" -InstallDir D:\Outsystems
    Install-OSPlatformServer -Version "10.0.823.0" -InstallDir D:\Outsystems -SourcePath c:\temp

    #>

    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName = 'Local')]
        [Parameter(ParameterSetName = 'Remote')]
        [string]$InstallDir = $OSDefaultInstallDir,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Remote', Mandatory = $true)]
        [string]$Version
    )

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        Try{
            CheckRunAsAdmin | Out-Null
        }
        Catch{
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }

        Try{
            $OSVersion = GetServerVersion
            $OSInstallDir = GetServerInstallDir
        } Catch {}

        If( -not $OSVersion ){
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems platform server is not installed"
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Proceeding with normal installation"
            $InstallDir = "$InstallDir\Platform Server"
            $DoInstall = $true
        } ElseIf ( [version]$OSVersion -lt [version]$Version) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems platform server already installed. Updating!!"
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Current version $OSVersion will be updated to $Version"
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Ignoring InstallDir since this is an update"
            $InstallDir = $OSInstallDir
            $DoInstall = $true
        } ElseIf ( [version]$OSVersion -gt [version]$Version) {
            $DoInstall = $false
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform server already installed with an higher version $OSVersion"
            Throw "Outsystems platform server already installed with an higher version $OSVersion"
        } Else {
            $DoInstall = $false
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems platform server already installed with the specified version $OSVersion"
        }
    }

    Process {
        If ( $DoInstall ) {

            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing version $Version"
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing in $InstallDir"

            #Check if installer is local or is to be downloaded.
            switch ($PsCmdlet.ParameterSetName) {
                "Remote" {
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "SourcePath not specified. Downloading installer from repository"

                    $Installer = "$ENV:TEMP\PlatformServer-$Version.exe"
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Saving installer to $Installer"

                    Try {
                        DownloadOSSources -URL "$OSRepoURL\PlatformServer-$Version.exe" -SavePath $Installer
                    }
                    Catch {
                        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error downloading the installer from repository. Check if version is correct"
                        Throw "Error downloading the installer from repository. Check if version is correct"
                    }

                }
                "Local" {
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "SourcePath specified. Using the local installer"
                    $Installer = "$SourcePath\PlatformServer-$Version.exe"
                    If ( -not (Test-Path -Path $Installer)) {
                        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Cant file the setup file at $Installer"
                        Throw "Cant file the setup file at $Installer"
                    }
                }
            }

            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Starting the installation. This can take a while..."
            $IntReturnCode = Start-Process -FilePath $Installer -ArgumentList "/S", "/D=$InstallDir" -Wait -PassThru
            If ( $IntReturnCode.ExitCode -ne 0 ) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error installing Outsystems Platform Server. Exit code: $($IntReturnCode.ExitCode)"
                throw "Error installing Outsystems Platform Server. Exit code: $($IntReturnCode.ExitCode)"
            }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems platform server successfully installed."
        }
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}