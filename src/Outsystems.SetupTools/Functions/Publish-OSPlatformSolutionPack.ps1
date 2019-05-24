function Publish-OSPlatformSolutionPack
{
    <#
    .SYNOPSIS
    Deploys a solution pack

    .DESCRIPTION
    This will deploy a solution pack to an OutSystems environment
    It will not stop on any error. It proceeds till the end and outputs all errors found during the deployment.

    .PARAMETER Solution
    Solution path. This can be an OSP or an OAP file.

    .PARAMETER Credential
    Username or PSCredential object with credentials for Service Center. If not specified defaults to admin/admin

    .EXAMPLE
    $Credential = Get-Credential
    Publish-OSPlatformSolutionPack -Solution 'c:\solution.osp' -Credential $Credential

    .EXAMPLE
    $password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
    Publish-OSPlatformSolutionPack -Solution 'c:\solution.osp' -Credential $Credential

    .NOTES
    This script has to be executed locally on the server in which you wish to publish to. This environment needs to have the osptool present

    The cmdlet will return an object with an ExitCode property that will match one of the following values:
    -1 = Error while trying to publish the solution
    0  = Success
    1  = Solution published with warnings
    2  = Solution published with errors

    This cmdlet does not check the integrity of the solution pack before starting.
    Trusts on the Service Center to make all the checks.

    #>

    [CmdletBinding(DefaultParameterSetName = 'PSCred')]
    [OutputType('Outsystems.SetupTools.PublishResult')]
    param (

        [ValidateNotNullOrEmpty()]
        [string]$Solution,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceCenterUser = $OSSCUser,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceCenterPass = $OSSCPass,

        [Parameter(ParameterSetName = 'PSCred')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $publishResult = [pscustomobject]@{
            PSTypeName = 'Outsystems.SetupTools.PublishResult'
            Success    = $true
            ExitCode   = 0
            Message    = 'Solution successfully installed'
        }
        $osVersion = GetServerVersion
        $osInstallDir = GetServerInstallDir

        switch ($PsCmdlet.ParameterSetName)
        {
            "PSCred"
            {
                $ServiceCenterUser = $Credential.UserName
                $ServiceCenterPass = $Credential.GetNetworkCredential().Password
            }
        }
    }

    process
    {
        if ($(-not $osVersion) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            $publishResult.Success = $false
            $publishResult.ExitCode = -1
            $publishResult.Message = 'Outsystems platform is not installed'

            return $publishResult
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems solution. This can take a while..."
        try
        {
            $result = PublishSolution -Solution $solution -SCUser $ServiceCenterUser -SCPass $ServiceCenterPass
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the solution installation"
            WriteNonTerminalError -Message "Error lauching the solution installation"

            $publishResult.Success = $false
            $publishResult.ExitCode = -1
            $publishResult.Message = 'Error lauching the solution installation'

            return $publishResult
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

            $publishResult.Success = $false
            $publishResult.ExitCode = $result.ExitCode
            $publishResult.Message = 'Error installing the solution'

            return $publishResult
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution successfully installed!!"
        return $publishResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}
