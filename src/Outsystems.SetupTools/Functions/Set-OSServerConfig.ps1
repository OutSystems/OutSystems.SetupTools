function Set-OSServerConfig
{
    <#
    .SYNOPSIS
    Configure or apply the current configuration to the OutSystems server

    .DESCRIPTION
    This cmdLet has two modes. Configure or Apply:

    In configure mode you can change configuration tool settings using the -SettingSection, -Setting, -Value and -Encrypted parameter
    The cmdLet will not check if SettingSection and Setting are valid OutSystems parameters. You need to know what you are doing here

    The Apply mode will run the OutSystems configuration tool with the configured settings
    For that you need to specify the -Apply parameter
    You can also specify the admin credentials for the platform, session and logging (only in OS11) databases
    You may also add the -InstallServiceCenter to install Service Center
    In OS11 you may also add the -ConfigureCacheInvalidationService to configure RabbitMQ

    .PARAMETER SettingSection
    The setting section. When this is specified, the cmdLet will run in configure mode

    .PARAMETER SectionAttribute
    The attribute of a section.

    .PARAMETER SectionAttributeValue
    The value of an attribute of a section.

    .PARAMETER Setting
    The setting

    .PARAMETER Value
    The value

    .PARAMETER Apply
    This will switch the cmdLet to apply mode

    .PARAMETER PlatformDBCredential
    PSCredential object with the admin credentials to the platform database

    .PARAMETER SessionDBCredential
    PSCredential object with the admin credentials to the session database

    .PARAMETER LogDBCredential
    PSCredential object with the admin credentials to the logging database. This is only available in OutSystems 11

    .PARAMETER ConfigureCacheInvalidationService
    If specified, the cmdLet will also configure RabbitMQ

    .PARAMETER InstallServiceCenter
    If specified, the cmdLet will also install Service Center

    .PARAMETER SkipSessionRebuild
    If specified, the configuration tool will not rebuild the session database. Usefull on frontends.

    .PARAMETER UpgradeEnvironment
    If specified, the configuration tool will upgrade all applications in the environment to the new version

    .PARAMETER IntegratedAuthPassword
    If specified, the configuration tool will upgrade the environment using integrated auth

    .EXAMPLE
    Set-OSServerConfig -Apply -UpgradeEnvironment -IntegratedAuthPassword 'password'

    .EXAMPLE
    Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'ServiceUsername' -Value 'admin'

    .EXAMPLE
    Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'ServicePassword' -Value 'mysecretpass'

    .EXAMPLE
    Set-OSServerConfig -Apply -PlatformDBCredential sa

    .EXAMPLE
    Set-OSServerConfig -Apply -PlatformDBCredential sa -SessionDBCredential sa -LogDBCredential sa -ConfigureCacheInvalidationService -InstallServiceCenter

    .NOTES
    Check the server.hsconf file on the platform server installation folder to know which section settings and settings are available

    If you dont specify database credentials, the configuration tool will try the current user credentials and then admin user specified on the configuration

    #>

    [CmdletBinding(DefaultParameterSetName = 'ChangeSettings')]
    param(
        [Parameter(ParameterSetName = 'ChangeSettings', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [string]$SettingSection,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'ChangeSettings')]
        [ValidateNotNullOrEmpty()]
        [string]$SectionAttribute,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'ChangeSettings')]
        [ValidateNotNullOrEmpty()]
        [string]$SectionAttributeValue,

        [Parameter(ParameterSetName = 'ChangeSettings', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_]+$')]
        [string]$Setting,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'ChangeSettings', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        #[Parameter(ParameterSetName = 'ChangeSettings')]
        #[switch]$Encrypted,

        [Parameter(ParameterSetName = 'ApplyConfig')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$PlatformDBCredential,

        [Parameter(ParameterSetName = 'ApplyConfig')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$SessionDBCredential,

        [Parameter(ParameterSetName = 'ApplyConfig')]
        [switch]$Apply,

        [Parameter(ParameterSetName = 'ApplyConfig')]
        [switch]$SkipSessionRebuild
    )

    dynamicParam
    {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Get the platform major version
        $osVersion = GetServerVersion

        if ($osVersion)
        {
            $osMajorVersion = "$(([version]$osVersion).Major)"

            # Version specific parameters
            switch ($osMajorVersion)
            {
                '10'
                {
                    #do nothing
                }
                default
                {
                    $ConfigureCacheInvalidationServiceAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $ConfigureCacheInvalidationServiceAttrib.ParameterSetName = 'ApplyConfig'
                    $ConfigureCacheInvalidationServiceAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $ConfigureCacheInvalidationServiceAttribCollection.Add($ConfigureCacheInvalidationServiceAttrib)
                    $ConfigureCacheInvalidationServiceParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ConfigureCacheInvalidationService', [switch], $ConfigureCacheInvalidationServiceAttribCollection)

                    $LogDBCredentialAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $LogDBCredentialAttrib.ParameterSetName = 'ApplyConfig'
                    $LogDBCredentialAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $LogDBCredentialAttribCollection.Add($LogDBCredentialAttrib)
                    $LogDBCredentialParam = New-Object System.Management.Automation.RuntimeDefinedParameter('LogDBCredential', [System.Management.Automation.PSCredential], $LogDBCredentialAttribCollection)

                    $UpgradeEnvironmentAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $UpgradeEnvironmentAttrib.ParameterSetName = 'ApplyConfig'
                    $UpgradeEnvironmentAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $UpgradeEnvironmentAttribCollection.Add($UpgradeEnvironmentAttrib)
                    $UpgradeEnvironmentParam = New-Object System.Management.Automation.RuntimeDefinedParameter('UpgradeEnvironment', [switch], $UpgradeEnvironmentAttribCollection)

                    $IntegratedAuthPasswordAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $IntegratedAuthPasswordAttrib.ParameterSetName = 'ApplyConfig'
                    $IntegratedAuthPasswordAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $IntegratedAuthPasswordAttribCollection.Add($IntegratedAuthPasswordAttrib)
                    $IntegratedAuthPasswordParam = New-Object System.Management.Automation.RuntimeDefinedParameter('IntegratedAuthPassword', [string], $IntegratedAuthPasswordAttribCollection)

                    $paramDictionary.Add('ConfigureCacheInvalidationService', $ConfigureCacheInvalidationServiceParam)
                    $paramDictionary.Add('LogDBCredential', $LogDBCredentialParam)
                    $paramDictionary.Add('IntegratedAuthPassword', $IntegratedAuthPasswordParam)
                    $paramDictionary.Add('UpgradeEnvironment', $UpgradeEnvironmentParam)
                }
            }

            $InstallServiceCenterAttrib = New-Object System.Management.Automation.ParameterAttribute
            $InstallServiceCenterAttrib.ParameterSetName = 'ApplyConfig'
            $InstallServiceCenterAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $InstallServiceCenterAttribCollection.Add($InstallServiceCenterAttrib)
            $InstallServiceCenterParam = New-Object System.Management.Automation.RuntimeDefinedParameter('InstallServiceCenter', [switch], $InstallServiceCenterAttribCollection)

            $paramDictionary.Add('InstallServiceCenter', $InstallServiceCenterParam)
        }
        return $paramDictionary
    }

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osInstallDir = GetServerInstallDir
    }

    process
    {
        #region pre-checks
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return $null
        }

        if ($(-not $osVersion) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "OutSystems platform is not installed"
            WriteNonTerminalError -Message "OutSystems platform is not installed"

            return $null
        }

        if ($(-not $(Test-Path -Path "$osInstallDir\server.hsconf")) -or $(-not $(Test-Path -Path "$osInstallDir\private.key")))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Cant find configuration file and/or private.key file. Please run New-OSServerConfig cmdLet to generate a new one"
            WriteNonTerminalError -Message "Cant find configuration file and/or private.key. Please run New-OSServerConfig cmdLet to generate a new one"

            return $null
        }

        if (($PSBoundParameters.IntegratedAuthPassword.IsPresent) -and (-not $PSBoundParameters.UpgradeEnvironment.IsPresent))
        {
            $errorMessage = "SetupTools is currently only supporting integrated auth with upgrade environment option."
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message $errorMessage
            WriteNonTerminalError -Message $errorMessage

            return $null
        }
        #endregion

        #region do things
        switch ($PsCmdlet.ParameterSetName)
        {
            #region change setttings
            'ChangeSettings'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "In modifying configuration mode"

                $configurationFile = "$osInstallDir\server.hsconf"

                # Load XML
                try
                {
                    [xml]$hsConf = Get-Content ($configurationFile) -ErrorAction Stop
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error loading the configuration file (server.hsconf). Can't parse XML"
                    WriteNonTerminalError -Message "Error loading the configuration file (server.hsconf). Can't parse XML"

                    return $null
                }

                # Write setting in the configuration
                if (-not $($($hsConf.EnvironmentConfiguration).SelectSingleNode($SettingSection)))
                {
                    # Create the config section
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration section $SettingSection doesn't exists. Creating a new one"

                    $newElement = $hsConf.CreateElement($SettingSection)
                    $hsConf.EnvironmentConfiguration.AppendChild($newElement) | Out-Null
                }

                if ($SectionAttribute) {
                    if (-not $($($hsConf.EnvironmentConfiguration).SelectSingleNode($SettingSection).GetAttribute($SectionAttribute)))
                    {
                        $section = $($hsConf.EnvironmentConfiguration).SelectSingleNode($SettingSection)
                        $section.SetAttribute($SectionAttribute, $SectionAttributeValue)
                    }
                }

                if ($($hsConf.EnvironmentConfiguration).SelectSingleNode($SettingSection).SelectSingleNode($Setting))
                {
                    # Delete the existing setting
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting $Setting already exists. Deleting"

                    $nodeToDelete = $hsConf.EnvironmentConfiguration.$SettingSection.SelectSingleNode($Setting)
                    $hsConf.EnvironmentConfiguration.SelectSingleNode($SettingSection).RemoveChild($nodeToDelete) | Out-Null
                }

                # Create the new setting
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating the new setting $Setting"

                $newElement = $hsConf.CreateElement($Setting)
                $hsConf.EnvironmentConfiguration.SelectSingleNode($SettingSection).AppendChild($newElement) | Out-Null

                # Encrypt value
                # This only works after running the config tool
                # Will check this later. For now we disabled this option
                #Cannot find the private key path
                #    at #0mb.#lp.#MDb.#cp()
                #    at #0mb.#ep.InnerApplyAlgorithm(String value)
                #    at OutSystems.RuntimeCommon.Cryptography.VersionedAlgorithms.VersionedCryptographyAlgorithms`1.ApplySpecificAlgorithm(String value, Int32 algorithmIdx)
                #    at OutSystems.HubEdition.RuntimePlatform.Settings.EncryptString(String text)
                #    at CallSite.Target(Closure , CallSite , Type , String )
                if ($Encrypted.IsPresent)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Value will be encrypted"

                    $nodeAttrib = $hsConf.EnvironmentConfiguration.$SettingSection.SelectSingleNode($Setting).OwnerDocument.CreateAttribute('encrypted')
                    $nodeAttrib.Value = 'true'

                    try
                    {
                        $encryptedValue = EncryptSetting -Setting $Value
                    }
                    catch
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error encrypting value"
                        WriteNonTerminalError -Message "Error encrypting value"

                        return $null
                    }

                    # Encrypted value is good
                    $Value = $encryptedValue
                    $hsConf.EnvironmentConfiguration.$SettingSection.SelectSingleNode($Setting).Attributes.Append($nodeAttrib) | Out-Null
                }

                # Writting the value
                switch($Setting)
                {
                    {'RuntimePassword', 'SessionPassword', 'ServicePassword', 'AdminPassword', 'LogPassword'}
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting '$SettingSection/$Setting' to the provided value"
                    }
                    default
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting '$SettingSection/$Setting' to '$Value'"
                    }
                }

                $hsConf.EnvironmentConfiguration.$SettingSection.SelectSingleNode($Setting).InnerXML = $Value

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Saving configuration"
                try
                {
                    $hsConf.Save($configurationFile)
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error saving the configuration file"
                    WriteNonTerminalError -Message "Error saving the configuration file"

                    return $null
                }
            }
            #endregion

            #region apply settings
            'ApplyConfig'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "In apply configuration mode"
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Building configuration tool command line"

                # Build the command line
                $configToolArguments = "/setupinstall "

                if ($PSBoundParameters.IntegratedAuthPassword.IsPresent)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using supplied password for the Integrated Auth User"
                    $configToolArguments += "$IntegratedAuthPassword "
                }
                elseif ($PlatformDBCredential)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using supplied admin credentials for the platform database"
                    $dbUser = $PlatformDBCredential.UserName
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using $dbUser for the platform database"
                    $dbPass = $PlatformDBCredential.GetNetworkCredential().Password
                    $configToolArguments += "$dbUser $dbPass "
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Using existing admin credentials for the platform database"
                    $configToolArguments += "  "
                }

                if ($osMajorVersion -ge '11')
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

                if (-not $SkipSessionRebuild.IsPresent)
                {
                    $configToolArguments += "/rebuildsession "
                }

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

                if ($PSBoundParameters.UpgradeEnvironment.IsPresent)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Upgrade of environment will be performed"
                    $configToolArguments += "/UpgradeEnvironment "
                }

                if ($PSBoundParameters.InstallServiceCenter.IsPresent)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installation of Service Center will be performed"
                    $configToolArguments += "/SCInstall "
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the platform. This can take a while..."

                $onLogEvent = {
                    param($logLine)
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message $logLine
                }

                try
                {
                    $result = RunConfigTool -Arguments $configToolArguments -OnLogEvent $onLogEvent
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
                    WriteNonTerminalError -Message "Error launching the configuration tool. Exit code: $($result.ExitCode)"

                    return $null
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($result.ExitCode)"

                if ($result.ExitCode -ne 0)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error configuring the platform. Exit code: $($result.ExitCode)"
                    WriteNonTerminalError -Message "Error configuring the platform. Exit code: $($result.ExitCode)"

                    return $null
                }

                if ($PSBoundParameters.InstallServiceCenter.IsPresent -or $PSBoundParameters.UpgradeEnvironment.IsPresent)
                {
                    # Flag service center installation
                    try
                    {
                        SetSCCompiledVersion -SCVersion $osVersion
                    }
                    catch
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the service center version"
                        WriteNonTerminalError -Message "Error setting the service center version"
                    }
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Platform successfully configured"
            }
            #endregion
        }
        #endregion
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
