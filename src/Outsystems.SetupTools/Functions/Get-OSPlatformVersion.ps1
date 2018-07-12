Function Get-OSPlatformVersion {
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
    Param(
        [Parameter()]
        [string]$Host = "127.0.0.1"
    )

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        If( $($Host.Trim()) -eq "" ) { $Host = "127.0.0.1" }
    }

    Process {
        Try {
            $ServiceProxy = New-WebServiceProxy -Uri "http://$Host/ServiceCenter/OutSystemsPlatform.asmx?wsdl" -Namespace Outsystems -ErrorAction Stop
            $RefDummy = ""
            $Version = $ServiceProxy.GetPlatformInfo(([ref]$RefDummy))
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error contacting service center"
            Throw "Error contacting service center"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $Version"
        Return [System.Version]$Version
    }

    End {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}