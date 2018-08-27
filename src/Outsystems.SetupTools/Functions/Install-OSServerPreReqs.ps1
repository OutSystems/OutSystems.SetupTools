function Install-OSServerPreReqs
{
    <#
    .SYNOPSIS
    Install the pre-requisites for the platform server.

    .DESCRIPTION
    This will install the pre-requisites for the platform server version specified.
    It will install .NET 4.6.1 if needed. After installing .NET a reboot will be probably needed.
    You should also run the Test-OSServerSoftwareReqs and the Test-OSServerHardwareReqs to check if your server is supported for Outsystems.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    The function will install the pre-requisites for the version specified on this parameter. Supported values: 10.0 or 11.0

    .PARAMETER InstallIISMgmtConsole
    Specifies if the IIS Managament Console will be installed.
    On servers without GUI this feature can't be installed. So you should set this parameter to $false.
    Defaults to $true

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "10.0"
    Install-OSServerPreReqs -MajorVersion "11.0" -InstallIISMgmtConsole:$false

    #>

    [CmdletBinding()]
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
        try
        {
            CheckRunAsAdmin | Out-Null
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }
    }

    process
    {
        # Base Windows features
        $WinFeatures = $OSWindowsFeaturesBase

        # Check if IISMgmtConsole is needed. In a server without GUI, the management console is not available
        if ($InstallIISMgmtConsole)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding IIS Management console feature to the windows features list"
            $WinFeatures += "Web-Mgmt-Console"
        }

        # Version specific pre-reqs install.
        switch ($MajorVersion)
        {
            '10.0'
            {
                # Check .NET version
                if ($(GetDotNet4Version) -lt $OS10ReqsMinDotNetVersion)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion not found. We will try to download and install NET 4.7.1."
                    $installDotNet = $true
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding Microsoft Message Queueing feature to the windows features list"
                $WinFeatures += "MSMQ"
            }

            '11.0'
            {
                # Check .NET version
                if ($(GetDotNet4Version) -lt $OS11ReqsMinDotNetVersion)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion not found. We will try to download and install NET 4.7.1."
                    $installDotNet = $true
                }

                #TODO. Install RabbitMQ?
            }
        }

        # Do the actual install
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing pre-requisites for Outsystems major version $MajorVersion"

        # Install .NET
        if ($installDotNet)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET 4.7.1"
                $intReturnCode = InstallDotNet
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET installation"
                throw "Error downloading or starting the .NET installation"
            }

            switch ($intReturnCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 4.7.1 successfully installed."
                }

                3010
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 4.7.1 successfully installed but a reboot is needed!!!!! Exit code: $intReturnCode"
                    throw ".NET 4.7.1 successfully installed but a reboot is needed!!!!! Exit code: $intReturnCode"
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET 4.7.1. Exit code: $intReturnCode"
                    throw "Error installing .NET 4.7.1. Exit code: $intReturnCode"
                }
            }
        }

        # Install build tools 2015
        if (-not $(IsMSIInstalled -ProductCode '{8C918E5B-E238-401F-9F6E-4FB84B024CA2}'))
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Build Tools 2015"
                $intReturnCode = InstallBuildTools
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the Build Tools installation"
                throw "Error downloading or starting the Build Tools installation"
            }

            switch ($intReturnCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools successfully installed."
                }

                3010
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools successfully installed but a reboot is needed!!!!! Exit code: $intReturnCode"
                    throw "Build Tools successfully installed but a reboot is needed!!!!! Exit code: $intReturnCode"
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing Build Tools. Exit code: $intReturnCode"
                    throw "Error installing Build Tools. Exit code: $intReturnCode"
                }
            }
        }

        # Windows features
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing windows features"
        $ProgressPreference = "SilentlyContinue"

        try
        {
            InstallWindowsFeatures -Features $WinFeatures
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error installing windows features"
            throw "Error installing windows features"
        }

        #Configure the WMI windows service
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the WMI windows service"
        try
        {
            ConfigureServiceWMI
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the WMI service"
            throw "Error configuring the WMI service"
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
            throw "Error configuring the Windows search service"
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
            throw "Error disabling FIPS compliant algorithms checks"
        }

        #Configure event log
        foreach ($EventLog in $OSWinEventLogName)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring $EventLog Event Log"
            try
            {
                ConfigureWindowsEventLog -LogName $EventLog -LogSize $OSWinEventLogSize -LogOverflowAction $OSWinEventLogOverflowAction
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring $EventLog Event Log"
                throw "Error configuring $EventLog Event Log"
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
                    throw "Error configuring the Message Queuing service"
                }
            }
            '11.0'
            {
                #TODO. Configure RabbitMQ? Or probably this needs to be done in the conf tool.. Lets see..
            }
        }
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
