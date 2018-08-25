function New-OSPlatformFullFactorySolution
{
    <#
    .SYNOPSIS
    Creates a factory solution with all the apps and modules.

    .DESCRIPTION
    Create a solution with all applications and modules in the factory.
    Systems applications and modules are excluded for this solution like 'Lifetime', 'OutsystemsNow', 'System Components'

    To be able to use this function, you need to set the parameter EnableCloudServicesAPI to True on the OutSystems database.

    .PARAMETER ServiceCenterHost
    Service Center hostname or IP. If not specified, localhost will be used.

    .PARAMETER Credential
    Username or PSCredential object. When you submit the command, you will be prompted for a password.
    If you do not specify credentials, the default OutSystems credentials will be used.

    .EXAMPLE
    $Credential = Get-Credential
    New-OSPlatformFullFactorySolution -ServiceCenterHost "8.8.8.8" -Credential $Credential

    $password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
    New-OSPlatformFullFactorySolution -ServiceCenterHost "8.8.8.8" -Credential $Credential

    .NOTES
    Supports both local and remote systems.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    # [OutputType([Integer],[Object])] TO BE DONE!!
    param (
        [Parameter()]
        [ValidateNotNull()]
        [string]$ServiceCenterHost = '127.0.0.1',

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$SolutionName,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter()]
        [Switch]$PassThru
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    process
    {
        if ($Credential)
        {
            $ServiceCenterUser = $Credential.UserName
            $ServiceCenterPass = $Credential.GetNetworkCredential().Password
        }
        else
        {
            $ServiceCenterUser = $OSSCUser
            $ServiceCenterPass = $OSSCPass
        }

        try
        {
            $SolutionId = $(GetSolutionsWS -SCHost $ServiceCenterHost).CreateAllSolution($SolutionName, $ServiceCenterUser, $(GetHashedPassword($ServiceCenterPass)))
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error creating the solution. Check in the OutSystems database if you have EnableCloudServicesAPI=True on the ossys.parameter table" -Exception $_.Exception
            throw "Error creating the solution. Check in the OutSystems database if you have EnableCloudServicesAPI=True on the ossys.parameter table"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Created solution '$SolutionName' with id $SolutionId"

        if ($PassThru.IsPresent)
        {
            $objResult = [PSCustomObject]@{
                'SolutionId'        = $SolutionId;
                'SolutionName'      = $SolutionName;
                'ServiceCenterHost' = $ServiceCenterHost;
                'Credential'        = $Credential;
            }
            return $objResult
        }
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
