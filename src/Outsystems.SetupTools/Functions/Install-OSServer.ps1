function Install-OSServer
{
    <#
    .SYNOPSIS
    Installs or updates the OutSystems Platform server

    .DESCRIPTION
    This will install or update the OutSystems platform server
    It will also install RabbitMQ on version 11 and later
    If the platform is already installed, the cmdLet will check if version to be installed is higher than the current one and update it

    .PARAMETER InstallDir
    Where the platform will be installed. if the platform is already installed, this parameter has no effect
    If not specified, it will default to %ProgramFiles%\Outsystems

    .PARAMETER SourcePath
    If specified, the cmdlet will use the sources in that path.
    If not specified it will download the sources from the OutSystems repository.

    .PARAMETER Version
    The version to be installed.

    .PARAMETER SkipRabbitMQ
    If specified, the cmdlet will skip RabbitMQ installation.

    .PARAMETER WithLifetime
    If specified, the cmdlet will install the platform server with lifetime.

    .PARAMETER FullPathInstallDir
    If specified, the InstallDir will not be appended with \Platform Server

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .EXAMPLE
    Install-OSServer -Version "10.0.823.0"

    .EXAMPLE
    Install-OSServer -Version "10.0.823.0" -InstallDir D:\Outsystems

    .EXAMPLE
    Install-OSServer -Version "10.0.823.0" -InstallDir D:\Outsystems -SourcePath c:\temp

    .EXAMPLE
    Install-OSServer -Version "11.0.108.0" -InstallDir 'D:\Outsystems\Platform Server' -SourcePath c:\temp -SkipRabbitMQ -FullPathInstallDir

    .EXAMPLE
    Install-OSServer -Version "10.0.823.0" -Force

    .EXAMPLE
    To install the latest 11 version

    Install-OSServer -Verbose -Version $(Get-OSRepoAvailableVersions -MajorVersion 11 -Latest -Application 'PlatformServer')

    #>

    [CmdletBinding(DefaultParameterSetName = 'Remote')]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(ParameterSetName = 'Local')]
        [Parameter(ParameterSetName = 'Remote')]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir = $OSDefaultInstallDir,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Sources')]
        [string]$SourcePath,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Remote', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [version]$Version,

        [Parameter()]
        [string]$AdditionalParameters,

        [Parameter()]
        [switch]$SkipRabbitMQ,

        [Parameter()]
        [switch]$WithLifetime,

        [Parameter()]
        [switch]$Force
    )

    dynamicParam
    {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($InstallDir)
        {
            $FullPathInstallDirAttrib = New-Object System.Management.Automation.ParameterAttribute
            $FullPathInstallDirAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $FullPathInstallDirAttribCollection.Add($FullPathInstallDirAttrib)
            $FullPathInstallDirAttribCollection.Add($(New-Object Management.Automation.ValidateNotNullOrEmptyAttribute))
            $FullPathInstallDirParam = New-Object System.Management.Automation.RuntimeDefinedParameter('FullPathInstallDir', [switch], $FullPathInstallDirAttribCollection)

            $paramDictionary.Add('FullPathInstallDir', $FullPathInstallDirParam)
        }

        return $paramDictionary
    }

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.InstallResult'
            Success      = $true
            RebootNeeded = $false
            ExitCode     = 0
            Message      = 'OutSystems platform server successfully installed'
        }

        $osVersion = GetServerVersion
        $osInstallDir = GetServerInstallDir

        # Installer name
        $osInstaller = "PlatformServer-$Version.exe"
        if ($WithLifetime.IsPresent)
        {
            # Lifetime installer instead
            $osInstaller = "LifeTimeWithPlatformServer-$Version.exe"
        }
    }

    process
    {
        #region check
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
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OutSystems platform server is not installed"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Proceeding with normal installation"

            if (-not $PSBoundParameters.FullPathInstallDir.IsPresent)
            {
                $InstallDir = "$InstallDir\Platform Server"
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "FullPathInstallDir specified. Not appending \Platform Server"
            }
            $installPlatformServer = $true
        }
        elseif ([version]$osVersion -lt [version]$Version)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OutSystems platform server already installed. Updating!!"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Current version $osVersion will be updated to $Version"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Ignoring InstallDir since this is an update"
            $InstallDir = $osInstallDir
            $installPlatformServer = $true
        }
        elseif ([version]$osVersion -gt [version]$Version)
        {
            $installPlatformServer = $false
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "OutSystems platform server already installed with an higher version $osVersion"
            WriteNonTerminalError -Message "OutSystems platform server already installed with an higher version $osVersion"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = "OutSystems platform server already installed with an higher version $osVersion"

            return $installResult
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OutSystems platform server already installed with the specified version $osVersion"
            if ($Force.IsPresent)
            {
                $installPlatformServer = $true
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. We will reinstall!!"
            }
            else
            {
                $installPlatformServer = $false
            }
        }

        if ($Version -ge '11.0.0.0')
        {
            if ($SkipRabbitMQ.IsPresent)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ installation will be skipped"
            }
            else
            {
                if (-not $(GetErlangInstallDir))
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang not found. Proceeding with the installation"
                    $installErlang = $true
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang already installed at $(GetErlangInstallDir)"
                }

                if (-not $(GetRabbitInstallDir))
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ not found. Proceeding with the installation"
                    $installRabbitMQ = $true
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ already installed at $(GetRabbitInstallDir)"
                }
            }
        }
        #endregion

        #region install platform
        if ($installPlatformServer)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing version $Version"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing in $InstallDir"

            #Check if installer is local or is to be downloaded.
            switch ($PsCmdlet.ParameterSetName)
            {
                "Remote"
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SourcePath not specified. Downloading installer from repository"

                    $installer = "$ENV:TEMP\$osInstaller"
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Saving installer to $installer"

                    try
                    {
                        DownloadOSSources -URL "$OSRepoURL\$osInstaller" -SavePath $installer
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
                    $installer = "$SourcePath\$osInstaller"
                }
            }

            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the installation. This can take a while..."
                $result = Start-Process -FilePath $installer -ArgumentList "/S /D=$InstallDir $AdditionalParameters" -Wait -PassThru -ErrorAction Stop
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
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OutSystems platform server successfully installed"
                }
                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OutSystems platform server successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }
                default
                {
                    # Error. Let the caller decide what to do
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing the OutSystems platform server. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing the OutSystems platform server. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = "Error installing the OutSystems platform server"

                    return $installResult
                }
            }
        }
        #endregion

        # Refresh installdir variable after the installation
        $osInstallDir = GetServerInstallDir

        #region install erlang
        if ($installErlang)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Erlang"
                $exitCode = InstallErlang -Sources "$osInstallDir\thirdparty\erlang.exe" -InstallDir "$osInstallDir\thirdparty\Erlang"
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the Erlang installation"
                WriteNonTerminalError -Message "Error starting the Erlang installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error starting the Erlang installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang successfully installed"
                }
                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }
                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing Erlang. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing Erlang. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing Erlang'

                    return $installResult
                }
            }
        }
        #endregion

        #region install RabbitMQ
        if ($installRabbitMQ)
        {
            try
            {
                InstallRabbitMQPreReqs -RabbitBaseDir $OSRabbitMQBaseDir
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the pre-requisites for RabbitMQ"
                WriteNonTerminalError -Message "Error configuring the pre-requisites for RabbitMQ"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error configuring the pre-requisites for RabbitMQ'

                return $installResult
            }

            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing RabbitMQ"
                $exitCode = InstallRabbitMQ -Sources "$osInstallDir\thirdparty\rabbitmq.exe" -InstallDir "$osInstallDir\thirdparty\RabbitMQ Server"
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the RabbitMQ installation"
                WriteNonTerminalError -Message "Error starting the RabbitMQ installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error starting the RabbitMQ installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ successfully installed"

                    # Flag the installation for the configuration tool
                    $env:OUTSYSTEMS_RABBITMQ = "$osInstallDir\thirdparty\RabbitMQ Server"
                    [System.Environment]::SetEnvironmentVariable('OUTSYSTEMS_RABBITMQ', "$osInstallDir\thirdparty\RabbitMQ Server", "Machine")
                }
                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }
                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing RabbitMQ. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing RabbitMQ. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing RabbitMQ'

                    return $installResult
                }
            }
        }
        #endregion

        if ($installResult.RebootNeeded)
        {
            $installResult.ExitCode = 3010
            $installResult.Message = 'OutSystems platform server successfully installed but a reboot is needed'
        }
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
