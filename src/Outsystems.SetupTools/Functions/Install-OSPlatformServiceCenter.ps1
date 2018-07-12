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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Write-Output "Installing Outsystems Service Center. This can take a while... Please wait..."
        Try {
            CheckRunAsAdmin | Out-Null
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }

        Try {
            $OSVersion = GetServerVersion
            GetServerInstallDir | Out-Null
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
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
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Service Center was already compiled with this server version"
        }
    }

    Process {
        If ($DoInstall -or $Force.IsPresent) {

            If( $Force.IsPresent ){ LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. We will reinstall!!" }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems Service Center. This can take a while..."
            Try {
                $Result = RunSCInstaller -Arguments "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif"
            }
            Catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the service center installer"
                Throw "Error lauching the service center installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            ForEach ($Logline in $OutputLog) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SCINSTALLER: $Logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SCInstaller exit code: $($Result.ExitCode)"

            If ( $Result.ExitCode -ne 0 ) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing service center. Return code: $($Result.ExitCode)"
                throw "Error installing service center. Return code: $($Result.ExitCode)"
            }

            SetSCCompiledVersion -SCVersion $OSVersion | Out-Null
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service Center successfully installed!!"
        }
    }

    End {
        Write-Output "Outystems Service Center successfully installed!!"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}