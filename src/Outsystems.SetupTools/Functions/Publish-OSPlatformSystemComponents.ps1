function Publish-OSPlatformSystemComponents {
    <#
    .SYNOPSIS
    Install or update Outsystems System Components.

    .DESCRIPTION
    This will install or update the System Components.
    You need to specify a user and a password to connect to Service Center. if you dont specify, the default admin will be used.
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

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"

        try {
            CheckRunAsAdmin | Out-Null
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }

        $OSVersion = GetServerVersion
        $OSInstallDir = GetServerInstallDir
        if ($(-not $OSVersion) -or $(-not $OSInstallDir)){
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }

        if ( $(GetSCCompiledVersion) -ne $OSVersion ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        if ( $(GetSysComponentsCompiledVersion) -ne $OSVersion ) {
            $DoInstall = $true
        } else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "The system components were already compiled with this server version"
        }
    }

    process {

        if ($DoInstall -or $Force.IsPresent) {

            if ( $Force.IsPresent ) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. Will be reinstalled!!"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems System Components. This can take a while..."
            try {
                $Result = PublishSolution -Solution "$OSInstallDir\System_Components.osp" -SCUser $ServiceCenterUser -SCPass $ServiceCenterPass
            } catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the system Components installer"
                throw "Error lauching the system Components installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            foreach ($Logline in $OutputLog) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTOOL: $Logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTool exit code: $($Result.ExitCode)"

            if ( $Result.ExitCode -ne 0 ) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing the system Components. Return code: $($Result.ExitCode)"
                throw "Error installing the system Components. Return code: $($Result.ExitCode)"
            }

            SetSysComponentsCompiledVersion -SysComponentsVersion $OSVersion | Out-Null
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "System components successfully installed!!"
        }
    }

    end {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
