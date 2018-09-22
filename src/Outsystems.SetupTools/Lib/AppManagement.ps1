

function PublishSolutionAsync([string]$SCHost, [string]$Solution, [pscredential]$Credential)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Solution path: $Solution"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Reading file"
    $solutionFile = [System.IO.File]::ReadAllBytes($Solution)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publishing"
    $publishResult = WSPublishSolutionPack -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass -Solution $solutionFile

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returnig id $($publishResult.publishId)"

    return $publishResult
}

function GetPublishResult([string]$SCHost, [int]$PublishId, [pscredential]$Credential, [string]$CallingFunction)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting publishing results for publication id $PublishId"

    $SCUser = $Credential.UserName
    $SCPass = $Credential.GetNetworkCredential().Password

    $finished = $false
    $lastMessageId = 0

    $resultsCount = [pscustomobject]@{
        Errors       = 0
        Warnings     = 0
    }

    while(-not $finished)
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting publication messages from service center at $SCHost"
        $objMessages = WSGetPublicationMessages -SCHost $SCHost -SCUser $SCUser -SCPass $SCPass -PublishId $PublishId -AfterMessageId $lastMessageId

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Found $($objMessages.Messages.Count)"
        foreach ($message in $objMessages.Messages)
        {
            # Service Center messages will be send as the calling function. This is an exception from the rest of this file
            LogMessage -Function $CallingFunction -Phase 1 -Stream 0 -Message "Service Center: $($message.Message) - $($message.Detail)"
            switch ($message.Type) {
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
            }
        }

        $finished = $objMessages.Finished
        if (-not $objMessages.Finished)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Deployment still running"
            $lastMessageId = $objMessages.LastMessageId
            Start-Sleep -Seconds 1
        }
    }
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Deployment finished"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Errors count: $($resultsCount.Errors)"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Warnings count: $($resultsCount.Warnings)"

    if ($resultsCount.Errors -ne 0)
    {
        $result = 2
    }
    elseif ($resultsCount.Warnings -ne 0)
    {
        $result = 1
    }
    else
    {
        $result = 0
    }

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returnig $result"

    return $result
}
