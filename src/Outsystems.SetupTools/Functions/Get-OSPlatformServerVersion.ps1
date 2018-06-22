Function Get-OSPlatformServerVersion
{
    <#
    .SYNOPSIS
    Returns the current Outsystems platform version

    .DESCRIPTION
    This will returns the current Outsystems platform installed version. Will throw an exception if the platform is not installed.

    #>

    [CmdletBinding()]
    [OutputType([System.Version])]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $Version = GetServerVersion

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning $Version"
    Return [System.Version]$Version

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}