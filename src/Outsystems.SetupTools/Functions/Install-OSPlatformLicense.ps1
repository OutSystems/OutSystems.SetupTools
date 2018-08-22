function Install-OSPlatformLicense {
    <#
    .SYNOPSIS
    Installs the OutSystems platform license.

    .DESCRIPTION
    This will install the OutSystems platform license. If a license file is not specified a 30 days trial license will be installed instead.

    .PARAMETER Path
    The path of the license.lic file.

    .EXAMPLE
    Install-OSPlatformLicense -Path c:\temp

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Path
    )

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"

        try {
            CheckRunAsAdmin | Out-Null
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }

        $OSVersion = GetServerVersion

        if (-not $OSVersion) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }

        if ($(GetSCCompiledVersion) -ne $OSVersion) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        if ($Path -and ($Path -ne "")) {
            if ( -not (Test-Path -Path "$Path\license.lic")) {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 3 -Message "License file not found at $Path\license.lic"
                throw "License file not found at $Path\license.lic"
            }
        } else {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "License path not specified. We will install a trial one"
            $Path = $ENV:TEMP

            try {
                DownloadOSSources -URL "$OSRepoURL\license.lic" -SavePath "$Path\license.lic"
                $Path = "$Path\license.lic"
            } catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "Error downloading the license from the repository"
                throw "Error downloading the license from the repository"
            }
        }
    }

    process {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing outsytems license"

        try {
            $Result = RunConfigTool -Arguments $("/UploadLicense " + [char]34 + $Path + [char]34)
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
            throw "Error lauching the configuration tool"
        }

        $ConfToolOutputLog = $($Result.Output) -Split ("`r`n")
        foreach ($Logline in $ConfToolOutputLog) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "CONFTOOL: $Logline"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($Result.ExitCode)"

        if ($Result.ExitCode -ne 0) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error uploading the license. Return code: $($Result.ExitCode)"
            throw "Error uploading the license. Return code: $($Result.ExitCode)"
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "License successfully installed!!"
    }

    end {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
