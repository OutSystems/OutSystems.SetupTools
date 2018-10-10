function Set-OSServerConfig
{
    <#
    .SYNOPSIS
    Goal is to replace Invoke-OSConfigurationTool with this cmdlet
    This release only applies the current platform config

    .DESCRIPTION
    Long description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(ParameterSetName = 'ChangeSettings')]
        [string]$Setting,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'ChangeSettings')]
        [string]$Value,

        [Parameter(ParameterSetName = 'Apply')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$PlatformDBCredential,

        [Parameter(ParameterSetName = 'Apply')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$SessionDBCredential,

        [Parameter(ParameterSetName = 'Apply')]
        [switch]$Apply
    )

    dynamicParam
    {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Get the platform major version
        $osVersion = GetServerVersion

        if ($osVersion)
        {
            $osMajorVersion = "$(([version]$osVersion).Major).$(([version]$osVersion).Minor)"

            # Version specific parameters
            switch ($osMajorVersion)
            {
                '11.0'
                {
                    $ConfigureCacheInvalidationServiceAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $ConfigureCacheInvalidationServiceAttrib.ParameterSetName = 'Apply'
                    $ConfigureCacheInvalidationServiceAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $ConfigureCacheInvalidationServiceAttribCollection.Add($ConfigureCacheInvalidationServiceAttrib)
                    $ConfigureCacheInvalidationServiceParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ConfigureCacheInvalidationService', [switch], $ConfigureCacheInvalidationServiceAttribCollection)

                    $LogDBCredentialAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $LogDBCredentialAttrib.ParameterSetName = 'Apply'
                    $LogDBCredentialAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $LogDBCredentialAttribCollection.Add($LogDBCredentialAttrib)
                    $LogDBCredentialParam = New-Object System.Management.Automation.RuntimeDefinedParameter('LogDBCredential', [System.Management.Automation.PSCredential], $LogDBCredentialAttribCollection)

                    $paramDictionary.Add('ConfigureCacheInvalidationService', $ConfigureCacheInvalidationServiceParam)
                    $paramDictionary.Add('LogDBCredential', $LogDBCredentialParam)
                }
            }

        }
        return $paramDictionary
    }

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osInstallDir = GetServerInstallDir

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.InstallResult'
            Success      = $true
            RebootNeeded = $false
            ExitCode     = 0
            Message      = 'Nothing done'
        }
    }

    process
    {
        #region pre-checks
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        if ($(-not $osVersion) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "OutSystems platform is not installed"
            WriteNonTerminalError -Message "OutSystems platform is not installed"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'OutSystems platform is not installed'

            return $installResult
        }

        if ($(-not $(Test-Path -Path "$osInstallDir\server.hsconf")) -or $(-not $(Test-Path -Path "$osInstallDir\private.key")))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Cant find configuration file and/or private.key file. Please run New-OSServerConfig"
            WriteNonTerminalError -Message "Cant find configuration file and/or private.key. Please run New-OSServerConfig first"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Cant find configuration file and/or private.key. Please run New-OSServerConfig first'

            return $installResult
        }
        #endregion

        #region do things
        switch ($PsCmdlet.ParameterSetName)
        {
            'ChangeSettings'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Modifing configuration"
            }
            'Apply'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Applying current configuration"
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Building configuration tool command line"

                # Build the command line
                $configToolArguments = "/setupinstall "

                if ($PlatformDBCredential)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using supplied admin credentials for the platform database"
                    $dbUser = $PlatformDBCredential.UserName
                    $dbPass = $PlatformDBCredential.GetNetworkCredential().Password
                    $configToolArguments += "$dbUser $dbPass "
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using existing admin credentials for the platform database"
                    $configToolArguments += "  "
                }

                if ($osMajorVersion -eq '11.0')
                {
                    if ($PSBoundParameters.LogDBCredential)
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using supplied admin credentials for the log database"
                        $dbUser = $PSBoundParameters.LogDBCredential.UserName
                        $dbPass = $PSBoundParameters.LogDBCredential.GetNetworkCredential().Password
                        $configToolArguments += "$dbUser $dbPass "
                    }
                    else
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using existing admin credentials for the log database"
                        $configToolArguments += "  "
                    }
                }

                $configToolArguments += "/rebuildsession "

                if ($SessionDBCredential)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using supplied admin credentials for the session database"
                    $dbUser = $SessionDBCredential.UserName
                    $dbPass = $SessionDBCredential.GetNetworkCredential().Password
                    $configToolArguments += "$dbUser $dbPass "
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using existing admin credentials for the session database"
                    $configToolArguments += "  "
                }

                if ($PSBoundParameters.ConfigureCacheInvalidationService.IsPresent)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration of the cache invalidation service will be performed"
                    $configToolArguments += "/createupgradecacheinvalidationservice "
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the platform. This can take a while..."
                try
                {
                    $result = RunConfigTool -Arguments $configToolArguments
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
                    WriteNonTerminalError -Message "Error launching the configuration tool. Exit code: $($result.ExitCode)"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = 'Error launching the configuration tool'

                    return $installResult
                }

                $confToolOutputLog = $($result.Output) -Split ("`r`n")
                foreach ($logline in $confToolOutputLog)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration Tool: $logline"
                }
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($result.ExitCode)"

                if ($result.ExitCode -ne 0)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error configuring the platform. Exit code: $($result.ExitCode)"
                    WriteNonTerminalError -Message "Error configuring the platform. Exit code: $($result.ExitCode)"

                    $installResult.Success = $false
                    $installResult.ExitCode = $($result.ExitCode)
                    $installResult.Message = 'Error configuring the platform'

                    return $installResult
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Platform successfully configured"
                $installResult.Message = 'OutSystems platform successfully configured'
            }
        }
        #endregion

        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
