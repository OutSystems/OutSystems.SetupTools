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

    .PARAMETER Credential
    Username or PSCredential object with credentials for Service Center. If not specified defaults to admin/admin

    .EXAMPLE
    $Credential = Get-Credential
    Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -Credential $Credential

    .EXAMPLE
    $password = ConvertTo-SecureString "superpass" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("superuser", $password)
    Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -Credential $Credential

    .NOTES
    You can run this cmdlet on any machine with HTTP access to Service Center.

    #>

    [OutputType('OutSystems.PlatformServices.CS_Application')]
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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Getting applications from $ServiceCenter"
        try
        {
            $applications = AppMgmt_GetApplications -SCHost $ServiceCenter -Credential $Credential
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting applications from $ServiceCenter" -Exception $_.Exception
            WriteNonTerminalError -Message "Error getting applications from $ServiceCenter"

            return $null
        }

        if ($Filter)
        {
            $applications = $applications | Where-Object -FilterScript $Filter
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $($applications.Count) applications from $ServiceCenter"

        if ($applications)
        {
            # If PassThru, we create a custom and add the service center and the credentials to the object to be used in another piped functions
            if ($PassThru.IsPresent)
            {
                return [pscustomobject]@{
                    PSTypeName    = 'Outsystems.SetupTools.Applications'
                    ServiceCenter = $ServiceCenter
                    Credential    = $Credential
                    Applications       = $applications
                }
            }
            else
            {
                return $applications
            }
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
