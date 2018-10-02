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

    .PARAMETER PassThru
    If spedified returns the list of modules grouped by environment. Also returns the ServiceCenter and the Credentials parameters
    Useful for the Publish-OSPlatformModules function

    .PARAMETER Filter
    Filter script

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

    [OutputType('OutSystems.PlatformServices.CS_Module')]
    [OutputType('OutSystems.PlatformServices.Modules', ParameterSetName = "PassThru")]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Host', 'Environment', 'ServiceCenterHost')]
        [string]$ServiceCenter = '127.0.0.1',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred,

        [Parameter()]
        [scriptblock]$Filter,

        [Parameter(ParameterSetName = 'PassThru')]
        [switch]$PassThru
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Getting modules from $ServiceCenter"
        try
        {
            $modules = AppMgmt_GetModules -SCHost $ServiceCenter -Credential $Credential
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting modules from $ServiceCenter" -Exception $_.Exception
            WriteNonTerminalError -Message "Error getting modules from $ServiceCenter"

            return $null
        }

        if ($Filter)
        {
            $modules = $modules | Where-Object -FilterScript $Filter
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $($modules.Count) modules from $ServiceCenter"

        if ($modules)
        {
            # If PassThru, we create a custom and add the service center and the credentials to the object to be used in another piped functions
            if ($PassThru.IsPresent)
            {
                return [pscustomobject]@{
                    PSTypeName    = 'Outsystems.SetupTools.Modules'
                    ServiceCenter = $ServiceCenter
                    Credential    = $Credential
                    Modules       = $modules
                }
            }
            else
            {
                return $modules
            }
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
