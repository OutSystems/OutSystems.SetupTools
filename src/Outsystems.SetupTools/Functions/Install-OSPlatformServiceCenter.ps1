function Install-OSPlatformServiceCenter {
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

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"

        try {
            CheckRunAsAdmin | Out-Null
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }

        $OSVersion = GetServerVersion
        if ($(-not $OSVersion) -or $(-not $(GetServerInstallDir))){
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }

        if ( $(GetSCCompiledVersion) -ne $OSVersion ) {
            $DoInstall = $true
        } else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Service Center was already compiled with this server version"
        }
    }

    process {
        if ($DoInstall -or $Force.IsPresent) {

            if ( $Force.IsPresent ) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. We will reinstall!!"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems Service Center. This can take a while..."
            try {
                $Result = RunSCInstaller -Arguments "-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif"
            } catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the service center installer"
                throw "Error lauching the service center installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            foreach ($Logline in $OutputLog) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SCINSTALLER: $Logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SCInstaller exit code: $($Result.ExitCode)"

            if ( $Result.ExitCode -ne 0 ) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing service center. Return code: $($Result.ExitCode)"
                throw "Error installing service center. Return code: $($Result.ExitCode)"
            }

            SetSCCompiledVersion -SCVersion $OSVersion | Out-Null
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service Center successfully installed!!"
        }
    }

    end {
        Write-Output "Outystems Service Center successfully installed!!"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
