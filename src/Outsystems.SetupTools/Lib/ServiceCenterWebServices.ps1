
function SCWS_GetPlatformServicesProxy([string]$SCHost)
{
    $platformServicesUri = "http://$SCHost/ServiceCenter/PlatformServices_v8_0_0.asmx?WSDL"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connecting to $platformServicesUri"
    $platformServicesWS = New-WebServiceProxy -Uri $platformServicesUri -ErrorAction Stop -Namespace 'OutSystems.PlatformServices'
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connection successful"

    return $platformServicesWS
}

function SCWS_GetSolutionsProxy([string]$SCHost)
{
    $solutionsUri = "http://$SCHost/ServiceCenter/Solutions.asmx?WSDL"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connecting to $solutionsUri"
    $solutionsWS = New-WebServiceProxy -Uri $solutionsUri -ErrorAction Stop -Namespace 'OutSystems.Solutions'
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connection successful"

    return $solutionsWS
}

function SCWS_GetOutSystemsPlatformProxy([string]$SCHost)
{
    $platformUri = "http://$SCHost/ServiceCenter/OutSystemsPlatform.asmx?WSDL"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connecting to $platformUri"
    $platformWS = New-WebServiceProxy -Uri $platformUri -ErrorAction Stop -Namespace 'OutSystems.Platform'
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connection successful"

    return $platformWS
}

function SCWS_GetPlatformInfo([string]$SCHost, [string]$SCUser, [string]$SCPass)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting platform info from $SCHost"

    $platformWS = SCWS_GetOutSystemsPlatformProxy -SCHost $SCHost
    $result = $($platformWS).GetPlatformInfo($SCUser, $(GetHashedPassword($SCPass)))

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $result"

    return $result
}

function SCWS_Applications_Get([string]$SCHost, [string]$SCUser, [string]$SCPass)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting applications from $SCHost"

    $platformServicesWS = SCWS_GetPlatformServicesProxy -SCHost $SCHost
    $result = $($platformServicesWS).Applications_Get($SCUser, $(GetHashedPassword($SCPass)), $true, $true)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $($result.Count) applications"

    return $result
}

function SCWS_Modules_Get([string]$SCHost, [string]$SCUser, [string]$SCPass)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting modules from $SCHost"

    $platformServicesWS = SCWS_GetPlatformServicesProxy -SCHost $SCHost
    $result = $($platformServicesWS).Modules_Get($SCUser, $(GetHashedPassword($SCPass)))

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $($result.Count) modules"

    return $result
}

function SCWS_Module_GetVersions([string]$SCHost, [string]$SCUser, [string]$SCPass, [string]$ModuleKey)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting modules versions of module key $ModuleKey"

    $errorCode = 0
    $errorMessage = ""
    $publishedVersion = 0

    $platformServicesWS = SCWS_GetPlatformServicesProxy -SCHost $SCHost
    $result = $($platformServicesWS).Module_GetVersions($SCUser, $(GetHashedPassword($SCPass)), $ModuleKey, [ref]$publishedVersion, [ref]$errorCode, [ref]$errorMessage)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning $($result.Count) module versions"

    $returnResult = [pscustomobject]@{
        ErrorCode        = $errorCode
        ErrorMessage     = $errorMessage
        PublishedVersion = $publishedVersion
        ModuleVersions   = $result
    }

    return $returnResult
}

function SCWS_Staging_PublishWith2StepOption([string]$SCHost, [string]$SCUser, [string]$SCPass, [object[]]$ModulesToPublish, [object[]]$ApplicationsToUpdate, [string]$StagingName, [bool]$TwoStepMode)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publishing $($ModulesToPublish.Count) modules"

    $uri = "http://$SCHost/ServiceCenter/rest/PlatformServices/Staging_PublishWith2StepOption?StagingName=$StagingName&TwoStepMode=$TwoStepMode"
    $body = [pscustomobject]@{
        ModulesToPublish     = $ModulesToPublish
        ApplicationsToUpdate = $ApplicationsToUpdate
    } | ConvertTo-Json -Depth 20

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SCUser, $(GetHashedPassword($SCPass)))))

    $result = Invoke-RestMethod -Uri $uri -Headers @{Authorization = "Basic $base64AuthInfo" } -Method POST -ContentType "application/json" -Body $body -Verbose:$false

    return $result
}

function SCWS_SolutionPack_PublishWith2StepOption([string]$SCHost, [string]$SCUser, [string]$SCPass, [Byte[]]$Solution, [bool]$TwoStepMode)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Publishing solution to $SCHost"

    $publishId = 0

    $platformServicesWS = SCWS_GetPlatformServicesProxy -SCHost $SCHost
    $result = $($platformServicesWS).SolutionPack_PublishWith2StepOption($SCUser, $(GetHashedPassword($SCPass)), $Solution, $TwoStepMode, [ref]$publishId)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning publishing id $publishId"

    $returnResult = [pscustomobject]@{
        PublishId = $publishId
        Messages  = $result
    }

    return $returnResult
}

function SCWS_SolutionPack_GetPublicationMessages([string]$SCHost, [string]$SCUser, [string]$SCPass, [int]$PublishId, [int]$AfterMessageId)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting messages from publishing id $PublishId"

    $lastMessageId = 0
    $finished = $false

    $platformServicesWS = SCWS_GetPlatformServicesProxy -SCHost $SCHost
    $result = $($platformServicesWS).SolutionPack_GetPublishMessages($SCUser, $(GetHashedPassword($SCPass)), $PublishId, $AfterMessageId, [ref]$lastMessageId, [ref]$finished)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning messages"

    $returnResult = [pscustomobject]@{
        Finished      = [bool]$finished
        LastMessageId = $lastMessageId
        Messages      = $result
    }

    return $returnResult
}

function SCWS_SolutionPack_PublishContinue([string]$SCHost, [string]$SCUser, [string]$SCPass, [int]$PublishId)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Continuing publish id $PublishId on $SCHost"

    $platformServicesWS = SCWS_GetPlatformServicesProxy -SCHost $SCHost
    $null = $($platformServicesWS).SolutionPack_PublishContinue($SCUser, $(GetHashedPassword($SCPass)), $PublishId)
}

function WSSC_SolutionPack_PublishAbort([string]$SCHost, [string]$SCUser, [string]$SCPass, [int]$PublishId)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Stopping publish id $PublishId on $SCHost"

    $platformServicesWS = SCWS_GetPlatformServicesProxy -SCHost $SCHost
    $null = $($platformServicesWS).SolutionPack_PublishAbort($SCUser, $(GetHashedPassword($SCPass)), $PublishId)
}


#>###########
Function WSGetModuleVersionPublished([string]$SCHost, [string]$SCUser, [string]$SCPass, [string]$ModuleKey)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Getting module published version of module key $ModuleKey"

    $errorCode = 0
    $errorMessage = ""
    $publishedVersion = 0

    $platformServicesWS = GetPlatformServicesWS -SCHost $SCHost
    $result = $($platformServicesWS).Module_GetVersions($SCUser, $(GetHashedPassword($SCPass)), $ModuleKey, [ref]$publishedVersion, [ref]$errorCode, [ref]$errorMessage)

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Returning module version $publishedVersion"

    $returnResult = [pscustomobject]@{
        ErrorCode     = $errorCode
        ErrorMessage  = $errorMessage
        ModuleVersion = $result | Where-Object -FilterScript { $_.Version -eq $publishedVersion }
    }

    return $returnResult
}
