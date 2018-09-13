function Install-OSServerPreReqs
{
    <#
    .SYNOPSIS
    Install the pre-requisites for the platform server.

    .DESCRIPTION
    This will install the pre-requisites for the platform server version specified.
    You should also run the Test-OSServerSoftwareReqs and the Test-OSServerHardwareReqs to check if your server is supported for Outsystems.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    The function will install the pre-requisites for the version specified on this parameter. Accepted values: 10.0 or 11.0

    .PARAMETER InstallIISMgmtConsole
    Specifies if the IIS Managament Console will be installed.
    On servers without GUI this feature can't be installed. So you should set this parameter to $false.
    Defaults to $true if not specified.

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "10.0"
    Install-OSServerPreReqs -MajorVersion "11.0" -InstallIISMgmtConsole:$false

    .NOTES
    All error are non-terminating. The function caller should decide what to do using the -ErrorAction parameter or using the $ErrorPreference variable.

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('10.0', '11.0')]
        [string]$MajorVersion,

        [Parameter()]
        [bool]$InstallIISMgmtConsole = $true
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName = 'Outsystems.SetupTools.InstallResult'
            Success = $true
            RebootNeeded = $false
            ExitCode = 0
            Message = 'Outsystems platform server pre-requisites successfully installed'
        }
    }

    process
    {
        # Check if user is admin
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        # Base Windows features
        $winFeatures = $OSWindowsFeaturesBase

        # Check if IISMgmtConsole is needed. In a server without GUI, the management console is not available
        if ($InstallIISMgmtConsole)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding IIS Management console feature to the windows features list"
            $winFeatures += "Web-Mgmt-Console"
        }

        #region check
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Checking pre-requisites for Outsystems major version $MajorVersion"

        # Check build tools 2015. Its required for all OS versions
        if (-not $(IsMSIInstalled -ProductCode '{8C918E5B-E238-401F-9F6E-4FB84B024CA2}'))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools 2015 not found but its required for Outsystems. We will try to download and install"
            $installBuildTools = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools 2015 found"
        }

        # Version specific pre-reqs checks.
        switch ($MajorVersion)
        {
            '10.0'
            {
                # Check .NET version
                if ($(GetDotNet4Version) -lt $OS10ReqsMinDotNetVersion)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion not found. We will try to download and install NET 4.7.1"
                    $installDotNet = $true
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion found"
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding Microsoft Message Queueing feature to the windows features list since its required for OutSystems $MajorVersion"
                $winFeatures += "MSMQ"
            }

            '11.0'
            {
                # Check .NET version
                if ($(GetDotNet4Version) -lt $OS11ReqsMinDotNetVersion)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion not found. We will try to download and install NET 4.7.1"
                    $installDotNet = $true
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion found"
                }

                # Check .NET Core Windows Server Hosting version
                if ([version]$(GetDotNetCoreVersion) -lt [version]$OS11ReqsMinDotNetCoreVersion)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET Core Windows Server Hosting version for OutSystems $MajorVersion not found. We will try to download and install the latest .NET Core Windows Server Hosting bundle"
                    $installDotNetCore = $true
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET Core Windows Server Hosting for OutSystems $MajorVersion found"
                }

            }
        }
        #endregion

        #region install
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing pre-requisites for Outsystems major version $MajorVersion"

        # Windows features
        # Exit codes available at: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc733119(v=ws.11)
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing windows features"
        try
        {
            $result = InstallWindowsFeatures -Features $winFeatures
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the windows features installation"
            WriteNonTerminalError -Message "Error starting the windows features installation"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = "Error starting the windows features installation"

            return $installResult
        }

        if ($result.Success)
        {
            if ($result.RestartNeeded.value__ -ne 1)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows features successfully installed but a reboot is needed!!!!!"
                $installResult.RebootNeeded = $true
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows features successfully installed"
            }
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing windows features. Exit code: $($result.ExitCode.value__)"
            WriteNonTerminalError -Message "Error installing windows features. Exit code: $($result.ExitCode.value__)"

            $installResult.Success = $false
            $installResult.ExitCode = $result.ExitCode.value__
            $installResult.Message = 'Error installing windows features'

            return $installResult
        }

        # Install build tools 2015
        if ($installBuildTools)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Build Tools 2015"
                $exitCode = InstallBuildTools
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the Build Tools installation"
                WriteNonTerminalError -Message "Error downloading or starting the Build Tools installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the Build Tools installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools 2015 successfully installed"
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools 2015 successfully installed but a reboot is needed!!!!! Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing Build Tools 2015. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing Build Tools 2015. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing Build Tools 2015'

                    return $installResult
                }
            }
        }

        # Install .NET Core Windows Server Hosting bundle
        if ($installDotNetCore)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET Core Windows Server Hosting bundle"
                $exitCode = InstallDotNetCore
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET Core installation"
                WriteNonTerminalError -Message "Error downloading or starting the .NET Core installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the .NET Core installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Core Windows Server Hosting bundle successfully installed."
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Core Windows Server Hosting bundle successfully installed but a reboot is needed!!!!! Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET Core Windows Server Hosting bundle. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET Core Windows Server Hosting bundle. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing .NET Core Windows Server Hosting bundle'

                    return $installResult
                }
            }
        }

        # Install .NET
        if ($installDotNet)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET 4.7.1"
                $exitCode = InstallDotNet
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET installation"
                WriteNonTerminalError -Message "Error downloading or starting the .NET installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the .NET installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 4.7.1 successfully installed"
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 4.7.1 successfully installed but a reboot is needed!!!!! Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET 4.7.1. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET 4.7.1. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing .NET 4.7.1'

                    return $installResult
                }
            }
        }
        #endregion

        #region configuration
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring pre-requisites for Outsystems major version $MajorVersion"

        #Configure the WMI windows service
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the WMI windows service"
        try
        {
            ConfigureServiceWMI
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the WMI service"
            WriteNonTerminalError -Message "Error configuring the WMI service"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error configuring the WMI service'

            return $installResult
        }

        #Configure the Windows search service
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the Windows search service"
        try
        {
            ConfigureServiceWindowsSearch
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the Windows search service"
            WriteNonTerminalError -Message "Error configuring the Windows search service"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error configuring the Windows search service'

            return $installResult
        }

        #Disable FIPS compliant algorithms checks
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling FIPS compliant algorithms checks"
        try
        {
            DisableFIPS
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling FIPS compliant algorithms checks"
            WriteNonTerminalError -Message "Error disabling FIPS compliant algorithms checks"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error disabling FIPS compliant algorithms checks'

            return $installResult
        }

        #Configure event log
        foreach ($eventLog in $OSWinEventLogName)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring $eventLog Event Log"
            try
            {
                ConfigureWindowsEventLog -LogName $eventLog -LogSize $OSWinEventLogSize -LogOverflowAction $OSWinEventLogOverflowAction
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring $eventLog Event Log"
                WriteNonTerminalError -Message "Error configuring $eventLog Event Log"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = "Error configuring $eventLog Event Log"

                return $installResult
            }
        }

        # Version specific configuration.
        switch ($MajorVersion)
        {
            '10.0'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configure Message Queuing service to to always try to contact a message queue server when running on a server registered in a domain."
                try
                {
                    ConfigureMSMQDomainServer
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the Message Queuing service"
                    WriteNonTerminalError -Message "Error configuring the Message Queuing service"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = 'Error configuring the Message Queuing service'

                    return $installResult
                }
            }
            '11.0'
            {
                # Nothing to be done here
            }
        }
        #endregion

        if ($installResult.RebootNeeded)
        {
            $installResult.ExitCode = 3010
            $installResult.Message = 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
        }
        return $installResult
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
