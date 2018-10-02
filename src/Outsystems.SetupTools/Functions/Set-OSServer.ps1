function Set-OSServer
{
    <#
    .SYNOPSIS
    Short description

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
        [Parameter()]
        [string]$Settings,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred,

        [Parameter()]
        [switch]$Apply,

        [Parameter()]
        [string]$PrivateKey
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osVersion = GetServerVersion
        $osInstallDir = GetServerInstallDir

        $dbSAUser = $Credential.UserName
        $dbSAPass = $Credential.GetNetworkCredential().Password

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

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error while configuring the private key'

                return $installResult
            }
        }
        #endregion

        #region apply config
        if ($Apply.IsPresent)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the platform. This can take a while..."
            try
            {
                $result = RunConfigTool -Arguments "/silent /setupinstall $dbSAUser $dbSAPass /rebuildsession $dbSAUser $dbSAPass"
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
            $installResult.Message = 'OutSystems successfully configured'
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
