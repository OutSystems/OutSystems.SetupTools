function Get-OSPlatformVersion {
    <#
    .SYNOPSIS
    Gets the platform version from Service Center.

    .DESCRIPTION
    This will return the Outsystems platform version from Service Center API. Will throw an exception if cannot get the version.

    .PARAMETER Host
    Service Center address. If not specofied will default to localhost (127.0.0.1).

    .EXAMPLE
    Get-OSPlatformVersion -Host "10.0.0.1"

    #>

    [CmdletBinding()]
    [OutputType([System.Version])]
    param(
        [Parameter()]
        [Alias('Host')]
        [string]$ServiceCenterHost = '127.0.0.1'
    )

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        if ( $($ServiceCenterHost.Trim()) -eq "" ) {
            $ServiceCenterHost = "127.0.0.1"
        }
    }

    process {
        try {
            $RefDummy = ""
            $Version = $(GetOutSystemsPlatformWS -SCHost $ServiceCenterHost).GetPlatformInfo(([ref]$RefDummy))
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error contacting service center"
            throw "Error contacting service center"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $Version"
        return [System.Version]$Version
    }

    end {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}
