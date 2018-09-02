function Install-OSServer
{
    <#
    .SYNOPSIS
    Installs or updates the Outsystems Platform server.

    .DESCRIPTION
    This will installs or updates the platform server.
    If the platform is already installed, the function will check if version to be installed is higher than the current one and update it.

    .PARAMETER InstallDir
    Where the platform will be installed. if the platform is already installed, this parameter has no effect.
    if not specified will default to %ProgramFiles%\Outsystems

    .PARAMETER SourcePath
    If specified, the function will use the sources in that path.
    If not specified it will download the sources from the Outsystems repository (default behavior).

    .PARAMETER Version
    The version to be installed.

    .EXAMPLE
    Install-OSServer -Version "10.0.823.0"
    Install-OSServer -Version "10.0.823.0" -InstallDir D:\Outsystems
    Install-OSServer -Version "10.0.823.0" -InstallDir D:\Outsystems -SourcePath c:\temp

    .NOTES
    All error are non-terminating. The function caller should decide what to do using the -ErrorAction parameter or using the $ErrorPreference variable.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Remote')]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(ParameterSetName = 'Local')]
        [Parameter(ParameterSetName = 'Remote')]
        [string]$InstallDir = $OSDefaultInstallDir,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Remote', Mandatory = $true)]
        [string]$Version
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.InstallResult'
            Success      = $true
            RebootNeeded = $false
            ExitCode     = 0
            Message      = 'Outsystems platform server successfully installed'
        }

        $osVersion = GetServerVersion
        $osInstallDir = GetServerInstallDir
    }

    process
    {
         ### Check phase ###
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        if (-not $osVersion)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems platform server is not installed"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Proceeding with normal installation"
            $InstallDir = "$InstallDir\Platform Server"
            $doInstall = $true
        }
        elseif ([version]$osVersion -lt [version]$Version)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems platform server already installed. Updating!!"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Current version $osVersion will be updated to $Version"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Ignoring InstallDir since this is an update"
            $InstallDir = $osInstallDir
            $doInstall = $true
        }
        elseif ([version]$osVersion -gt [version]$Version)
        {
            $doInstall = $false
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform server already installed with an higher version $osVersion"
            WriteNonTerminalError -Message "Outsystems platform server already installed with an higher version $osVersion"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = "Outsystems platform server already installed with an higher version $osVersion"

            return $installResult
        }
        else
        {
            $doInstall = $false
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems platform server already installed with the specified version $osVersion"
        }

        ### Install phase ###
        if ($doInstall)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing version $Version"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing in $InstallDir"

            #Check if installer is local or is to be downloaded.
            switch ($PsCmdlet.ParameterSetName)
            {
                "Remote"
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SourcePath not specified. Downloading installer from repository"

                    $installer = "$ENV:TEMP\PlatformServer-$Version.exe"
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Saving installer to $installer"

                    try
                    {
                        DownloadOSSources -URL "$OSRepoURL\PlatformServer-$Version.exe" -SavePath $installer
                    }
                    catch
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading the installer from repository. Check if version is correct"
                        WriteNonTerminalError -Message "Error downloading the installer from repository. Check if version is correct"

                        $installResult.Success = $false
                        $installResult.ExitCode = -1
                        $installResult.Message = 'Error downloading the installer from repository. Check if version is correct'

                        return $installResult
                    }

                }
                "Local"
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SourcePath specified. Using the local installer"
                    $installer = "$SourcePath\PlatformServer-$Version.exe"
                }
            }

            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the installation. This can take a while..."
                $result = Start-Process -FilePath $installer -ArgumentList "/S", "/D=$InstallDir" -Wait -PassThru -ErrorAction Stop
                $exitCode = $result.ExitCode
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the plaform server installation"
                WriteNonTerminalError -Message "Error starting the plaform server installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error starting the plaform server installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems platform server successfully installed"
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems platform server successfully installed but a reboot is needed!!!!! Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    # Error. Let the caller decide what to do
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing the Outsystems platform server. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing the Outsystems platform server. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = "Error installing the Outsystems platform server. Exit code: $exitCode"

                    return $installResult
                }
            }
        }

        if ($installResult.RebootNeeded)
        {
            $installResult.ExitCode = 3010
            $installResult.Message = 'Outsystems platform server successfully installed but a reboot is needed'
        }
        return $installResult
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
