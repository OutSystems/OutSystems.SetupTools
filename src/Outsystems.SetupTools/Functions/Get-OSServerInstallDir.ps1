function Get-OSServerInstallDir
{
    <#
    .SYNOPSIS
    Returns where the OutSystems platform server is installed.

    .DESCRIPTION
    This will returns where the OutSystems platform server is installed.

    .EXAMPLE
    Get-OSServerInstallDir

    #>

    [CmdletBinding()]
    [OutputType('System.String')]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        $output = GetServerInstallDir

        if (-not $output)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

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
