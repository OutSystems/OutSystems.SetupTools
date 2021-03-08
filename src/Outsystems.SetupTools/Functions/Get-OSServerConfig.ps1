function Get-OSServerConfig
{
    <#
    .SYNOPSIS
    Returns the OutSystems server configuration

    .DESCRIPTION
    This will return the OutSystems server current configuration
    Encrypted settings are returned un-encrypted

    .EXAMPLE
    Get-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'AdminUser'

    .NOTES
    Check the server.hsconf file on the platform server installation folder to know which section settings and settings are available

    #>

    [CmdletBinding()]
    [OutputType('System.String')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [string]$SettingSection,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [string]$Setting
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osInstallDir = GetServerInstallDir
        $configurationFile = "$osInstallDir\server.hsconf"
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

        if (-not $osInstallDir)
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
        #endregion

        #region load hsserver.conf
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
        #endregion

        #region read setting
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Reading value from section $SettingSection, setting $Setting"
        try
        {
            $xmlNode = $hsConf.EnvironmentConfiguration.$SettingSection.SelectSingleNode($Setting)
            if (-not $xmlNode)
            {
                throw "Error getting setting $Setting"
            }
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Cant find setting. Check if its a valid setting for installed platform version"
            WriteNonTerminalError -Message "Cant find setting. Check if its a valid setting for installed platform version"

            return $null
        }
        #endregion

        #region getting value
        $result = $xmlNode.'#text'
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "The raw value from the configuration is $result"

        if ($xmlNode.encrypted -eq 'true')
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Value is encrypted. Decrypting value"
            $decryptedResult = DecryptSetting($result)

            if ($($decryptedResult -eq $result) -or $(-not $decryptedResult))
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error decrypting value"
                WriteNonTerminalError -Message "Error decrypting value"

                return $null
            }
            # Value is good
            $result = $decryptedResult
        }
        #endregion

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $result"
        return $result
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
