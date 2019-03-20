function Get-OSPlatformDeploymentZone
{
    <#
    .SYNOPSIS
    Returns the OutSystems environment deployment zones

    .DESCRIPTION
    This will return the OutSystems environment deployment zones

    .EXAMPLE
    Get-OSPlatformDeploymentZones

    .NOTES
    This cmdLet requires at least OutSystems 11

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.DeploymentZone')]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osInstallDir = GetServerInstallDir
        $osVersion = GetServerVersion
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

        if ($osVersion -lt '11.0.0.0')
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "This cmdLet is only supported on OutSystems 11 or higher"
            WriteNonTerminalError -Message "This cmdLet is only supported on OutSystems 11 or higher"

            return $null
        }
        #endregion

        #region do things

        # Build the command line
        $configToolArguments = "/getdeploymentzones"

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Running the configuration tool. This can take a while..."
        try
        {
            $result = RunConfigTool -Arguments $configToolArguments
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
            WriteNonTerminalError -Message "Error launching the configuration tool. Exit code: $($result.ExitCode)"

            return $null
        }

        if ($result.ExitCode -ne 0)
        {
            $confToolOutputLog = $($result.Output) -Split ("`r`n")
            foreach ($logline in $confToolOutputLog)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration Tool: $logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($result.ExitCode)"

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error getting the deployment zones. Exit code: $($result.ExitCode)"
            WriteNonTerminalError -Message "Error getting the deployment zones. Exit code: $($result.ExitCode)"

            return $null
        }

        try
        {
            # Try to convert the confTool JSON to a PS object
            $return = $result.Output | ConvertFrom-Json -ErrorAction Stop
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error converting the configuration tool output to object"
            WriteNonTerminalError -Message "Error converting the configuration tool output to object"

            return $null
        }

        # Add a type to the returned object
        $return.psobject.TypeNames.Insert(0, 'Outsystems.SetupTools.DeploymentZone')

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Successfully retrived the deployment zones"
        return $return

        #endregion
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
