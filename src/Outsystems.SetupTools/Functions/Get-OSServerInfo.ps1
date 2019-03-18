function Get-OSServerInfo
{
    <#
    .SYNOPSIS
    Returns a summary information about the OutSystems Server

    .DESCRIPTION
    This will returns the OutSystems Server version, install directory, serial number and machine name.

    .EXAMPLE
    Get-OSServerInfo

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.ServerInfo')]
    param ()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $serverInfo = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.ServerInfo'
            InstallDir   = ''
            Version      = ''
            MachineName  = ''
            SerialNumber = ''
        }
    }

    process
    {
        $serverInfo.InstallDir = GetServerInstallDir
        $serverInfo.Version = GetServerVersion

        if ($(-not $serverInfo.Version) -or $(-not $serverInfo.InstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            return $null
        }

        $serverInfo.Version = [System.Version]$serverInfo.Version
        $serverInfo.MachineName = GetServerMachineName
        $serverInfo.SerialNumber = GetServerSerialNumber

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning server InstallDir: $($serverInfo.InstallDir)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning server version: $($serverInfo.Version)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning server machine name: $($serverInfo.MachineName)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning server machine serial number: $($serverInfo.SerialNumber)"

        return $serverInfo
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
