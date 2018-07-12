Function Install-OSPlatformPreReqs {
    <#
    .SYNOPSIS
    Install the pre-requisites for the platform server.

    .DESCRIPTION
    This will install the pre-requisites for the platform server version specified.
    It will install .NET 4.6.1 if needed. After installing .NET a reboot will be probably needed.
    You should also run the Test-OSPlatformSoftwareReqs and the Test-OSPlatformHardwareReqs to check if your server is supported for Outsystems.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    The function will install the pre-requisites for the version specified on this parameter. Supported values: 10.0 or 11.0

    .PARAMETER InstallIISMgmtConsole
    Specifies if the IIS Managament Console will be installed.
    On servers without GUI this feature can't be installed. So you should set this parameter to $false.
    Defaults to $true

    .EXAMPLE
    Install-OSPlatformPreReqs -MajorVersion "10.0"
    Install-OSPlatformPreReqs -MajorVersion "11.0" -InstallIISMgmtConsole:$false

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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Write-Output "Starting the pre-requisites installation. This can take a while... Please wait..."
        Try {
            CheckRunAsAdmin | Out-Null
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }
    }

    Process {
        # Check and install .NET
        If ($(GetDotNet4Version) -lt $OSReqsMinDotNetVersion) {
            Write-Output "Minimum .NET version is not installed. We will try to download and install NET 4.6.1..."
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version is not installed. We will try to download and install NET 4.6.1."

            #Download sources from repo
            $Installer = "$ENV:TEMP\NDP461-KB3102436-x86-x64-AllOS-ENU.exe"
            Try {
                DownloadOSSources -URL "$OSRepoURL\NDP461-KB3102436-x86-x64-AllOS-ENU.exe" -SavePath $Installer
            }
            Catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading the installer from repository. Check if version is correct"
                Throw "Error downloading the installer from repository. Check if file name is correct"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the installation. This can take a while..."
            $IntReturnCode = Start-Process -FilePath $Installer -ArgumentList "/q","/norestart","/MSIOPTIONS `"ALLUSERS=1 REBOOT=ReallySuppress`"" -Wait -PassThru
            Switch ($IntReturnCode.ExitCode){
                0 {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 4.6.1 successfully installed."
                }
                3010 {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 4.6.1 successfully installed but a reboot is needed!!!!! Exit code: $($IntReturnCode.ExitCode)"
                    Throw ".NET 4.6.1 successfully installed but a reboot is needed!!!!! Exit code: $($IntReturnCode.ExitCode)"
                }
                Default {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error installing .NET 4.6.1. Exit code: $($IntReturnCode.ExitCode)"
                    Throw "Error installing .NET 4.6.1. Exit code: $($IntReturnCode.ExitCode)"
                }
            }

        } Else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installed .NET is supported for OutSystems"
        }

        # Base Windows features
        $WinFeatures = $OSWindowsFeaturesBase

        # Check if IISMgmtConsole is needed. In a server without GUI, the management console is not available
        If ($InstallIISMgmtConsole) {
            $WinFeatures += "Web-Mgmt-Console"
        }
        else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "InstallIISMgmtConsole is false. Not adding IIS Management console to the list"
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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing pre-requisites for Outsystems major version $MajorVersion"

        # Windows features
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing windows features"
        $ProgressPreference = "SilentlyContinue"

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the installation"
        Try {
            InstallWindowsFeatures -Features $WinFeatures
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error installing windows features"
            Throw "Error installing windows features"
        }

        #Configure the WMI windows service
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the WMI windows service"
        Try {
            ConfigureServiceWMI
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the WMI service"
            Throw "Error configuring the WMI service"
        }

        #Configure the Windows search service
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the Windows search service"
        Try {
            ConfigureServiceWindowsSearch
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the Windows search service"
            Throw "Error configuring the Windows search service"
        }

        #Disable FIPS compliant algorithms checks
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling FIPS compliant algorithms checks"
        Try {
            DisableFIPS
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling FIPS compliant algorithms checks"
            Throw "Error disabling FIPS compliant algorithms checks"
        }

        #Configure event log
        ForEach ($EventLog in $OSWinEventLogName) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring $EventLog Event Log"
            Try {
                ConfigureWindowsEventLog -LogName $EventLog -LogSize $OSWinEventLogSize -LogOverflowAction $OSWinEventLogOverflowAction
            }
            Catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring $EventLog Event Log"
                Throw "Error configuring $EventLog Event Log"
            }
        }

        # Version specific configuration.
        Switch ($MajorVersion) {
            '10.0' {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configure Message Queuing service to to always try to contact a message queue server when running on a server registered in a domain."
                Try {
                    ConfigureMSMQDomainServer
                }
                Catch {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the Message Queuing service"
                    Throw "Error configuring the Message Queuing service"
                }
            }
            '11.0' {
                #TODO. Configure RabbitMQ? Or probably this needs to be done in the conf tool.. Lets see..
            }
        }
    }

    End {
        Write-Output "Pre-requisites successfully installed!!"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}