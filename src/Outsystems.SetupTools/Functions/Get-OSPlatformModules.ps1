Function Get-OSPlatformModules
{
    <#
    .SYNOPSIS
    Returns the list of modules installed on an Outsystems environment.

    .DESCRIPTION
    This will return the list of modules (espaces and extensions) installed on an Outsystems environment.
    The function can be used to query a remote Outsystems environment for the list of modules installed using the ServiceCenterHost parameter.
    If not specified, the function will query the local machine.

    .PARAMETER ServiceCenterHost
    Service Center hostname or IP. If not specified, defaults to localhost.

    .PARAMETER Credential
    Username or PSCredential object with credentials for Service Center. If not specified defaults to admin/admin

    .EXAMPLE
    $Credential = Get-Credential
    Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -Credential $Credential

    .EXAMPLE
    $password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
    Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -Credential $Credential

    .NOTES
    You can run this cmdlet on any machine with HTTP access to Service Center.

    #>

    [OutputType([object[]])]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('Host', 'Environment')]
        [string[]]$ServiceCenterHost = '127.0.0.1',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $SCUser = $Credential.UserName
        $SCPass = $Credential.GetNetworkCredential().Password
    }

    process
    {
        foreach ($SCHost in $ServiceCenterHost)
        {
            try
            {
                $result = WSGetModules -SCHost $SCHost -SCUser $Credential.UserName -SCPass $Credential.GetNetworkCredential().Password

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $($result.Count) applications from $SCHost"
                return $result
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting applications from $SCHost" -Exception $_.Exception
                WriteNonTerminalError -Message "Error getting applications from $SCHost"
            }
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
