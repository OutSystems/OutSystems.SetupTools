Function Install-OSPlatformServiceCenter {
    <#
    .SYNOPSIS
    Install or update Outsystems Service Center.

    .DESCRIPTION
    This will install or update the Service Center. It will skip the installation if already installed with the right version.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .EXAMPLE
    Install-OSPlatformServiceCenter -Force

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Force
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
            GetServerInstallDir | Out-Null
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }

        Try {
            $SCVersion = GetSCCompiledVersion
        }
        Catch {}

        If ( $SCVersion -ne $OSVersion ) {
            $DoInstall = $true
        }
        Else {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Service Center was already compiled with this server version"
        }
    }

    Process {
        If ($DoInstall -or $Force.IsPresent) {

            If( $Force.IsPresent ){ LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Force switch specified. We will reinstall!!" }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing Service Center. This can take a while..."

            Try {
                $Result = RunSCInstaller -Arguments "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif"
            }
            Catch {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error lauching the service center installer"
                Throw "Error lauching the service center installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            ForEach ($Logline in $OutputLog) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "SCINSTALLER: $Logline"
            }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "SCInstaller exit code: $($Result.ExitCode)"

            If ( $Result.ExitCode -ne 0 ) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error installing service center. Return code: $($Result.ExitCode)"
                throw "Error installing service center. Return code: $($Result.ExitCode)"
            }

            SetSCCompiledVersion -SCVersion $OSVersion | Out-Null
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service Center successfully installed!!"
        }
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}