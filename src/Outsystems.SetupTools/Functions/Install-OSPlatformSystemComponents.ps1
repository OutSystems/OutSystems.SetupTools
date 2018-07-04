Function Install-OSPlatformSystemComponents {
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

    .PARAMETER SystemCenterUser
    System Center username.

    .PARAMETER SystemCenterPass
    System Center password.

    .EXAMPLE
    Install-OSPlatformSystemComponents -Force -SystemCenterUser "admin" -SystemCenterPass "mypass"

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
        }
        Catch {}

        If ( $SCVersion -ne $OSVersion ) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        If ( $SystemComponentsVersion -ne $OSVersion ) {
            $DoInstall = $true
        }
        Else {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "The system components were already compiled with this server version"
        }
    }

    Process {

        If ($DoInstall -or $Force.IsPresent) {

            If( $Force.IsPresent ){ LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Force switch specified. We will reinstall!!" }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing System Components. This can take a while..."

            Try {
                $Result = RunOSPTool -Arguments $("/publish " + [char]34 + $("$OSInstallDir\System_Components.osp") + [char]34 + " $ENV:ComputerName $SystemCenterUser $SystemCenterPass")
            }
            Catch {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error lauching the system Components installer"
                Throw "Error lauching the system Components installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            ForEach ($Logline in $OutputLog) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "OSPTOOL: $Logline"
            }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "OSPTool exit code: $($Result.ExitCode)"

            If ( $Result.ExitCode -ne 0 ) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error installing the system Components. Return code: $($Result.ExitCode)"
                throw "Error installing the system Components. Return code: $($Result.ExitCode)"
            }

            SetSysComponentsCompiledVersion -SysComponentsVersion $OSVersion | Out-Null
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "System components successfully installed!!"
        }
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}