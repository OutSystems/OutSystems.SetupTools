Function Invoke-OSConfigurationTool {
    <#
    .SYNOPSIS
    Documentation to be done!

    .DESCRIPTION
    Documentation to be done!


    #>

    [CmdletBinding()]
    Param(
        [Parameter()]
        [string]$Controller,

        [Parameter()]
        [string]$PrivateKey,

        [Parameter()]
        [switch]$OverwritePrivateKey,

        [Parameter(Mandatory = $true)]
        [ValidateSet('SQL', 'SQLExpress', 'AzureSQL')]
        [string]$DBProvider,

        [Parameter(Mandatory = $true)]
        [string]$DBSAUser,

        [Parameter(Mandatory = $true)]
        [string]$DBSAPass,

        [Parameter(Mandatory = $true)]
        [string]$DBAdminUser,

        [Parameter(Mandatory = $true)]
        [string]$DBAdminPass,

        [Parameter(Mandatory = $true)]
        [string]$DBRuntimeUser,

        [Parameter(Mandatory = $true)]
        [string]$DBRuntimePass,

        [Parameter(Mandatory = $true)]
        [string]$DBLogUser,

        [Parameter(Mandatory = $true)]
        [string]$DBLogPass,

        [Parameter(Mandatory = $true)]
        [string]$DBSessionUser,

        [Parameter(Mandatory = $true)]
        [string]$DBSessionPass
    )

    DynamicParam {

        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        If ( $DBProvider -in "SQL", "AzureSQL", "SQLExpress" ) {
            #DBServer
            $DBServerAttrib = New-Object System.Management.Automation.ParameterAttribute
            $DBServerAttrib.Mandatory = $true
            $DBServerAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $DBServerAttribCollection.Add($DBServerAttrib)
            $DBServerParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBServer', [String], $DBServerAttribCollection)

            #DBCatalog
            $DBCatalogAttrib = New-Object System.Management.Automation.ParameterAttribute
            $DBCatalogAttrib.Mandatory = $true
            $DBCatalogAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $DBCatalogAttribCollection.Add($DBCatalogAttrib)
            $DBCatalogParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBCatalog', [String], $DBCatalogAttribCollection)

            #DBAuth
            $DBAuthAttrib = New-Object System.Management.Automation.ParameterAttribute
            $DBAuthAttrib.Mandatory = $true
            $DBAuthValidateSetAttrib = New-Object System.Management.Automation.ValidateSetAttribute(@('SQL', 'Windows'))
            $DBAuthAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $DBAuthAttribCollection.Add($DBAuthAttrib)
            $DBAuthAttribCollection.Add($DBAuthValidateSetAttrib)
            $DBAuthParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBAuth', [String], $DBAuthAttribCollection)

            #DBSessionServer
            $DBSessionServerAttrib = New-Object System.Management.Automation.ParameterAttribute
            $DBSessionServerAttrib.Mandatory = $true
            $DBSessionServerAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $DBSessionServerAttribCollection.Add($DBSessionServerAttrib)
            $DBSessionServerParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBSessionServer', [String], $DBSessionServerAttribCollection)

            #DBSessionCatalog
            $DBSessionCatalogAttrib = New-Object System.Management.Automation.ParameterAttribute
            $DBSessionCatalogAttrib.Mandatory = $true
            $DBSessionCatalogAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $DBSessionCatalogAttribCollection.Add($DBSessionCatalogAttrib)
            $DBSessionCatalogParam = New-Object System.Management.Automation.RuntimeDefinedParameter('DBSessionCatalog', [String], $DBSessionCatalogAttribCollection)


            $paramDictionary.Add('DBServer', $DBServerParam)
            $paramDictionary.Add('DBCatalog', $DBCatalogParam)
            $paramDictionary.Add('DBAuth', $DBAuthParam)
            $paramDictionary.Add('DBSessionServer', $DBSessionServerParam)
            $paramDictionary.Add('DBSessionCatalog', $DBSessionCatalogParam)
        }

        Return $paramDictionary
    }

    Begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Write-Output "Configuring the platform. This can take a while... Please wait..."
        Try{
            CheckRunAsAdmin | Out-Null
        }
        Catch{
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }

        $OSInstallDir = GetServerInstallDir
        if ($(-not $(GetServerVersion)) -or $(-not $OSInstallDir)){
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }
    }

    Process {

        #Write the private.key file. This needs to be done before running the configuration tool for the first time.
        If ($PrivateKey) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Environment private key specified in the command line"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the private.key"

            If ( ( -not (Test-Path -Path "$OSInstallDir\private.key") ) -or $OverwritePrivateKey.IsPresent  ) {

                #Copy template file to the destination.
                Copy-Item -Path "$PSScriptRoot\..\Lib\private.key" -Destination "$OSInstallDir\private.key" -Force

                #Changing the contents of the file.
                (Get-Content "$OSInstallDir\private.key") -replace '<<KEYTOREPLACE>>', "$($PSBoundParameters.PrivateKey)" | Set-Content "$OSInstallDir\private.key"

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "File modified successfully!!."
            }
            else {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "File NOT modified. File already exists and the OverwritePrivateKey switch was not set"
            }

        }

        #Run configuration tool to generate the hsconf templates.
        Try {
            $Result = RunConfigTool -Arguments "/GenerateTemplates"
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool."
            Throw "Error lauching the configuration tool."
        }

        If( $Result.ExitCode -ne 0 ){
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error generating the templates. Return code: $($Result.ExitCode)"
            throw "Error generating the templates. Return code: $($Result.ExitCode)"
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "hsconf templates generated"

        #Select the template
        switch ($DBProvider) {
            {$_ -in "SQL", "AzureSQL", "SQLExpress"} {
                $TemplateFile = "$OSInstallDir\docs\SqlServer_template.hsconf"
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Database provider is $DBProvider"

                #Loading the template
                [xml]$HSConf = Get-Content ($TemplateFile)

                #Write common parameters for all SQL server editions
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL parameters common for all editions"
                $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBCatalog
                $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBSessionCatalog
                $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBServer
                $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBSessionServer

                #Write auth method
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting authentication method"
                switch ($PSBoundParameters.DBAuth) {
                    "SQL" {
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                    }
                    "Windows" {
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Windows Authentication'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Windows Authentication'
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "When windows authentication, the session user and password needs to be the same of the runtime User."
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Overwritting the session user"
                        $DBSessionUser = $DBRuntimeUser
                        $DBSessionPass = $DBRuntimePass
                    }
                }

                #Write parameters for the specific SQL server edition
                switch ($DBProvider) {
                    "SQL" {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting SQL parameters for Standard Edition"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Standard'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Standard'
                    }
                    "AzureSQL" {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Wrtting SQL parameters for AzureSQL"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Azure'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Azure'

                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "AzureSQL doesnt support Windows authentication. Forcing SQL authentication"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'

                    }
                    "SQLExpress" {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Wrtting SQL parameters for SQL Express"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Express'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Express'
                    }
                }
            }

            "Oracle" {
                #$TemplateFile = "$OSInstallDir\docs\Oracle_template.hsconf"
                #NOT IMPLEMENTED YET!!!!
            }

            "MySQL" {
                #$TemplateFile = "$OSInstallDir\docs\MySQL_template.hsconf"
                #NOT IMPLEMENTED YET!!!!
            }
        }

        #Wrtting common parameters to all templates.
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting common parameters"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting DBAdminUser and DBAdminPass"
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminUser.InnerText = $DBAdminUser
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.InnerText = $DBAdminPass

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting DBRuntimeUser and DBRuntimePass"
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeUser.InnerText = $DBRuntimeUser
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.InnerText = $DBRuntimePass

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting DBLogUser and DBLogPass"
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogUser.InnerText = $DBLogUser
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.InnerText = $DBLogPass

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting DBSessionUser and DBSessionPass"
        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionUser.InnerText = $DBSessionUser
        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionPassword.InnerText = $DBSessionPass
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Writting common parameters complete"

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting DB Timeout to $OSDBTimeout"
        $HSConf.EnvironmentConfiguration.OtherConfigurations.DBTimeout = "$OSDBTimeout"

        #Writting controller address.
        If (-not $Controller) {
            $Controller = "127.0.0.1"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting controller address to $Controller"
        $HSConf.EnvironmentConfiguration.ServiceConfiguration.CompilerServerHostname = $Controller

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Saving server.hsconf"
        $HSConf.Save("$OSInstallDir\server.hsconf")

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the platform. This can take a while..."
        Try {
            $Result = RunConfigTool -Arguments "/silent /setupinstall $DBSAUser $DBSAPass /rebuildsession $DBSAUser $DBSAPass"
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
            Throw "Error lauching the configuration tool"
        }

        $ConfToolOutputLog = $($Result.Output) -Split("`r`n")
        ForEach($Logline in $ConfToolOutputLog){
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "CONFTOOL: $Logline"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($Result.ExitCode)"

        If( $Result.ExitCode -ne 0 ){
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error configuring the platform. Return code: $($Result.ExitCode)"
            throw "Error configuring the platform. Return code: $($Result.ExitCode)"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Platform successfully configured!!"
    }

    End {
        Write-Output "Platform successfully configured!!"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
