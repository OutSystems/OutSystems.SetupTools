Function Invoke-OSConfigurationTool
{
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER InstallType
    Parameter description

    .PARAMETER DBProvider
    Parameter description

    .PARAMETER DBAdminUser
    Parameter description

    .PARAMETER DBAdminPass
    Parameter description

    .PARAMETER DBRuntimeUser
    Parameter description

    .PARAMETER DBRuntimePass
    Parameter description

    .PARAMETER DBLogUser
    Parameter description

    .PARAMETER DBLogPass
    Parameter description

    .PARAMETER DBSessionUser
    Parameter description

    .PARAMETER DBSessionPass
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param(
        [Parameter()]
        [string]$Controller='127.0.0.1',

        [Parameter()]
        [string]$PrivateKey,

        [Parameter()]
        [switch]$OverwritePrivateKey,

        [Parameter(Mandatory=$true)]
        [ValidateSet('SQL','SQLExpress','AzureSQL')]
        [string]$DBProvider,

        [Parameter(Mandatory=$true)]
        [string]$DBSAUser,

        [Parameter(Mandatory=$true)]
        [string]$DBSAPass,

        [Parameter(Mandatory=$true)]
        [string]$DBAdminUser,

        [Parameter(Mandatory=$true)]
        [string]$DBAdminPass,

        [Parameter(Mandatory=$true)]
        [string]$DBRuntimeUser,

        [Parameter(Mandatory=$true)]
        [string]$DBRuntimePass,

        [Parameter(Mandatory=$true)]
        [string]$DBLogUser,

        [Parameter(Mandatory=$true)]
        [string]$DBLogPass,

        [Parameter(Mandatory=$true)]
        [string]$DBSessionUser,

        [Parameter(Mandatory=$true)]
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
            $DBAuthValidateSetAttrib = New-Object System.Management.Automation.ValidateSetAttribute(@('SQL','Windows'))
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


            $paramDictionary.Add('DBServer',$DBServerParam)
            $paramDictionary.Add('DBCatalog',$DBCatalogParam)
            $paramDictionary.Add('DBAuth',$DBAuthParam)
            $paramDictionary.Add('DBSessionServer',$DBSessionServerParam)
            $paramDictionary.Add('DBSessionCatalog',$DBSessionCatalogParam)
        }

        Return $paramDictionary
    }

    Process {

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

        #Checking for admin rights
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights"
        If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console" }

        #Checking if platform server is installed.
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Check if the platform server is installed"
        $OSVersion = Get-OSPlatformServerVersion -ErrorAction stop
        $OSInstallDir = Get-OSPlatformServerInstallDir -ErrorAction stop
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Platform server is installed. Version: $OSVersion"

        #Stop Outsystems services
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Stopping Outsystems services"
        Stop-OSServices
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems services stopped"

        #Write the private.key file. This needs to be done before running the configuration tool for the first time.
        If ($PrivateKey){
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Environment private key specified in the command line"
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring the private.key"

            If( ( -not (Test-Path -Path "$OSInstallDir\private.key")) -or $OverwritePrivateKey.IsPresent  ){

                #Copy template file to the destination.
                Copy-Item -Path "$PSScriptRoot\..\Lib\private.key" -Destination "$OSInstallDir\private.key" -Force

                #Changing the contents of the file.
                (Get-Content "$OSInstallDir\private.key") -replace '<<KEYTOREPLACE>>', "$($PSBoundParameters.PrivateKey)" | Set-Content "$OSInstallDir\private.key"

                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "File modified successfully!!."
            } else {
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "File NOT modified. File already exists and the OverwritePrivateKey switch was not set"
            }

        }

        #Run configuration tool to generate the hsconf templates.
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Generating hsconf templates"
        RunConfigTool -Path $OSInstallDir -Arguments "/GenerateTemplates"
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "hsconf templates generated"

        #Select the template
        switch ($DBProvider) {
            {$_ -in "SQL", "AzureSQL", "SQLExpress"}
            {
                $TemplateFile = "$OSInstallDir\docs\SqlServer_template.hsconf"
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Database provider is: $DBProvider"

                #Loading the template
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Loading template file $TemplateFile"
                [xml]$HSConf = Get-Content ($TemplateFile)
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Template loaded"

                #Write common parameters for all SQL server editions
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting SQL parameters common for all editions"
                $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBCatalog
                $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.Catalog.InnerText = $PSBoundParameters.DBSessionCatalog
                $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBServer
                $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.Server.InnerText = $PSBoundParameters.DBSessionServer

                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting SQL parameters common for all editions completed"

                #Write auth method
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting authentication method"
                switch ($PSBoundParameters.DBAuth) {
                    "SQL"
                    {
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                    }
                    "Windows"
                    {
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Windows Authentication'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Windows Authentication'
                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "When windows authentication, the session user and password needs to be the same of the runtime User."
                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Overwritting the session user"
                        $DBSessionUser = $DBRuntimeUser
                        $DBSessionPass = $DBRuntimePass
                    }
                }
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting authentication method completed."

                #Write parameters for the specific SQL server edition
                switch ($DBProvider) {
                    "SQL"
                    {
                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Wrtting SQL parameters for Standard Edition"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Standard'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Standard'
                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Wrtting SQL parameters for Standard Edition completed"
                    }
                    "AzureSQL"
                    {
                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Wrtting SQL parameters for AzureSQL"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Azure'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Azure'

                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "AzureSQL doesnt support Windows authentication. Forcing SQL authentication"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.UsedAuthenticationMode.InnerText = 'Database Authentication'

                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Wrtting SQL parameters for AzureSQL completed"
                    }
                    "SQLExpress"
                    {
                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Wrtting SQL parameters for SQL Express"
                        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.SqlEngineEdition.InnerText = 'Express'
                        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SqlEngineEdition.InnerText = 'Express'
                        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Wrtting SQL parameters for SQL Express completed"
                    }
                }
            }

            "Oracle"
            {
                #$TemplateFile = "$OSInstallDir\docs\Oracle_template.hsconf"
                #NOT IMPLEMENTED YET!!!!
            }

            "MySQL"
            {
                #$TemplateFile = "$OSInstallDir\docs\MySQL_template.hsconf"
                #NOT IMPLEMENTED YET!!!!
            }
        }

        #Wrtting common parameters to all templates.
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting common parameters"
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting DBAdminUser and DBAdminPass"
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminUser.InnerText = $DBAdminUser
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.AdminPassword.InnerText = $DBAdminPass

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting DBRuntimeUser and DBRuntimePass"
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimeUser.InnerText = $DBRuntimeUser
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.RuntimePassword.InnerText = $DBRuntimePass

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting DBLogUser and DBLogPass"
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogUser.InnerText = $DBLogUser
        $HSConf.EnvironmentConfiguration.PlatformDatabaseConfiguration.LogPassword.InnerText = $DBLogPass

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting DBSessionUser and DBSessionPass"
        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionUser.InnerText = $DBSessionUser
        $HSConf.EnvironmentConfiguration.SessionDatabaseConfiguration.SessionPassword.InnerText = $DBSessionPass
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Writting common parameters complete"

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting DB Timeout to: $OSDBTimeout"
        $HSConf.EnvironmentConfiguration.OtherConfigurations.DBTimeout = "$OSDBTimeout"

        #Writting controller address.
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting controller address to: $Controller"
        $HSConf.EnvironmentConfiguration.ServiceConfiguration.CompilerServerHostname = $Controller

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Saving server.hsconf"
        $HSConf.Save("$OSInstallDir\server.hsconf")

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring the platform. This can take a while."
        RunConfigTool -Path $OSInstallDir -Arguments "/silent /setupinstall $DBSAUser $DBSAPass /rebuildsession $DBSAUser $DBSAPass" -ErrorAction stop
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Platform successfully configured!!"

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}