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
        [Alias('Host', 'Environment')]
        [string[]]$ServiceCenterHost = '127.0.0.0',

        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSTypeName('OutSystems.PlatformServices.CS_Module')]$Module,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred,

        [Parameter()]
        [switch]$CreateNewVersion,

        [Parameter()]
        [switch]$StopOnError,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$StagingName = 'OutSystems_SetupTools_Staging'
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        $SCUser = $Credential.UserName
        $SCPass = $Credential.GetNetworkCredential().Password

        $moduleVersionsToPublish = @()
        foreach ($outdatedModule in $Module)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Getting published version of module $($outdatedModule.Name)"
                $modulePublishedVersion = WSGetModuleVersionPublished -SCHost $ServiceCenterHost -SCUser $SCUser -SCPass $SCPass -ModuleKey $outdatedModule.Key
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting published version of module $($outdatedModule.Name)" -Exception $_.Exception
                WriteNonTerminalError -Message "Error getting published version of module $($outdatedModule.Name)"

                return
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding module $($outdatedModule.Name) to the list"
            $ModulesToPublish = [pscustomobject]@{
                REST_Module        = [pscustomobject]@{
                    Name = $outdatedModule.Name
                    Key  = $outdatedModule.Key
                    Kind = $outdatedModule.Kind
                }
                #REST_ModuleVersion = [pscustomobject]@{
                #    ModuleVersionKey = $modulePublishedVersion.ModuleVersion.ModuleVersionKey
                #}
            }
            $moduleVersionsToPublish += $ModulesToPublish
        }

        if ($moduleVersionsToPublish)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the deployment"
            $publishResponse = WSPublishModules -SCHost $ServiceCenterHost -SCUser $SCUser -SCPass $SCPass -ModulesToPublish $moduleVersionsToPublish -StagingName "Publish_Outdated_Modules"

            # Check deployment status
            try
            {
                $result = GetPublishResult -SCHost $ServiceCenterHost -PublishId $publishResponse.PublishId -Credential $Credential -CallingFunction $($MyInvocation.Mycommand)
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error checking the status of publication id $publishId" -Exception $_.Exception
                WriteNonTerminalError -Message "Error checking the status of publication id $publishId"

                return
            }

            switch ($result)
            {
                1
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution successfully published with warnings!!"
                    return
                }
                2
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error publishing the solution"
                    WriteNonTerminalError -Message "Error publishing the solution"

                    return
                }
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Solution successfully published"
        }

    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
