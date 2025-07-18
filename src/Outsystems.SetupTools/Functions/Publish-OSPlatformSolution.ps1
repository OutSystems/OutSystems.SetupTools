function Publish-OSPlatformSolution
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
    Will wait for the deployment to finish and reports back the deployment result

    .PARAMETER StopOnWarnings
    Treat warnings as errors. Deployment will stop on compilation warnings and return success false

    .PARAMETER UseTwoStepMode
    Enable 2-Stage Deployment of solution. First step compiles and prepares apps, second step deploys.

    .PARAMETER StartSecondStep
    Automatically start second step of solution publish to deploy apps. Requires the UseTwoStepMode parameter.

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

    .EXAMPLE
    $Credential = Get-Credential
    Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential -Wait -UseTwoStepMode

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

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType('Outsystems.SetupTools.PublishResult')]
    param (
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "TwoStep")]
        [ValidateNotNullOrEmpty()]
        [Alias('Host', 'Environment','ServiceCenterHost')]
        [string]$ServiceCenter = '127.0.0.1',

        [Parameter(ParameterSetName = "Default", ValueFromPipeline)]
        [Parameter(ParameterSetName = "TwoStep", ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Solution,

        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "TwoStep")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred,

        [Parameter(ParameterSetName = "TwoStep")]
        [Parameter(ParameterSetName = "Default")]
        [switch]$Wait,

        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "TwoStep")]
        [switch]$StopOnWarnings,

        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "TwoStep", Mandatory = $true)]
        [switch]$UseTwoStepMode,

        [Parameter(ParameterSetName = "TwoStep")]
        [switch]$StartSecondStep
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
        #region pre-checks

        # Check if file exists
        if (-not (Test-Path -Path $Solution))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Cant find the solution file $Solution"
            WriteNonTerminalError -Phase 1 -Stream 3 -Message "Cant find the solution file $Solution"

            $publishResult.Success = $false
            $publishResult.ExitCode = -1
            $publishResult.Message = "Cant find the solution file $Solution"

            return $publishResult
        }

        # Check if StartSecondStep switch was enabled but UseTwoStepMode was not
        if ( ($StartSecondStep -eq $true) -and ($UseTwoStepMode -eq $false) ) 
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error in parameters provided. StartSecondStep enabled requires that UseTwoStepMode is also enabled" -Exception $_.Exception
            WriteNonTerminalError -Message "Error in parameters provided"

            $publishResult.Success = $false
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error in parameters provided"

            return $publishResult
        }
        #endregion

        #region start publish step 1
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Uploading solution $Solution"
        try
        {
            $publishAsyncResult = AppMgmt_SolutionPublish -SCHost $ServiceCenter -Solution $Solution -Credential $Credential -TwoStepMode $UseTwoStepMode -CallingFunction $($MyInvocation.Mycommand)
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error while starting to compile the solution" -Exception $_.Exception
            WriteNonTerminalError -Message "Error while starting to compile the solution"

            $publishResult.Success = $false
            $publishResult.PublishId = 0
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error while starting to compile the solution"

            return $publishResult
        }

        # Here we have the publish id
        $publishId = $publishAsyncResult.publishId

        # If wait switch is not specified just return the publish id and exit
        if (-not $Wait.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution publishing successfully uploaded. Compilation started on the deployment controller"

            $publishResult.Success = $true
            $publishResult.PublishId = $publishId
            $publishResult.Message = "Solution successfully uploaded. Compilation started on the deployment controller"

            return $publishResult
        }
        #endregion

        #region get step 1 publish results
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the compilation of the solution ( Publish Id: $publishId )"

        try
        {
            $result = AppMgmt_GetPublishResults -SCHost $ServiceCenter -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error checking the publication status ( Publish Id: $publishId )" -Exception $_.Exception
            WriteNonTerminalError -Message "Error checking the publication status ( Publish Id: $publishId )"

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error checking the publication status"

            return $publishResult
        }

        # Process results of step 1
        $publishResult.Warnings = $result.Warnings
        $publishResult.Errors = $result.Errors
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Found $($publishResult.Errors) errors and $($publishResult.Warnings) warnings while compiling the solution"

        if ($result.Errors -gt 0)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Errors found while compiling the solution"
            WriteNonTerminalError -Message "Errors found while compiling the solution"

            # Delete the staging. Dont care with the results for now
            AppMgmt_SolutionPublishStop -SCHost $ServiceCenter -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 2
            $publishResult.Message = "Errors found while compiling the solution"

            return $publishResult
        }

        if ($($result.Warnings -gt 0) -and $StopOnWarnings.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Warnings found while compiling the solution"
            WriteNonTerminalError -Message "Warnings found while compiling the solution"

            # Delete the staging. Dont care with the results for now
            AppMgmt_SolutionPublishStop -SCHost $ServiceCenter -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 2
            $publishResult.Message = "Warnings found while compiling the solution"

            return $publishResult
        }
        #endregion
        
        #region handle two step publishing enabled
        if ( ($UseTwoStepMode.IsPresent -eq $true) -and ($StartSecondStep.IsPresent -eq $false) ) {

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "First step of solution publish successfully completed. Will wait for second step to be be started in Service Center to finish deployment"
            $publishResult.Message = "First step of solution publish successfully completed. Will wait for second step to be be started in Service Center to finish deployment."
            $publishResult.PublishId = $publishId

            return $publishResult

        }

        elseif ( ($UseTwoStepMode.IsPresent -eq $true) -and ($StartSecondStep.IsPresent -eq $true) ) {

            #region start publish step 2
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Continuing to the deployment..."
            try
            {
                AppMgmt_SolutionPublishContinue -SCHost $ServiceCenter -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error while starting to deploy the solution" -Exception $_.Exception
                WriteNonTerminalError -Message "Error while starting to deploy the solution"

                $publishResult.Success = $false
                $publishResult.PublishId = $publishId
                $publishResult.ExitCode = -1
                $publishResult.Message = "Error while starting to deploy the solution"

                return $publishResult
            }
            #endregion

        }
        #endregion

        #region get step 2 publish results
        try
        {
            $result = AppMgmt_GetPublishResults -SCHost $ServiceCenter -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand) -AfterMessageId $result.LastMessageId
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error checking the publication status ( Publish Id: $publishId )"  -Exception $_.Exception
            WriteNonTerminalError -Message "Error checking the publication status ( Publish Id: $publishId )"

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error checking the publication status"

            return $publishResult
        }

        $publishResult.Warnings += $result.Warnings
        $publishResult.Errors += $result.Errors
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Found a total of $($result.Errors) errors and $($result.Warnings) warnings after the deployment"

        if ($result.Errors -gt 0)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error publishing the solution"
            WriteNonTerminalError -Message "Error publishing the solution"

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 2
            $publishResult.Message = "Error publishing the solution"

            return $publishResult
        }

        if ($result.Warnings -gt 0)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Solution successfully published with warnings!!"

            if ($StopOnWarnings.IsPresent)
            {
                WriteNonTerminalError -Message "Solution successfully published with warnings!!"
                $publishResult.Success = $false
            }
            else
            {
                $publishResult.Success = $true
            }
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 1
            $publishResult.Message = "Solution successfully published with warnings!!"

            return $publishResult
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution successfully published"
        $publishResult.Message = "Solution successfully published"
        $publishResult.PublishId = $publishId

        return $publishResult

        #endregion

    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}
