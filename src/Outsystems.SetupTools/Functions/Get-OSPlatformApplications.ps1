Function Get-OSPlatformApplications {
    <#
    .SYNOPSIS
    Returns the list of applications installed on an Outsystems environment.

    .DESCRIPTION
    This will return the list of applications installed on an Outsystems environment.
    The function can be used to query a remote Outsystems environment for the list of applications installed using the ServiceCenterHost parameter.
    If not specified, the function will query the local machine.

    .PARAMETER ServiceCenterHost
    Service Center hostname or IP. If not specified, defaults to localhost.

    .PARAMETER ServiceCenterUser
    Service Center username. If not specified, defaults to admin

    .PARAMETER ServiceCenterPass
    Service Center password. If not specified, defaults to admin

    .EXAMPLE
    Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -ServiceCenterUser "admin" -ServiceenterPass "mypass"

    #>

    [CmdletBinding()]
    [OutputType([System.Array])]
    param (
        [Parameter()]
        [string]$ServiceCenterHost = '127.0.0.1',

        [Parameter()]
        [string]$ServiceCenterUser = $OSSCUser,

        [Parameter()]
        [string]$ServiceCenterPass = $OSSCPass
    )

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    Process {
        Try{
            $PlatformServicesProxy = GetPlatformServicesWS -SCHost $ServiceCenterHost
            $Result = $PlatformServicesProxy.Applications_Get($ServiceCenterUser, $(GetHashedPassword($ServiceCenterPass)) ,$true,$true)
        } Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting applications" -Exception $_.Exception
            Throw "Error getting applications"
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $($Result.Count) applications"
        Return $Result
    }

    End {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}