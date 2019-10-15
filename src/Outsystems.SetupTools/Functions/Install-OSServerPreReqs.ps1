function Install-OSServerPreReqs
{
    <#
    .SYNOPSIS
    Installs the pre-requisites for the OutSystems platform server.

    .DESCRIPTION
    This will install the pre-requisites for the OutSystems platform server.
    You should run first the Test-OSServerSoftwareReqs and the Test-OSServerHardwareReqs cmdlets to check if the server is supported for OutSystems.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    Accepted values: 10 or 11.

    .PARAMETER InstallIISMgmtConsole
    Specifies if the IIS Managament Console will be installed.
    On servers without GUI this feature can't be installed so you should set this parameter to $false.

    .PARAMETER SourcePath
    Specifies a local path having the pre-requisites binaries.

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "10"

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false

     .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false -SourcePath "c:\downloads"

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('1[0-1]{1}(\.0)?')]
        [string]$MajorVersion,

        [Parameter()]
        [Alias('Sources')]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

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
            Message = 'OutSystems platform server pre-requisites successfully installed'
        }

        #The MajorVersion parameter supports 11.0 or 11. Therefore, we need to remove the '.0' part
        $MajorVersion = $MajorVersion.replace(".0","")
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

        # Base Windows Features
        $winFeatures = $OSWindowsFeaturesBase

        # Check if IISMgmtConsole is needed. In a server without GUI, the management console is not available
        if ($InstallIISMgmtConsole)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding IIS Management console feature to the Windows Features list"
            $winFeatures += "Web-Mgmt-Console"
        }

        #region check
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Checking pre-requisites for OutSystems major version $MajorVersion"

        # MS Buld Tools minimum version is different depending on the Platform Major Version
        # 10 : 2015 and 2015 Update 3 are allowed but 2017 is not
        # 11 : All the above three are allowed
        $MSBuildInstallInfo = $(GetMSBuildToolsInstallInfo)

        if (-not $(IsMSBuildToolsVersionValid -MajorVersion $MajorVersion -InstallInfo $MSBuildInstallInfo))
        {
            if ($MSBuildInstallInfo.LatestVersionInstalled)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$($MSBuildInstallInfo.LatestVersionInstalled) found but this version is not supported by OutSystems. We will try to download and install MS Build Tools 2015."
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "No valid MS Build Tools version found, this is an OutSystems requirement. We will try to download and install MS Build Tools 2015."
            }

            $installBuildTools = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$($MSBuildInstallInfo.LatestVersionInstalled) found"

            $installResult.RebootNeeded = $MSBuildInstallInfo.RebootNeeded
        }

        # Version specific pre-reqs checks.
        switch ($MajorVersion)
        {
            '10'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding Microsoft Message Queueing feature to the Windows Features list since its required for OutSystems $MajorVersion"
                $winFeatures += "MSMQ"
            }

            '11'
            {
                # Check .NET Core Windows Server Hosting version
                if ([version]$(GetWindowsServerHostingVersion) -lt [version]$OS11ReqsMinDotNetCoreVersion)
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

        # Check .NET version
        $MinDotNet4Version = $(GetMinDotNet4VersionForMajor -PlatformMajorVersion $MajorVersion)
        if ($(GetDotNet4Version) -lt $MinDotNet4Version.Value)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion not found. We will try to download and install NET $($MinDotNet4Version.Version)"
            $installDotNet = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion found"
        }
        #endregion

        #region install
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing pre-requisites for OutSystems major version $MajorVersion"

        # Windows Features
        # Exit codes available at: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc733119(v=ws.11)
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Windows Features"
        try
        {
            $result = InstallWindowsFeatures -Features $winFeatures
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the Windows Features installation"
            WriteNonTerminalError -Message "Error starting the Windows Features installation"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = "Error starting the Windows Features installation"

            return $installResult
        }

        if ($result.Success)
        {
            if ($result.RestartNeeded.value__ -ne 1)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows Features successfully installed but a reboot is needed."
                $installResult.RebootNeeded = $true
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows Features successfully installed"
            }
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing Windows Features. Exit code: $($result.ExitCode.value__)"
            WriteNonTerminalError -Message "Error installing Windows Features. Exit code: $($result.ExitCode.value__)"

            $installResult.Success = $false
            $installResult.ExitCode = $result.ExitCode.value__
            $installResult.Message = 'Error installing Windows Features'

            return $installResult
        }

        # Install build tools 2015
        if ($installBuildTools)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Build Tools 2015"
                $exitCode = InstallBuildTools -Sources $SourcePath
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
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools 2015 successfully installed but a reboot is needed. Exit code: $exitCode"
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
                $exitCode = InstallDotNetCore -Sources $SourcePath
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
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Core Windows Server Hosting bundle successfully installed but a reboot is needed. Exit code: $exitCode"
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
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET $($MinDotNet4Version.Version)"
                $exitCode = InstallDotNet -Sources $SourcePath -MinDotNet4Version $($MinDotNet4Version.Version)
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
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET $($MinDotNet4Version.Version) successfully installed"
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET $($MinDotNet4Version.Version) successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET $($MinDotNet4Version.Version). Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET $($MinDotNet4Version.Version). Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = "Error installing .NET $($MinDotNet4Version.Version)"

                    return $installResult
                }
            }
        }
        #endregion

        #region configuration
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring pre-requisites for OutSystems major version $MajorVersion"

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
            '10'
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
            '11'
            {
                # Nothing to be done here
            }
        }
        #endregion

        if ($installResult.RebootNeeded)
        {
            $installResult.ExitCode = 3010
            $installResult.Message = 'OutSystems platform server pre-requisites successfully installed but a reboot is required'
        }
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
