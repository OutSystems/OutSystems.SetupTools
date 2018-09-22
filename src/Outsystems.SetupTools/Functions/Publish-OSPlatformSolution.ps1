function Publish-OSPlatformSolution
{
    <#
    .SYNOPSIS
    Deploys a solution pack

    .DESCRIPTION
    This will deploy a solution pack to an OutSystems environment.

    .PARAMETER ServiceCenterHost
    Service Center hostname or IP. If not specified, defaults to localhost.

    .PARAMETER Solution
    Solution file. This can be an OSP or an OAP file.

    .PARAMETER Credential
    Username or PSCredential object with credentials for Service Center. If not specified defaults to admin/admin

    .PARAMETER Wait
    Will waits for the deployment to finish and reports back the deployment result.

    .EXAMPLE
    $Credential = Get-Credential
    Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential

    .EXAMPLE
    $password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
    Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential -Wait

    .NOTES
    You can run this cmdlet on any machine with HTTP access to Service Center.

    This will return an object with an ExitCode property.
    -1 = Error while trying to publish the solution
    0  = Success
    1  = Solution published with warnings
    2  = Failed

    This cmdlet does not check the integrity of the solution pack.

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.PublishResult')]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Host', 'Environment')]
        [string]$ServiceCenterHost = '127.0.0.1',

        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Solution,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred,

        [Parameter()]
        [switch]$Wait
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $publishResult = [pscustomobject]@{
            PSTypeName = 'Outsystems.SetupTools.PublishResult'
            PublishId  = 0
            Success    = $true
            ExitCode   = 0
            Message    = ''
        }
    }

    process
    {
        $publishId = 0

        # Check if file exists
        if (-not (Test-Path -Path $Solution))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Cant find the solution file $Solution"
            WriteNonTerminalError -Message "Cant find the solution file $Solution"

            $publishResult.Success = $false
            $publishResult.ExitCode = -1
            $publishResult.Message = "Cant find the solution file $Solution"

            return $publishResult
        }

        # Check if file is OSP or OAP

        # Start deployment
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Publishing solution $Solution"
        try
        {
            $publishAsyncResult = PublishSolutionAsync -SCHost $ServiceCenterHost -Solution $Solution -Credential $Credential
            $publishId = $publishAsyncResult.publishId
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error while trying to publish the solution $Solution" -Exception $_.Exception
            WriteNonTerminalError -Message "Error while trying to publish the solution $Solution"

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error while trying to publish the solution $Solution"

            return $publishResult
        }

        # Check if publishId is valid
        if (-not $publishId -or ($publishId -eq 0))
        {
            # Get error message from Service Center
            if ($publishAsyncResult.Messages)
            {
                foreach ($publishMessage in $publishAsyncResult.Messages)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service Center: $($publishMessage.Message) - $($publishMessage.Detail)"
                }
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error while trying to publish the solution $Solution"
            WriteNonTerminalError -Message "Error while trying to publish the solution $Solution"

            $publishResult.Success = $false
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error while trying to publish the solution $Solution"

            return $publishResult
        }

        # If wait switch is not specified just return the publish id
        if (-not $Wait.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Deployment successfully started"

            $publishResult.Success = $true
            $publishResult.PublishId = $publishId
            $publishResult.Message = "Deployment successfully started"

            return $publishResult
        }

        # Check deployment status
        try
        {
            $result = GetPublishResult -SCHost $ServiceCenterHost -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error checking the status of publication id $($publishAsyncResult.publishId)" -Exception $_.Exception
            WriteNonTerminalError -Message "Error checking the status of publication id $publishId"

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error checking the status of publication id $publishId"

            return $publishResult
        }

        switch ($result)
        {
            1
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution successfully published with warnings!!"
                $publishResult.PublishId = $publishId
                $publishResult.ExitCode = $result
                $publishResult.Message = "Solution successfully published with warnings!!"

                return $publishResult
            }
            2
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error publishing the solution"
                WriteNonTerminalError -Message "Error publishing the solution"

                $publishResult.Success = $false
                $publishResult.PublishId = $publishId
                $publishResult.ExitCode = $result
                $publishResult.Message = "Error publishing the solution"

                return $publishResult
            }
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution successfully published"
        $publishResult.Message = "Solution successfully published"
        $publishResult.PublishId = $publishId

        return $publishResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}
