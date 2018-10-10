function Get-OSServerConfig
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
    [OutputType('System.String')]
    param(
        [Parameter()]
        [string]$Setting
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osInstallDir = GetServerInstallDir
        $configurationFile = "$osInstallDir\server.hsconf"
        $Setting = "EnvironmentConfiguration/$Setting"
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

        if (-not $(Test-Path -Path $configurationFile))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error loading the configuration file (server.hsconf). File doesn't exist"
            WriteNonTerminalError -Message "Error loading the configuration file (server.hsconf). File doesn't exist"

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
        try
        {
            $xmlNode = $hsConf.SelectSingleNode($Setting)
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

        #region return results
        $result = $xmlNode.ChildNodes.Value
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Value from config file: $result"

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
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning decrypted value: $decryptedResult"
                return $decryptedResult
            }
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning value: $result"
            return $result
        }
        #endregion
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
