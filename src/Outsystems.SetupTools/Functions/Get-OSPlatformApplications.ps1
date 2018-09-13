function Get-OSPlatformApplications
{
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
    Service Center username. If not specified, defaults to admin.

    .PARAMETER ServiceCenterPass
    Service Center password. If not specified, defaults to admin.

    .PARAMETER Credential
    Username or PSCredential object. When you submit the command, you will be prompted for a password.

    .EXAMPLE
    $Credential = Get-Credential
    Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -Credential $Credential

    $password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
    Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -Credential $Credential

    Unsecure way:
    Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -ServiceCenterUser "admin" -ServiceCenterPass "mypass"

    .NOTES
    Supports both local and remote systems.

    #>

    [CmdletBinding(DefaultParametersetname = 'UserAndPass')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(ParameterSetName = 'UserAndPass', ValueFromPipeline)]
        [Parameter(ParameterSetName = 'PSCred', ValueFromPipeline)]
        [Alias('Host')]
        [string[]]$ServiceCenterHost = '127.0.0.1',

        [Parameter(ParameterSetName = 'UserAndPass')]
        [Alias('User')]
        [string]$ServiceCenterUser = $OSSCUser,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [Alias('Pass','Password')]
        [string]$ServiceCenterPass = $OSSCPass,

        [Parameter(ParameterSetName = 'PSCred')]
        [ValidateNotNull()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        switch ($PsCmdlet.ParameterSetName)
        {
            "PSCred"
            {
                $ServiceCenterUser = $Credential.UserName
                $ServiceCenterPass = $Credential.GetNetworkCredential().Password
            }
        }

        try
        {
            $result = $(GetPlatformServicesWS -SCHost $ServiceCenterHost).Applications_Get($ServiceCenterUser, $(GetHashedPassword($ServiceCenterPass)), $true, $true)
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting applications" -Exception $_.Exception
            throw "Error getting applications"
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $($result.Count) applications"
        return $result
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
