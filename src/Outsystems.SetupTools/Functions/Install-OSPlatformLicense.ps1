function Install-OSPlatformLicense
{
    <#
    .SYNOPSIS
    Installs the OutSystems platform license.

    .DESCRIPTION
    This will install the OutSystems platform license.
    If the license file is not specified, a 30 days trial license will be installed.

    .PARAMETER Path
    The path of the license.lic file.

    .EXAMPLE
    Install-OSPlatformLicense -Path c:\temp

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osVersion = GetServerVersion
    }

    process
    {
        ### Check phase ###
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        if ($(-not $osVersion) -or $(-not $(GetServerInstallDir)))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            return
        }

        if ($(GetSCCompiledVersion) -ne $osVersion)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            WriteNonTerminalError -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"

            return
        }

        if ($Path)
        {
            if (-not (Test-Path -Path "$Path\license.lic"))
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "License file not found at $Path\license.lic"
                WriteNonTerminalError -Message "License file not found at $Path\license.lic"

                return
            }
            $Path = "$Path\license.lic"
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "License path not specified. We will install a trial one"
            $Path = $ENV:TEMP

            try
            {
                DownloadOSSources -URL "$OSRepoURL\license.lic" -SavePath "$Path\license.lic"
                $Path = "$Path\license.lic"
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading the license from the repository"
                WriteNonTerminalError -Message "Error downloading the license from the repository"

                return
            }
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing outsytems license"

        $onLogEvent = {
            param($logLine)
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message $logLine
        }

        try
        {
            $result = RunConfigTool -Arguments $("/UploadLicense " + [char]34 + $Path + [char]34) -OnLogEvent $onLogEvent
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
            WriteNonTerminalError -Message "Error lauching the configuration tool"

            return
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($result.ExitCode)"

        if ($result.ExitCode -ne 0)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error uploading the license. Return code: $($result.ExitCode)"
            WriteNonTerminalError -Message "Error uploading the license. Return code: $($result.ExitCode)"

            return
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "License successfully installed!!"
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
