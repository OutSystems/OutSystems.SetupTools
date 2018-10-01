function Publish-OSPlatformModule
{
    <#
    .SYNOPSIS
    Creates and publish an OutSystems solution with all modules that are outdated.

    .DESCRIPTION
    This will create and publish an OutSystems solution with all modules that are outdated.

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

    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Host', 'Environment', 'ServiceCenterHost')]
        [string]$ServiceCenter = '127.0.0.1',

        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSTypeName('OutSystems.PlatformServices.CS_Module')]$Modules,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred,

        [Parameter()]
        [switch]$Wait,

        [Parameter()]
        [switch]$StopOnWarning,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$StagingName = 'OutSystems_SetupTools_Staging'
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
        if (-not $Modules)
        {
            $publishResult.Success = $true
            $publishResult.PublishId = 0
            $publishResult.ExitCode = 0
            $publishResult.Message = "No modules to publish"

            return $publishResult
        }

        #region start publish step 1
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Publishing $($Modules.Count) modules to $ServiceCenter"
        try
        {
            $publishAsyncResult = AppMgmt_ModulesPublish -SCHost $ServiceCenter -Modules $Modules -Credential $Credential -StagingName $StagingName -TwoStepMode $Wait -CallingFunction $($MyInvocation.Mycommand)
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error while starting to compile the modules" -Exception $_.Exception
            WriteNonTerminalError -Message "Error while starting to compile the modules"

            $publishResult.Success = $false
            $publishResult.PublishId = 0
            $publishResult.ExitCode = -1
            $publishResult.Message = "Error while starting to compile the modules"

            return $publishResult
        }

        # Here we have the publish id
        $publishId = $publishAsyncResult.publishId

        # If wait switch is not specified just return the publish id and exit
        if (-not $Wait.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Compilation started on the deployment controller"

            $publishResult.Success = $true
            $publishResult.PublishId = $publishId
            $publishResult.Message = "Compilation started on the deployment controller"

            return $publishResult
        }
        #endregion

        #region get step 1 publish results
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the compilation of the modules ( Publish Id: $publishId )"

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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Found $($publishResult.Errors) errors and $($publishResult.Warnings) warnings while compiling the modules"

        if ($result.Errors -gt 0)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Errors found while compiling the modules"
            WriteNonTerminalError -Message "Errors found while compiling the modules"

            # Delete the staging. Dont care with the results for now
            AppMgmt_SolutionPublishStop -SCHost $ServiceCenter -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 2
            $publishResult.Message = "Errors found while compiling the modules"

            return $publishResult
        }

        if ($($result.Warnings -gt 0) -and $StopOnWarnings.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Warnings found while compiling the modules"
            WriteNonTerminalError -Message "Warnings found while compiling the modules"

            # Delete the staging. Dont care with the results for now
            AppMgmt_SolutionPublishStop -SCHost $ServiceCenter -PublishId $publishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 2
            $publishResult.Message = "Warnings found while compiling the modules"

            return $publishResult
        }
        #endregion

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
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error publishing the modules"
            WriteNonTerminalError -Message "Error publishing the modules"

            $publishResult.Success = $false
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 2
            $publishResult.Message = "Error publishing the modules"

            return $publishResult
        }

        if ($result.Warnings -gt 0)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Modules successfully published with warnings!!"

            if ($StopOnWarnings.IsPresent)
            {
                WriteNonTerminalError -Message "Modules successfully published with warnings!!"
                $publishResult.Success = $false
            }
            else
            {
                $publishResult.Success = $true
            }
            $publishResult.PublishId = $publishId
            $publishResult.ExitCode = 1
            $publishResult.Message = "Modules successfully published with warnings!!"

            return $publishResult
        }
        #endregion


        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Modules successfully published"
        $publishResult.Message = "Modules successfully published"
        $publishResult.PublishId = $publishId

        return $publishResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
