function Get-OSServiceStudioInstallDir
{
    <#
    .SYNOPSIS
    DEPRECATED - Use Get-OSServiceStudioInfo
    Returns where the OutSystems development environment (Service Studio) is installed.

    .DESCRIPTION
    This will returns where the OutSystems development environment is installed.
    Since we can have multiple development environments installed, you need to specify the major version to get.

    .PARAMETER MajorVersion
    Major version. 9.0, 9.1, 10, 11, ...

    .EXAMPLE
    Get-OSServiceStudioInstallDir -MajorVersion "10"

    #>

    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "10")]
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        $output = GetServiceStudioInstallDir -MajorVersion $MajorVersion

        if (-not $output)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems development environment $MajorVersion is not installed"
            WriteNonTerminalError -Message "Outsystems development environment $MajorVersion is not installed"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $output"
        return $output
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
