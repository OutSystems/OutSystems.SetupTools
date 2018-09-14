function Invoke-OSConfigurationTool
{
    <#
    .SYNOPSIS
    Documentation to be done!

    .DESCRIPTION
    Documentation to be done!


    #>

    [CmdletBinding(DefaultParameterSetName='__AllParameterSets')]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Controller = '127.0.0.1',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$PrivateKey,

        [Parameter()]
        [switch]$OverwritePrivateKey,

        [Parameter()]
        [ValidateSet('SQL', 'SQLExpress', 'AzureSQL')]
        [string]$DBProvider = 'SQL',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DBSAUser,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DBSAPass,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DBAdminUser = 'OSADMIN',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DBAdminPass,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DBRuntimeUser = 'OSRUNTIME',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DBRuntimePass,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DBSessionUser = 'OSSTATE',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DBSessionPass
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
                '10.0'
                {
                    # On OS10 we have the log DB user
                    $DBLogUserAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $DBLogUserAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $DBLogUserAttribCollection.Add($DBLogUserAttrib)
                    $DBLogUserAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                    $DBLogUserParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogUser', [String], $DBLogUserAttribCollection)
                    $PSBoundParameters.DBLogUser = 'OSLOG'

                    $DBLogPassAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $DBLogPassAttrib.Mandatory = $true
                    $DBLogPassAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $DBLogPassAttribCollection.Add($DBLogPassAttrib)
                    $DBLogPassParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogPass', [String], $DBLogPassAttribCollection)

                    $paramDictionary.Add('DBLogUser', $DBLogUserParam)
                    $paramDictionary.Add('DBLogPass', $DBLogPassParam)
                }
                '11.0'
                {
                    # On OS11 we have the rabbitMQ cache invalidation service
                    $RabbitMQHostAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $RabbitMQHostAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $RabbitMQHostAttribCollection.Add($RabbitMQHostAttrib)
                    $RabbitMQHostAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                    $RabbitMQHostParam = New-Object System.Management.Automation.RuntimeDefinedParameter('RabbitMQHost', [String], $RabbitMQHostAttribCollection)
                    $PSBoundParameters.RabbitMQHost = '127.0.0.1'

                    $RabbitMQVirtualHostAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $RabbitMQVirtualHostAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $RabbitMQVirtualHostAttribCollection.Add($RabbitMQVirtualHostAttrib)
                    $RabbitMQVirtualHostAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                    $RabbitMQVirtualHostParam = New-Object System.Management.Automation.RuntimeDefinedParameter('RabbitMQVirtualHost', [String], $RabbitMQVirtualHostAttribCollection)
                    $PSBoundParameters.RabbitMQVirtualHost = '/'

                    $RabbitMQUserAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $RabbitMQUserAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $RabbitMQUserAttribCollection.Add($RabbitMQUserAttrib)
                    $RabbitMQUserAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                    $RabbitMQUserParam = New-Object System.Management.Automation.RuntimeDefinedParameter('RabbitMQUser', [String], $RabbitMQUserAttribCollection)
                    $RabbitMQUserParam.Value = 'guest'
                    $PSBoundParameters.RabbitMQUser = 'guest'

                    $RabbitMQPassAttrib = New-Object System.Management.Automation.ParameterAttribute
                    $RabbitMQPassAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $RabbitMQPassAttribCollection.Add($RabbitMQPassAttrib)
                    $RabbitMQPassAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                    $RabbitMQPassParam = New-Object System.Management.Automation.RuntimeDefinedParameter('RabbitMQPass', [String], $RabbitMQPassAttribCollection)
                    $PSBoundParameters.RabbitMQPass = 'guest'

                    $paramDictionary.Add('RabbitMQHost', $RabbitMQHostParam)
                    $paramDictionary.Add('RabbitMQVirtualHost', $RabbitMQVirtualHostParam)
                    $paramDictionary.Add('RabbitMQUser', $RabbitMQUserParam)
                    $paramDictionary.Add('RabbitMQPass', $RabbitMQPassParam)
                }
            }

            if ($DBProvider -in "SQL", "AzureSQL", "SQLExpress")
            {
                # DBServer
                $DBServerAttrib = New-Object System.Management.Automation.ParameterAttribute
                $DBServerAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DBServerAttribCollection.Add($DBServerAttrib)
                $DBServerAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                $DBServerParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBServer', [String], $DBServerAttribCollection)
                $PSBoundParameters.DBServer = '127.0.0.1'

                # DBCatalog
                $DBCatalogAttrib = New-Object System.Management.Automation.ParameterAttribute
                $DBCatalogAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DBCatalogAttribCollection.Add($DBCatalogAttrib)
                $DBCatalogAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                $DBCatalogParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBCatalog', [String], $DBCatalogAttribCollection)
                $PSBoundParameters.DBCatalog = 'outsystems'

                # DBAuth
                $DBAuthAttrib = New-Object System.Management.Automation.ParameterAttribute
                $DBAuthValidateSetAttrib = New-Object System.Management.Automation.ValidateSetAttribute(@('SQL', 'Windows'))
                $DBAuthAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DBAuthAttribCollection.Add($DBAuthAttrib)
                $DBAuthAttribCollection.Add($DBAuthValidateSetAttrib)
                $DBAuthParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBAuth', [String], $DBAuthAttribCollection)
                $PSBoundParameters.DBAuth = 'SQL'

                # DBSessionServer
                $DBSessionServerAttrib = New-Object System.Management.Automation.ParameterAttribute
                $DBSessionServerAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DBSessionServerAttribCollection.Add($DBSessionServerAttrib)
                $DBSessionServerAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                $DBSessionServerParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBSessionServer', [String], $DBSessionServerAttribCollection)
                $PSBoundParameters.DBSessionServer = '127.0.0.1'

                # DBSessionCatalog
                $DBSessionCatalogAttrib = New-Object System.Management.Automation.ParameterAttribute
                $DBSessionCatalogAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $DBSessionCatalogAttribCollection.Add($DBSessionCatalogAttrib)
                $DBSessionCatalogAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                $DBSessionCatalogParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBSessionCatalog', [String], $DBSessionCatalogAttribCollection)
                $PSBoundParameters.DBSessionCatalog = 'osSession'


                # Add parameters
                $paramDictionary.Add('DBServer', $DBServerParam)
                $paramDictionary.Add('DBCatalog', $DBCatalogParam)
                $paramDictionary.Add('DBAuth', $DBAuthParam)
                $paramDictionary.Add('DBSessionServer', $DBSessionServerParam)
                $paramDictionary.Add('DBSessionCatalog', $DBSessionCatalogParam)

                switch ($osMajorVersion)
                {
                    '10.0'
                    {
                        # Nothing to be done here
                    }
                    '11.0'
                    {
                        ### On OS11 we need to configure the connection to the log DB ###

                        # DBLogServer
                        $DBLogServerAttrib = New-Object System.Management.Automation.ParameterAttribute
                        $DBLogServerAttrib.ParameterSetName = 'LogDBConfig'
                        $DBLogServerAttrib.Mandatory = $true
                        $DBLogServerAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                        $DBLogServerAttribCollection.Add($DBLogServerAttrib)
                        $DBLogServerAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                        $DBLogServerParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogServer', [String], $DBLogServerAttribCollection)

                        # DBLogCatalog
                        $DBLogCatalogAttrib = New-Object System.Management.Automation.ParameterAttribute
                        $DBLogCatalogAttrib.ParameterSetName = 'LogDBConfig'
                        $DBLogCatalogAttrib.Mandatory = $true
                        $DBLogCatalogAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                        $DBLogCatalogAttribCollection.Add($DBLogCatalogAttrib)
                        $DBLogCatalogAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                        $DBLogCatalogParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogCatalog', [String], $DBLogCatalogAttribCollection)

                        # DBLogAdminUser
                        $DBLogAdminUserAttrib = New-Object System.Management.Automation.ParameterAttribute
                        $DBLogAdminUserAttrib.ParameterSetName = 'LogDBConfig'
                        $DBLogAdminUserAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                        $DBLogAdminUserAttribCollection.Add($DBLogAdminUserAttrib)
                        $DBLogAdminUserAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                        $DBLogAdminUserParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogAdminUser', [String], $DBLogAdminUserAttribCollection)
                        $PSBoundParameters.DBLogAdminUser = 'OSADMIN'

                        # DBLogAdminPass
                        $DBLogAdminPassAttrib = New-Object System.Management.Automation.ParameterAttribute
                        $DBLogAdminPassAttrib.ParameterSetName = 'LogDBConfig'
                        $DBLogAdminPassAttrib.Mandatory = $true
                        $DBLogAdminPassAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                        $DBLogAdminPassAttribCollection.Add($DBLogAdminPassAttrib)
                        $DBLogAdminPassAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                        $DBLogAdminPassParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogAdminPass', [String], $DBLogAdminPassAttribCollection)

                        # DBLogRuntimeUser
                        $DBLogRuntimeUserAttrib = New-Object System.Management.Automation.ParameterAttribute
                        $DBLogRuntimeUserAttrib.ParameterSetName = 'LogDBConfig'
                        $DBLogRuntimeUserAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                        $DBLogRuntimeUserAttribCollection.Add($DBLogRuntimeUserAttrib)
                        $DBLogRuntimeUserAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                        $DBLogRuntimeUserParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogRuntimeUser', [String], $DBLogRuntimeUserAttribCollection)
                        $PSBoundParameters.DBLogRuntimeUser = 'OSRUNTIME'

                        # DBLogRuntimePass
                        $DBLogRuntimePassAttrib = New-Object System.Management.Automation.ParameterAttribute
                        $DBLogRuntimePassAttrib.ParameterSetName = 'LogDBConfig'
                        $DBLogRuntimePassAttrib.Mandatory = $true
                        $DBLogRuntimePassAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                        $DBLogRuntimePassAttribCollection.Add($DBLogRuntimePassAttrib)
                        $DBLogRuntimePassAttribCollection.Add((New-Object -TypeName System.Management.Automation.ValidateNotNullOrEmptyAttribute))
                        $DBLogRuntimePassParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBLogRuntimePass', [String], $DBLogRuntimePassAttribCollection)

                        # Add parameters
                        $paramDictionary.Add('DBLogServer', $DBLogServerParam)
                        $paramDictionary.Add('DBLogCatalog', $DBLogCatalogParam)
                        $paramDictionary.Add('DBLogAdminUser', $DBLogAdminUserParam)
                        $paramDictionary.Add('DBLogAdminPass', $DBLogAdminPassParam)
                        $paramDictionary.Add('DBLogRuntimeUser', $DBLogRuntimeUserParam)
                        $paramDictionary.Add('DBLogRuntimePass', $DBLogRuntimePassParam)
                    }
                }
            }
            return $paramDictionary
        }
    }

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.InstallResult'
            Success      = $true
            RebootNeeded = $false
            ExitCode     = 0
            Message      = 'Outsystems successfully configured'
        }

        $osInstallDir = GetServerInstallDir
    }

    process
    {
        # Check phase
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
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Outsystems platform is not installed'

            return $installResult
        }

        #Write the private.key file. This needs to be done before running the configuration tool for the first time.
        if ($PrivateKey)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the private.key"

            if ((-not (Test-Path -Path "$osInstallDir\private.key")) -or $OverwritePrivateKey.IsPresent  )
            {
                try
                {
                    #Copy template file to the destination.
                    Copy-Item -Path "$PSScriptRoot\..\Lib\private.key" -Destination "$osInstallDir\private.key" -Force -ErrorAction Stop

                    #Changing the contents of the file.
                    (Get-Content "$osInstallDir\private.key") -replace '<<KEYTOREPLACE>>', "$($PSBoundParameters.PrivateKey)" | Set-Content "$osInstallDir\private.key" -ErrorAction Stop
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error while configuring the private key"
                    WriteNonTerminalError -Message "Error while configuring the private key"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = 'Error while configuring the private key'

                    return $installResult
                }
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "File NOT modified. Already exists or the OverwritePrivateKey switch was not set"
            }
        }

        #Run configuration tool to generate the hsconf templates.
        try
        {
            $result = RunConfigTool -Arguments "/GenerateTemplates"
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
            WriteNonTerminalError -Message "Error lauching the configuration tool"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error lauching the configuration tool'

            return $installResult
        }

        if ( $result.ExitCode -ne 0 )
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error generating the templates. Exit code: $($result.ExitCode)"
            WriteNonTerminalError -Message "Error generating the templates. Exit code: $($result.ExitCode)"

            $installResult.Success = $false
            $installResult.ExitCode = $($result.ExitCode)
            $installResult.Message = 'Error generating the templates'

            return $installResult
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($result.ExitCode)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "hsconf templates generated"

        #Select the template
        switch ($DBProvider)
        {
            {$_ -in "SQL", "AzureSQL", "SQLExpress"}
            {
                $templateFile = "$osInstallDir\docs\SqlServer_template.hsconf"
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Database provider is $DBProvider"

                #Loading the template
                try
                {
                    [xml]$hsConf = Get-Content ($templateFile) -ErrorAction Stop
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error loading the server.hsconf configuration file"
                    WriteNonTerminalError -Message "Error loading the server.hsconf configuration file"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = 'Error loading the server.hsconf configuration file'

                    return $installResult
                }

                # Write common parameters for all SQL server editions
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting common SQL parameters for all editions and platforms"
                $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBCatalog
                $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBSessionCatalog
                $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBServer
                $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBSessionServer

                # Write platform specific common parameters for all SQL server editions
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting common SQL parameters for all editions specific for OutSystems $osMajorVersion"
                switch ($osMajorVersion)
                {
                    '10.0'
                    {
                        # Nothing to be done here
                    }
                    '11.0'
                    {
                        ### Log database
                        # If not specified, we default to the platform server database, admin user and runtime user
                        if ($PsCmdlet.ParameterSetName -eq 'LogDBConfig')
                        {
                            $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBLogServer
                            $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBLogCatalog
                        }
                        else
                        {
                            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Log Database not specified. Using the platform database for logs"
                            $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBServer
                            $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBCatalog
                        }
                    }
                }

                # Writting auth mode
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Database authentication mode is: $($PSBoundParameters.DBAuth)"
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting $($PSBoundParameters.DBAuth) authentication mode settings for all platforms"
                switch ($PSBoundParameters.DBAuth)
                {
                    "SQL"
                    {
                        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'

                        switch ($osMajorVersion)
                        {
                            '10.0'
                            {
                                # Nothing to be done here
                            }
                            '11.0'
                            {
                                # Log database
                                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting $($PSBoundParameters.DBAuth) authentication mode settings specific for $osMajorVersion"
                                $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.UsedAuthenticationMode.InnerText = $sqlAuthMode
                            }
                        }
                    }
                    "Windows"
                    {
                        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Windows Authentication'
                        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Windows Authentication'

                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "When windows authentication, the session DB user needs to be the runtime DB user"
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Overwritting the session user"
                        $DBSessionUser = $DBRuntimeUser
                        $DBSessionPass = $DBRuntimePass

                        switch ($osMajorVersion)
                        {
                            '10.0'
                            {
                                # Nothing to be done here
                            }
                            '11.0'
                            {
                                # Log database
                                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting $($PSBoundParameters.DBAuth) authentication mode settings specific for $osMajorVersion"
                                $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Windows Authentication'

                                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "When windows authentication, the log DB admin user and runtime needs to match with the platform DB admin and runtime user"
                                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Overwritting the log admin and runtime user"
                                $PSBoundParameters.DBLogAdminUser = $DBAdminUser
                                $PSBoundParameters.DBLogAdminPass = $DBAdminPass
                                $PSBoundParameters.DBLogRuntimeUser = $DBRuntimeUser
                                $PSBoundParameters.DBLogRuntimePass = $DBRuntimePass
                            }
                        }
                    }
                }

                #Write parameters for the specific SQL server edition
                switch ($DBProvider)
                {
                    "SQL"
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL settings for Standard Edition for all platforms"
                        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Standard'
                        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Standard'

                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL settings for Standard Edition specific for Outsystems $osMajorVersion"
                        switch ($osMajorVersion)
                        {
                            '10.0'
                            {
                                # Nothing to be done here
                            }
                            '11.0'
                            {
                                # Log database
                                $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.SqlEngineEdition.InnerText = 'Standard'
                            }
                        }
                    }
                    "AzureSQL"
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL setting for AzureSQL Edition for all platforms"
                        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Azure'
                        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Azure'

                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "AzureSQL doesnt support Windows authentication. Forcing SQL authentication"
                        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'

                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL settings for AzureSQL Edition specific for Outsystems $osMajorVersion"
                        switch ($osMajorVersion)
                        {
                            '10.0'
                            {
                                # Nothing to be done here
                            }
                            '11.0'
                            {
                                # Log database
                                $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.SqlEngineEdition.InnerText = 'Azure'
                                $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                            }
                        }

                    }
                    "SQLExpress"
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL settings for SQL Express Edition for all platforms"
                        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Express'
                        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Express'

                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL settings for SQL Express Edition specific for Outsystems $osMajorVersion"
                        switch ($osMajorVersion)
                        {
                            '10.0'
                            {
                                # Nothing to be done here
                            }
                            '11.0'
                            {
                                # Log database
                                $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.SqlEngineEdition.InnerText = 'Express'
                            }
                        }
                    }
                }
            }

            "Oracle"
            {
                #$templateFile = "$osInstallDir\docs\Oracle_template.hsconf"
                #NOT IMPLEMENTED YET!!!!
            }

            "MySQL"
            {
                #$templateFile = "$osInstallDir\docs\MySQL_template.hsconf"
                #NOT IMPLEMENTED YET!!!!
            }
        }

        ### Writting common parameters to all databases and platforms
        # Users
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting common settings for all platforms"
        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminUser.InnerText = $DBAdminUser
        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.InnerText = $DBAdminPass
        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeUser.InnerText = $DBRuntimeUser
        $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.InnerText = $DBRuntimePass
        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionUser.InnerText = $DBSessionUser
        $hsConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionPassword.InnerText = $DBSessionPass

        # Controller address
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting controller address to $Controller"
        $hsConf.EnvironmentConfiguration.ServiceConfiguration.CompilerServerHostname = $Controller

        # DB misc settings
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting DB Timeout to $OSDBTimeout"
        $hsConf.EnvironmentConfiguration.OtherConfigurations.DBTimeout = "$OSDBTimeout"

        ### Writting common parameters to all databases and but platform specific
        switch ($osMajorVersion)
        {
            '10.0'
            {
                # Log user on the platform database
                $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogUser.InnerText = "$($PSBoundParameters.DBLogUser)"
                $hsConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.InnerText = "$($PSBoundParameters.DBLogPass)"

            }
            '11.0'
            {
                # RabbitMQ
                $hsConf.EnvironmentConfiguration.CacheInvalidationConfiguration.ServiceHost = "$($PSBoundParameters.RabbitMQHost)"
                $hsConf.EnvironmentConfiguration.CacheInvalidationConfiguration.ServicePassword.InnerText = "$($PSBoundParameters.RabbitMQPass)"
                $hsConf.EnvironmentConfiguration.CacheInvalidationConfiguration.ServiceUsername = "$($PSBoundParameters.RabbitMQUser)"
                $hsConf.EnvironmentConfiguration.CacheInvalidationConfiguration.VirtualHost = "$($PSBoundParameters.RabbitMQVirtualHost)"

                # Log database settings. If not specified, we default to the platform database
                if ($PsCmdlet.ParameterSetName -eq 'LogDBConfig')
                {
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.AdminUser.InnerText = "$($PSBoundParameters.DBLogAdminUser)"
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.AdminPassword.InnerText = "$($PSBoundParameters.DBLogAdminPass)"
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.RuntimeUser.InnerText = "$($PSBoundParameters.DBLogRuntimeUser)"
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.RuntimePassword.InnerText = "$($PSBoundParameters.DBLogRuntimePass)"
                }
                else
                {
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.AdminUser.InnerText = "$($PSBoundParameters.DBAdminUser)"
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.AdminPassword.InnerText = "$($PSBoundParameters.DBAdminPass)"
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.RuntimeUser.InnerText = "$($PSBoundParameters.DBRuntimeUser)"
                    $hsConf.EnvironmentConfiguration.LoggingDatabaseConfiguration.RuntimePassword.InnerText = "$($PSBoundParameters.DBRuntimePass)"
                }
            }
        }

        ## Saving template
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Saving server.hsconf"
        try {
            $hsConf.Save("$osInstallDir\server.hsconf")
        }
        catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error saving the server.hsconf configuration file"
            WriteNonTerminalError -Message "Error saving the server.hsconf configuration file"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error saving the server.hsconf configuration file'

            return $installResult
        }


        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the platform. This can take a while..."
        try
        {
            $result = RunConfigTool -Arguments "/silent /setupinstall $DBSAUser $DBSAPass /rebuildsession $DBSAUser $DBSAPass"
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
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "CONFTOOL: $logline"
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

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Platform successfully configured!!"
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
