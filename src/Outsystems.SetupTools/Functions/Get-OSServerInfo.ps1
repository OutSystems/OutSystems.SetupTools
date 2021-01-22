function Get-OSServerInfo
{
    <#
    .SYNOPSIS
    Returns a summary information about the OutSystems Server

    .DESCRIPTION
    This will returns the OutSystems Server version, install directory, serial number, machine name and private key.

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
            PSTypeName       = 'Outsystems.SetupTools.ServerInfo'
            InstallDir       = ''
            Version          = ''
            MachineName      = ''
            SerialNumber     = ''
            PrivateKey       = ''
            LifetimeVersion  = ''
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
        $serverInfo.LifetimeVersion = [System.Version]$(GetLifetimeVersion)

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server InstallDir is: $($serverInfo.InstallDir)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server version is: $($serverInfo.Version)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server machine name is: $($serverInfo.MachineName)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server serial number is: $($serverInfo.SerialNumber)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Lifetime version is: $($serverInfo.LifetimeVersion)"

        #region private key
        $privateKeyFile = "$($serverInfo.InstallDir)\private.key"
        if (Test-Path -Path $privateKeyFile)
        {
            $regex = "^--*"
            Get-Content -Path $privateKeyFile -ErrorAction SilentlyContinue | ForEach-Object {
                if (-not ($_ -match $regex))
                {
                    $serverInfo.PrivateKey = $_
                }
            }

            if ($serverInfo.PrivateKey)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server private key is: $($serverInfo.PrivateKey)"
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Private Key file found but there was an error processing the file"
            }
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Private Key file not found at $privateKeyFile"
        }
        #endregion

        return $serverInfo
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
