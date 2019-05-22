function Publish-OSPTool-Solution
{
    <#
    .SYNOPSIS
    Deploys a solution pack

    .DESCRIPTION
    This will deploy a solution pack to an OutSystems environment
    The cmdlet checks for compilation errors and will stop the deployment on any if the Wait switch is specified

    .PARAMETER ServiceCenter
    Service Center hostname or IP. If not specified, defaults to localhost.

    .PARAMETER Solution
    Solution file. This can be an OSP or an OAP file.

    .PARAMETER Credential
    Username or PSCredential object with credentials for Service Center. If not specified defaults to admin/admin

    .PARAMETER Wait
    Will waits for the deployment to finish and reports back the deployment result

    .PARAMETER StopOnWarnings
    Treat warnings as errors. Deployment will stop on compilation warnings and return success false

    .EXAMPLE
    $Credential = Get-Credential
    Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential

    .EXAMPLE
    $password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
    Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential -Wait

    .EXAMPLE
    $Credential = Get-Credential
    Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential -StopOnWarnings

    .NOTES
    You can run this cmdlet on any machine with HTTP access to Service Center.

    The cmdlet will return an object with an ExitCode property that will match one of the following values:
    -1 = Error while trying to publish the solution
    0  = Success
    1  = Solution published with warnings
    2  = Solution published with errors

    This cmdlet does not check the integrity of the solution pack before starting.
    Trusts on the Service Center to make all the checks.

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.PublishResult')]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Host', 'Environment','ServiceCenterHost')]
        [string]$ServiceCenter = '127.0.0.1',

        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Solution,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [Parameter(ParameterSetName = 'PSCred')]
        [switch]$Force,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceCenterUser = $OSSCUser,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceCenterPass = $OSSCPass,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred,

        [Parameter()]
        [switch]$Wait,

        [Parameter()]
        [switch]$StopOnWarnings
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $publishResult = [pscustomobject]@{
            PSTypeName = 'Outsystems.SetupTools.PublishResult'
            PublishId  = 0
            Errors     = 0
            Warnings   = 0
            Success    = $true
            ExitCode   = 0
            Message    = ''
        }
    }

    process
    {

        if ($(-not $osVersion) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Outsystems platform is not installed'

            return $installResult
        }

        if ($(GetSCCompiledVersion) -ne $osVersion)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            WriteNonTerminalError -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first'

            return $installResult
        }

        if ( $(GetSysComponentsCompiledVersion) -ne $osVersion )
        {
            $doInstall = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "The solution were already compiled with this server version"
        }

        if ($doInstall -or $Force.IsPresent)
        {
            if ( $Force.IsPresent )
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. Will be reinstalled!!"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems solution. This can take a while..."
            try
            {
                $result = PublishSolution -Solution $solution -SCUser $ServiceCenterUser -SCPass $ServiceCenterPass
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the solution installion"
                WriteNonTerminalError -Message "Error lauching the solution installion"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error lauching the solution installion'

                return $installResult
            }

            $outputLog = $($result.Output) -Split ("`r`n")
            foreach ($logline in $outputLog)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTOOL: $logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTool exit code: $($result.ExitCode)"

            if ( $result.ExitCode -ne 0 )
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing the solution. Return code: $($result.ExitCode)"
                WriteNonTerminalError -Message "Error installing the solution. Return code: $($result.ExitCode)"

                $installResult.Success = $false
                $installResult.ExitCode = $result.ExitCode
                $installResult.Message = 'Error installing the solution'

                return $installResult
            }

            try {
                SetSysComponentsCompiledVersion -SysComponentsVersion $osVersion
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the solution version"
                WriteNonTerminalError -Message "Error setting the solution version"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error setting the solution version'

                return $installResult
            }
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution successfully installed!!"
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}
