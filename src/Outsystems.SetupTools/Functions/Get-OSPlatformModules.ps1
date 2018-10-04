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
    If spedified returns the list of modules grouped by environment.
    Also returns the ServiceCenter and the Credentials parameters. Useful for the Publish-OSPlatformModules cmdLet

    .PARAMETER Filter
    Filter script to filter returned modules

    .EXAMPLE
    $Credential = Get-Credential
    Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential $Credential

    .EXAMPLE
    $password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
    Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential $Credential

    .EXAMPLE
    Filter by module name
    Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential $Credential -Filter {$_.Name -eq 'MyModule'}

    .EXAMPLE
    Get all modules with outdated references
    Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential <username> -Filter {$_.StatusMessages.Id -eq 6}

    .EXAMPLE
    Get all modules not published since the last version update
    Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential <username> -Filter {$_.StatusMessages.Id -eq 13}

    .EXAMPLE
    Get modules all the modules from my factory
    @('dev','test','qa','prd') | Get-OSPlatformModules -ServiceCenter -Credential <username>

    .EXAMPLE
    Get all outdated modules from my factory
    @('dev','test','qa','prd') | Get-OSPlatformModules -ServiceCenter -Credential <username> -Filter {$_.StatusMessages.Id -eq 6}

    .NOTES
    You can run this cmdlet on any machine with HTTP access to Service Center.

    #>

    [OutputType('OutSystems.PlatformServices.CS_Module')]
    [OutputType('OutSystems.PlatformServices.ModuleList', ParameterSetName = "PassThru")]
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

        # If not empty after the filter
        if ($modules)
        {
            # If PassThru, we create a custom and add the service center and the credentials to the object to be used in another piped functions
            if ($PassThru.IsPresent)
            {
                return [pscustomobject]@{
                    PSTypeName    = 'Outsystems.SetupTools.ModuleList'
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
