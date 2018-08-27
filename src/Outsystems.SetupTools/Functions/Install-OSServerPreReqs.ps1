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
        # Check and install .NET
        if ($(GetDotNet4Version) -lt $OSReqsMinDotNetVersion)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version is not installed. We will try to download and install NET 4.6.1."

            #Download sources from repo
            $Installer = "$ENV:TEMP\NDP461-KB3102436-x86-x64-AllOS-ENU.exe"
            try
            {
                DownloadOSSources -URL "$OSRepoURL\NDP461-KB3102436-x86-x64-AllOS-ENU.exe" -SavePath $Installer
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading the installer from repository. Check if version is correct"
                throw "Error downloading the installer from repository. Check if file name is correct"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the installation. This can take a while..."
            $IntReturnCode = Start-Process -FilePath $Installer -ArgumentList "/q", "/norestart", "/MSIOPTIONS `"ALLUSERS=1 REBOOT=ReallySuppress`"" -Wait -PassThru
            switch ($IntReturnCode.ExitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 4.6.1 successfully installed."
                }

                3010
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message ".NET 4.6.1 successfully installed but a reboot is needed!!!!! Exit code: $($IntReturnCode.ExitCode)"
                    throw ".NET 4.6.1 successfully installed but a reboot is needed!!!!! Exit code: $($IntReturnCode.ExitCode)"
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET 4.6.1. Exit code: $($IntReturnCode.ExitCode)"
                    throw "Error installing .NET 4.6.1. Exit code: $($IntReturnCode.ExitCode)"
                }
            }

        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installed .NET is supported for OutSystems"
        }

        # Base Windows features
        $WinFeatures = $OSWindowsFeaturesBase

        # Check if IISMgmtConsole is needed. In a server without GUI, the management console is not available
        if ($InstallIISMgmtConsole)
        {
            $WinFeatures += "Web-Mgmt-Console"
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "InstallIISMgmtConsole is false. Not adding IIS Management console to the list"
        }

        # Version specific pre-reqs install.
        switch ($MajorVersion)
        {
            '10.0'
            {
                $WinFeatures += "MSMQ"
            }
            '11.0'
            {
                #TODO. Install RabbitMQ?
            }
        }

        # Do the actual install
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing pre-requisites for Outsystems major version $MajorVersion"

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
