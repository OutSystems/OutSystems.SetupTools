Function Publish-OSPlatformLifetime {
    <#
    .SYNOPSIS
    Install or update Outsystems Lifetime.

    .DESCRIPTION
    This will install or update Lifetime.
    You need to specify a user and a password to connect to Service Center. If you dont specify, the default admin will be used.
    It will skip the installation if already installed with the right version.
    Service Center needs to be installed using the Install-OSPlatformServiceCenter function.
    Outsystems system components needs to be installed using the Publish-OSPlatformSystemComponents function.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .PARAMETER SystemCenterUser
    System Center username.

    .PARAMETER SystemCenterPass
    System Center password.

    .EXAMPLE
    Publish-OSPlatformLifetime -Force -SystemCenterUser "admin" -SystemCenterPass "mypass"

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [string]$SystemCenterUser = $OSSCUser,

        [Parameter()]
        [string]$SystemCenterPass = $OSSCPass
    )

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Write-Output "Starting Lifetime installation. This can take a while... Please wait..."
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
            $LifetimeVersion = GetLifetimeCompiledVersion
        }
        Catch {}

        If ( $SCVersion -ne $OSVersion ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        If ( $SystemComponentsVersion -ne $OSVersion ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Systems components version mismatch. You should run the Publish-OSPlatformSystemComponents first"
            throw "Systems components version mismatch. You should run the Publish-OSPlatformSystemComponents first"
        }

        If ( $LifetimeVersion -ne $OSVersion ) {
            $DoInstall = $true
        }
        Else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Lifetime was already compiled with this server version"
        }
    }

    Process {

        If ($DoInstall -or $Force.IsPresent) {

            If( $Force.IsPresent ){ LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. We will reinstall!!" }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Lifetime. This can take a while..."

            Try {
                $Result = PublishSolution -Solution "$OSInstallDir\Lifetime.osp" -SCUser $SystemCenterUser -SCPass $SystemCenterPass
            }
            Catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the lifetime installer"
                Throw "Error lauching the lifetime installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            ForEach ($Logline in $OutputLog) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTOOL: $Logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTool exit code: $($Result.ExitCode)"

            If ( $Result.ExitCode -ne 0 ) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing lifetime. Return code: $($Result.ExitCode)"
                throw "Error installing lifetime. Return code: $($Result.ExitCode)"
            }

            SetLifetimeCompiledVersion -LifetimeVersion $OSVersion | Out-Null
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Lifetime successfully installed!!"
        }
    }

    End {
        Write-Output "Outystems Lifetime successfully installed!!"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}