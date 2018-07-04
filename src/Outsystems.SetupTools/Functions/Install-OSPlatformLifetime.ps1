Function Install-OSPlatformLifetime {
    <#
    .SYNOPSIS
    Install or update Outsystems Lifetime.

    .DESCRIPTION
    This will install or update Lifetime.
    You need to specify a user and a password to connect to Service Center. If you dont specify, the default admin will be used.
    It will skip the installation if already installed with the right version.
    Service Center needs to be installed using the Install-OSPlatformServiceCenter function.
    Outsystems system components needs to be installed using the Install-OSPlatformSystemComponents function.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .PARAMETER SystemCenterUser
    System Center username.

    .PARAMETER SystemCenterPass
    System Center password.

    .EXAMPLE
    Install-OSPlatformLifetime -Force -SystemCenterUser "admin" -SystemCenterPass "mypass"

    #>

    [CmdletBinding()]
    param (
        [string]$SystemCenterUser = $OSSCUser,
        [string]$SystemCenterPass = $OSSCPass
    )

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        Try {
            CheckRunAsAdmin | Out-Null
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }

        Try {
            $OSVersion = GetServerVersion
            $OSInstallDir = GetServerInstallDir
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }

        Try {
            $SCVersion = GetSCCompiledVersion
            $SystemComponentsVersion = GetSysComponentsCompiledVersion
            $LifetimeVersion = GetLifetimeCompiledVersion
        }
        Catch {}

        If ( $SCVersion -ne $OSVersion ) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        If ( $SystemComponentsVersion -ne $OSVersion ) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Systems components version mismatch. You should run the Install-OSPlatformSystemComponents first"
            throw "Systems components version mismatch. You should run the Install-OSPlatformSystemComponents first"
        }

        If ( $LifetimeVersion -ne $OSVersion ) {
            $DoInstall = $true
        }
        Else {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Lifetime was already compiled with this server version"
        }
    }

    Process {

        If ($DoInstall -or $Force.IsPresent) {

            If( $Force.IsPresent ){ LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Force switch specified. We will reinstall!!" }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing Lifetime. This can take a while..."

            Try {
                $Result = RunOSPTool -Arguments $("/publish " + [char]34 + $("$OSInstallDir\Lifetime.osp") + [char]34 + " $ENV:ComputerName $SystemCenterUser $SystemCenterPass")
            }
            Catch {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error lauching the lifetime installer"
                Throw "Error lauching the lifetime installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            ForEach ($Logline in $OutputLog) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "OSPTOOL: $Logline"
            }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "OSPTool exit code: $($Result.ExitCode)"

            If ( $Result.ExitCode -ne 0 ) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error installing lifetime. Return code: $($Result.ExitCode)"
                throw "Error installing lifetime. Return code: $($Result.ExitCode)"
            }

            SetLifetimeCompiledVersion -LifetimeVersion $OSVersion | Out-Null
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Lifetime successfully installed!!"
        }
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}