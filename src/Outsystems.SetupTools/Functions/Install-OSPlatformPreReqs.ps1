Function Install-OSPlatformPreReqs {
    <#
    .SYNOPSIS
    Install the pre-requisites for the platform server.

    .DESCRIPTION
    This will install the pre-requisites for the platform server version specified.
    It will not install .NET. You should run the Test-OSPlatformSoftwareReqs and the Test-OSPlatformHardwareReqs before running this one.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    The function will install the pre-requisites for the version specified on this parameter. Supported values: 10.0 or 11.0

    .PARAMETER InstallIISMgmtConsole
    Specifies if the IIS Managament Console will be installed.
    On servers without GUI this feature can't be installed. So you should set this parameter to $false.
    Defaults to $true

    .EXAMPLE
    Install-OSPlatformPreReqs -MajorVersion "10.0"
    Install-OSPlatformPreReqs -MajorVersion "11.0" -InstallIISMgmtConsole $false

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('10.0', '11.0')]
        [string]$MajorVersion,

        [Parameter()]
        [bool]$InstallIISMgmtConsole = $true
    )

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        If ( -not $(CheckRunAsAdmin)) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator of the machine"
            Throw "The current user is not Administrator of the machine"
        }
    }

    Process {
        # Base Windows features
        $WinFeatures = $OSWindowsFeaturesBase

        # Check if IISMgmtConsole is needed. In a server without GUI, the management console is not available
        If ($InstallIISMgmtConsole) {
            $WinFeatures += "Web-Mgmt-Console"
        }
        else {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "InstallIISMgmtConsole is false. Not adding IIS Management console to the list"
        }

        # Version specific pre-reqs install.
        Switch ($MajorVersion) {
            '10.0' {
                $WinFeatures += "MSMQ"
            }
            '11.0' {
                #TODO. Install RabbitMQ?
            }
        }

        # Do the actual install
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing pre-requisites for Outsystems major version $MajorVersion"

        # Windows features
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing windows features"
        ForEach ($Feature in $WinFeatures) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "$Feature"
        }
        InstallWindowsFeatures -Features $WinFeatures

        #Configure the WMI windows service
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring the WMI windows service"
        ConfigureServiceWMI

        #Configure the Windows search service
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring the Windows search service"
        ConfigureServiceWindowsSearch

        #Disable FIPS compliant algorithms checks
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Disabling FIPS compliant algorithms checks"
        DisableFIPS

        #Configure event log
        ForEach ($EventLog in $OSWinEventLogName) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring $EventLog Event Log"
            ConfigureWindowsEventLog -LogName $EventLog -LogSize $OSWinEventLogSize -LogOverflowAction $OSWinEventLogOverflowAction
        }

        # Version specific configuration.
        Switch ($MajorVersion) {
            '10.0' {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configure Message Queuing service to to always try to contact a message queue server when running on a server registered in a domain."
                ConfigureMSMQDomainServer
            }
            '11.0' {
                #TODO. Configure RabbitMQ? Or probably this needs to be done in the conf tool.. Lets see..
            }
        }
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}