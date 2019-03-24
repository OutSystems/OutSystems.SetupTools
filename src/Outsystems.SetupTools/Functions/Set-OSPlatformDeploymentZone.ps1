function Set-OSPlatformDeploymentZone
{
    <#
    .SYNOPSIS
    Sets the OutSystems environment deployment zone

    .DESCRIPTION
    This will return set an OutSystems environment deployment zone

    .PARAMETER DeploymentZone
    The name of the deployment zone. Defaults to Global

    .PARAMETER ZoneAddress
    The new address for the target Deployment Zone

    .PARAMETER EnableHTTPS
    Enable HTTPS for the target Deployment Zone. If this parameter is not provided the setting will remain unchanged

    .EXAMPLE
    Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8

    .EXAMPLE
    Set-OSPlatformDeploymentZone -DeploymentZone 'myzone' -ZoneAddress 8.8.8.8 -EnableHTTPS:$true

    .NOTES
    This cmdLet requires at least OutSystems 11

    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DeploymentZone = 'Global',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ZoneAddress,

        [Parameter()]
        [nullable[bool]]$EnableHTTPS = $null
    )

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

            return
        }

        if ($(-not $osVersion) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "OutSystems platform is not installed"
            WriteNonTerminalError -Message "OutSystems platform is not installed"

            return
        }

        if ($osVersion -lt '11.0.0.0')
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "This cmdLet is only supported on OutSystems 11 or higher"
            WriteNonTerminalError -Message "This cmdLet is only supported on OutSystems 11 or higher"

            return
        }
        #endregion

        #region do things

        # Build the command line
        $configToolArguments = "/modifydeploymentzone $DeploymentZone $ZoneAddress"

        if ($EnableHTTPS -ne $null)
        {
            $configToolArguments += " $EnableHTTPS"
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool parameters are: $configToolArguments"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Running the configuration tool. This can take a while..."
        try
        {
            $result = RunConfigTool -Arguments $configToolArguments
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the configuration tool"
            WriteNonTerminalError -Message "Error launching the configuration tool. Exit code: $($result.ExitCode)"

            return
        }

        $confToolOutputLog = $($result.Output) -Split ("`r`n")
        foreach ($logline in $confToolOutputLog)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration Tool: $logline"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuration tool exit code: $($result.ExitCode)"

        if ($result.ExitCode -ne 0)
        {

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error setting the deployment zones. Exit code: $($result.ExitCode)"
            WriteNonTerminalError -Message "Error setting the deployment zones. Exit code: $($result.ExitCode)"

            return
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Successfully set the deployment zone"

        #endregion
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
