function Install-OSPlatformServiceCenter
{
    <#
    .SYNOPSIS
    Installs or updates the OutSystems Service Center.

    .DESCRIPTION
    This will install or update the OutSystems Service Center.
    It will skip the installation if already installed with the right version.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .EXAMPLE
    Install-OSPlatformServiceCenter -Force

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param (
        [Parameter()]
        [switch]$Force
    )

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
            Message      = 'Outsystems service center successfully installed'
        }

        $osVersion = GetServerVersion
    }

    process
    {
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        if ($(-not $osVersion) -or $(-not $(GetServerInstallDir)))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Outsystems platform is not installed'

            return $installResult
        }

        if ($(GetSCCompiledVersion) -ne $osVersion)
        {
            $doInstall = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service Center was already compiled with this server version"
        }

        if ($doInstall -or $Force.IsPresent)
        {
            if ($Force.IsPresent)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. We will reinstall!!"
            }

            switch ("$(([version]$osVersion).Major)")
            {
                '10'
                {
                    $scInstallerArguments = '-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif'
                }
                { ($_  -as [int]) -ge 11}
                {
                    $scInstallerArguments = '-file ServiceCenter.oml -extension OMLProcessor.xif IntegrationStudio.xif PlatformLogs.xif'
                    if ($(([version]$osVersion).Major -gt 11) -or $(([version]$osVersion).Minor -gt 18) -or ($(([version]$osVersion).Minor -eq 18) -and $(([version]$osVersion).Build -ge 1)))
                    {
                        $scInstallerArguments += ' CentralizedPlatformLogs.xif'
                    }
                }
                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Unsupported Outsystems platform version"
                    WriteNonTerminalError -Message "Unsupported Outsystems platform version"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = 'Unsupported Outsystems platform version'

                    return $installResult
                }
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems Service Center. This can take a while..."

            $onLogEvent = {
                param($logLine)
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message $logLine
            }

            try
            {
                $result = RunSCInstaller -Arguments $scInstallerArguments -OnLogEvent $onLogEvent
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the service center installer"
                WriteNonTerminalError -Message "Error lauching the service center installer"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error lauching the service center installer'

                return $installResult
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SCInstaller exit code: $($result.ExitCode)"

            if ( $result.ExitCode -ne 0 )
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing service center. Return code: $($result.ExitCode)"
                WriteNonTerminalError -Message "Error installing service center. Return code: $($result.ExitCode)"

                $installResult.Success = $false
                $installResult.ExitCode = $($result.ExitCode)
                $installResult.Message = 'Error installing service center'

                return $installResult
            }

            try
            {
                SetSCCompiledVersion -SCVersion $osVersion
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the service center version"
                WriteNonTerminalError -Message "Error setting the service center version"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error setting the service center version'

                return $installResult
            }
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service Center successfully installed!!"
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
