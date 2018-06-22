Function Get-OSPlatformServerInstallDir
{
    <#
    .SYNOPSIS
    Returns where the Outsystems platform server is installed.

    .DESCRIPTION
    This will returns where the Outsystems platform server is installed. Will throw an exception if the platform is not installed.

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    $InstallDir = GetServerInstallDir

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Returning $InstallDir"
    return $InstallDir

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}