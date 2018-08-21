function Publish-OSPlatformLifetime {
    <#
    .SYNOPSIS
    Install or update Outsystems Lifetime.

    .DESCRIPTION
    This will install or update Lifetime.
    You need to specify a user and a password to connect to Service Center. if you dont specify, the default admin will be used.
    It will skip the installation if already installed with the right version.
    Service Center needs to be installed using the Install-OSPlatformServiceCenter function.
    Outsystems system components needs to be installed using the Publish-OSPlatformSystemComponents function.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .PARAMETER ServiceCenterUser
    Service Center username.

    .PARAMETER ServiceCenterPass
    Service Center password.

    .EXAMPLE
    Publish-OSPlatformLifetime -Force -ServiceCenterUser "admin" -ServiceCenterPass "mypass"

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
        Write-Output "Starting Lifetime installation. This can take a while... Please wait..."
        try {
            CheckRunAsAdmin | Out-Null
        }
        catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }

        try {
            $OSVersion = GetServerVersion
            $OSInstallDir = GetServerInstallDir
        }
        catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }

        try {
            $SCVersion = GetSCCompiledVersion
            $SystemComponentsVersion = GetSysComponentsCompiledVersion
            $LifetimeVersion = GetLifetimeCompiledVersion
        }
        catch {}

        if ( $SCVersion -ne $OSVersion ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        if ( $SystemComponentsVersion -ne $OSVersion ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Systems components version mismatch. You should run the Publish-OSPlatformSystemComponents first"
            throw "Systems components version mismatch. You should run the Publish-OSPlatformSystemComponents first"
        }

        if ( $LifetimeVersion -ne $OSVersion ) {
            $DoInstall = $true
        }
        else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Lifetime was already compiled with this server version"
        }
    }

    process {

        if ($DoInstall -or $Force.IsPresent) {

            if( $Force.IsPresent ){ LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. We will reinstall!!" }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Lifetime. This can take a while..."

            try {
                $Result = PublishSolution -Solution "$OSInstallDir\Lifetime.osp" -SCUser $ServiceCenterUser -SCPass $ServiceCenterPass
            }
            catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the lifetime installer"
                throw "Error lauching the lifetime installer"
            }

            $OutputLog = $($Result.Output) -Split ("`r`n")
            foreach ($Logline in $OutputLog) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTOOL: $Logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTool exit code: $($Result.ExitCode)"

            if ($Result.ExitCode -ne 0) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing lifetime. Return code: $($Result.ExitCode)"
                throw "Error installing lifetime. Return code: $($Result.ExitCode)"
            }

            SetLifetimeCompiledVersion -LifetimeVersion $OSVersion | Out-Null
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Lifetime successfully installed!!"
        }
    }

    end {
        Write-Output "Outystems Lifetime successfully installed!!"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
