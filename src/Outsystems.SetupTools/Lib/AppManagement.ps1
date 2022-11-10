

function AppMgmt_SolutionPublish([string]$SCHost, [string]$Solution, [pscredential]$Credential, [bool]$TwoStepMode, [string]$CallingFunction)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Solution path: $Solution"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password
    $publishId = 0

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Reading file"
    $solutionFile = [System.IO.File]::ReadAllBytes($Solution)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publishing"
    $publishResult = SCWS_SolutionPack_PublishWith2StepOption -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass -Solution $solutionFile -TwoStepMode $TwoStepMode

    $publishId = $publishResult.publishId

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publish id is: $publishId"

    # Check if publishId is valid
    if (-not $publishId -or ($publishId -eq 0))
    {
        # If pubid is not valid, get error message from Service Center and output them to the verbose stream
        if ($publishResult.Messages)
        {
            foreach ($publishMessage in $publishResult.Messages)
            {
                # Service Center messages will be send as the calling function
                LogMessage -Function $CallingFunction -Phase 1 -Stream 0 -Message "Service Center: $($publishMessage.Message) - $($publishMessage.Detail)"
            }
        }

        # Throw an exception to the calling function
        throw "Error while trying to publish the solution $Solution"
    }

    return $publishResult
}

function AppMgmt_GetPublishResults([string]$SCHost, [int]$PublishId, [pscredential]$Credential, [string]$CallingFunction, [int]$AfterMessageId = 0)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting publishing results for publish id $PublishId"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password

    $finished = $false

    $resultsCount = [pscustomobject]@{
        Errors        = 0
        Warnings      = 0
        LastMessageId = $AfterMessageId
    }

    while (-not $finished)
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting publication messages from service center at $SCHost"
        $objMessages = SCWS_SolutionPack_GetPublicationMessages -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass -PublishId $PublishId -AfterMessageId $resultsCount.LastMessageId

        $finished = $objMessages.Finished

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Found $($objMessages.Messages.Count)"
        foreach ($message in $objMessages.Messages)
        {
            # Service Center messages will be send as the calling function
            LogMessage -Function $CallingFunction -Phase 1 -Stream 0 -Message "Service Center: $($message.Message) - $($message.Detail)"

            # Log the last message id
            $resultsCount.LastMessageId = $objMessages.LastMessageId

            # Gather the results
            switch ($message.Type)
            {
                'Warning'
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Adding warning to results counter"
                    $resultsCount.Warnings ++
                }
                'Error'
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Adding error to results counter"
                    $resultsCount.Errors ++
                }
                'PublishStop'
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publish Step-1 is finished"
                    $finished = $true
                }
            }
        }

        if (-not $finished)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publish is still running"
            Start-Sleep -Seconds 1
        }
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publish finished"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Errors count: $($resultsCount.Errors)"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Warnings count: $($resultsCount.Warnings)"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "LastMessageId: $($resultsCount.LastMessageId)"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning publish results"

    # Return results. The calling function should know what to do with this
    return $resultsCount
}

function AppMgmt_SolutionPublishContinue([string]$SCHost, [int]$PublishId, [pscredential]$Credential)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Continuing publishid $PublishId"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password

    SCWS_SolutionPack_PublishContinue -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass -PublishId $PublishId
}

function AppMgmt_SolutionPublishStop([string]$SCHost, [int]$PublishId, [pscredential]$Credential)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Continuing publishid $PublishId"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password

    WSSC_SolutionPack_PublishAbort -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass -PublishId $PublishId
}

function AppMgmt_GetModules([string]$SCHost, [pscredential]$Credential)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting modules from $SCHost"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password

    $result = SCWS_Modules_Get -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $($result.Count) modules"

    return $result
}

function AppMgmt_GetApplications([string]$SCHost, [pscredential]$Credential)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting modules from $SCHost"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password

    $result = SCWS_Applications_Get -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $($result.Count) modules"

    return $result
}

function AppMgmt_ModulesPublish([string]$SCHost, [object[]]$Modules, [pscredential]$Credential, [string]$StagingName, [bool]$TwoStepMode, [string]$CallingFunction)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publishing $($Modules.Count) modules to $SCHost"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password
    $publishId = 0

    # Init array with modules to publish in the expected format
    $modulesToPublish = @()

    foreach($moduleToPublish in $Modules)
    {
        $moduleObject = [pscustomobject]@{
            REST_Module        = [pscustomobject]@{
                Name = $moduleToPublish.Name
                Key  = $moduleToPublish.Key
                Kind = $moduleToPublish.Kind
            }
        }
        $modulesToPublish += $moduleObject
    }

    $publishResult = SCWS_Staging_PublishWith2StepOption -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass -ModulesToPublish $modulesToPublish -StagingName $StagingName -TwoStepMode $TwoStepMode

    $publishId = $publishResult.publishId
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publish id is: $publishId"

    # Check if publishId is valid
    if (-not $publishId -or ($publishId -eq 0))
    {
        # If pubid is not valid, get error message from Service Center and output them to the verbose stream
        if ($publishResult.Messages)
        {
            foreach ($publishMessage in $publishResult.Messages)
            {
                # Service Center messages will be send as the calling function
                LogMessage -Function $CallingFunction -Phase 1 -Stream 0 -Message "Service Center: $($publishMessage.REST_PublicationMessage.Message) - $($publishMessage.REST_PublicationMessage.Detail)"
            }
        }

        # Throw an exception to the calling function
        throw "Error while trying to publish modules"
    }

    return $publishResult
}
