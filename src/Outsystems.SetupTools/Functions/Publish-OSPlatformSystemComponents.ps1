Function Publish-OSPlatformSystemComponents {
    <#
    .SYNOPSIS
    Install or update Outsystems System Components.

    .DESCRIPTION
    This will install or update the System Components.
    You need to specify a user and a password to connect to Service Center. If you dont specify, the default admin will be used.
    It will skip the installation if already installed with the right version.
    Service Center needs to be installed using the Install-OSPlatformServiceCenter function.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .PARAMETER ServiceCenterUser
    Service Center username.

    .PARAMETER ServiceCenterPass
    Service Center password.

    .EXAMPLE
    Publish-OSPlatformSystemComponents -Force -ServiceCenterUser "admin" -ServiceCenterPass "mypass"

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [string]$ServiceCenterUser = $OSSCUser,

        [Parameter()]
        [string]$ServiceCenterPass = $OSSCPass
    )

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Write-Output "Installing Outsystems System Components. This can take a while... Please wait..."
        Try {
            CheckRunAsAdmin | Out-Null
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }

        Try {
            $OSVersion = GetServerVersion
            $OSInstallDir = GetServerInstallDir
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }

        Try {
            $SCVersion = GetSCCompiledVersion
            $SystemComponentsVersion = GetSysComponentsCompiledVersion
        }
        Catch {}

        If ( $SCVersion -ne $OSVersion ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        If ( $SystemComponentsVersion -ne $OSVersion ) {
            $DoInstall = $true
        }
        Else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "The system components were already compiled with this server version"
        }
    }

    Process {

        If ($DoInstall -or $Force.IsPresent) {

            If( $Force.IsPresent ){ LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. Will be reinstalled!!" }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems System Components. This can take a while..."
            Try {
                $Result = PublishSolution -Solution "$OSInstallDir\System_Components.osp" -SCUser $ServiceCenterUser -SCPass $ServiceCenterPass
            }
            Catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the system Components installer"
                Throw "Error lauching the system Components installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            ForEach ($Logline in $OutputLog) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTOOL: $Logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTool exit code: $($Result.ExitCode)"

            If ( $Result.ExitCode -ne 0 ) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing the system Components. Return code: $($Result.ExitCode)"
                throw "Error installing the system Components. Return code: $($Result.ExitCode)"
            }

            SetSysComponentsCompiledVersion -SysComponentsVersion $OSVersion | Out-Null
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "System components successfully installed!!"
        }
    }

    End {
        Write-Output "Outystems System components successfully installed!!"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}