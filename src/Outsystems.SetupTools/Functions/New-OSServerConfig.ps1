function New-OSServerConfig
{
    <#
    .SYNOPSIS
    Generates an empty OutSystems configuration file

    .DESCRIPTION
    This will generate an empty OutSystems configuration file. You can specify the envrionment private key using the -PrivateKey parameter
    The cmdlet will not overwrite an existing configuration and/or private key. If you wish to overwrite you need to specify the -Force switch

    .PARAMETER DatabaseProvider
    Configuration will be generated for this database provider. Available database provider are 'SQL' and 'Oracle'

    .PARAMETER PrivateKey
    Used to specify the environment private key. If you dont specified this, a random one will be generated

    .PARAMETER Force
    Allows cmdlet to override an existing configuration

    .EXAMPLE
    New-OSServerConfig -DatabaseProvider 'SQL'

    .EXAMPLE
    New-OSServerConfig -DatabaseProvider 'Oracle' -PrivateKey '42bGTaGWPkWmbmGLDbkQwA==' -Force

    .EXAMPLE
    New-OSPlatformPrivateKey | New-OSServerConfig -DatabaseProvider 'Oracle' -Force

    .NOTES
    Use the Force switch with caution. Overwritting an existing configuration may cause your environment to become inaccessible

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('SQL', 'Oracle', 'PostgreSQL')]
        [string]$DatabaseProvider,

        [Parameter(ValueFromPipeline = $true)]
        [string]$PrivateKey,

        [Parameter()]
        [switch]$Force
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osVersion = GetServerVersion
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

        if (($(Test-Path -Path "$osInstallDir\server.hsconf") -or $(Test-Path -Path "$osInstallDir\private.key")) -and $(-not $Force.IsPresent))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Configuration already exists. To overwrite use the -Force switch"
            WriteNonTerminalError -Message "Configuration already exists. To overwrite use the -Force switch"

            return $null
        }
        #endregion

        #region set private key
        if ($PrivateKey)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the private.key"

            try
            {
                #Copy template file to the destination.
                Copy-Item -Path "$PSScriptRoot\..\Lib\private.key" -Destination "$osInstallDir\private.key" -Force -ErrorAction Stop

                #Changing the contents of the file.
                (Get-Content "$osInstallDir\private.key") -replace '<<KEYTOREPLACE>>', $PrivateKey | Set-Content "$osInstallDir\private.key" -ErrorAction Stop
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error while configuring the private key"
                WriteNonTerminalError -Message "Error while configuring the private key"

                return $null
            }
        }
        #endregion

        #region generate templates
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Generating new configuration for database provider $DatabaseProvider"

        $onLogEvent = {
            param($logLine)
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message $logLine
        }

        try
        {
            $result = RunConfigTool -Arguments "/GenerateTemplates" -OnLogEvent $onLogEvent
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
            WriteNonTerminalError -Message "Error lauching the configuration tool"

            return $null
        }

        if ( $result.ExitCode -ne 0 )
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error generating the templates. Exit code: $($result.ExitCode)"
            WriteNonTerminalError -Message "Error generating the templates. Exit code: $($result.ExitCode)"

            return $null
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration files generated"
        #endregion

        #region copy template
        switch($DatabaseProvider)
        {
            'SQL'
            {
                $templateFile = "$osInstallDir\docs\SqlServer_template.hsconf"
            }
            'Oracle'
            {
                $templateFile = "$osInstallDir\docs\Oracle_template.hsconf"
            }
            'PostgreSQL'
            {
                $templateFile = "$osInstallDir\docs\PostgreSQL_template.hsconf"
            }
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Copying configuration to the platform server folder"
        try
        {
            Copy-Item -Path $templateFile -Destination "$osInstallDir\server.hsconf" -Force -ErrorAction Stop
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error copying the configuration file to the platform server folder"
            WriteNonTerminalError -Message "Error copying the configuration file to the platform server folder"

            return $null
        }
        #endregion

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "New OutSystems configuration successfully created!!"
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
