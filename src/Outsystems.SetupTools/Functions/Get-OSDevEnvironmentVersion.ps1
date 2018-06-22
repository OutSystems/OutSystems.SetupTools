Function Get-OSDevEnvironmentVersion
{
    <#
    .SYNOPSIS
    Returns the Outsystems development environment installed version.

    .DESCRIPTION
    This will returns the Outsystems platform installed version. Cause you can have multiple development environments installed, you need to specify the major version.
    Will throw an exception if the platform is not installed.

    .PARAMETER MajorVersion
    Major version. 9.0, 9.1, 10.0, 11.0, ...

    .EXAMPLE
    Get-OSDevEnvironmentVersion -MajorVersion 10.0

    #>
    [CmdletBinding()]
    [OutputType([System.Version])]
    param (
        [Parameter(Mandatory=$true, HelpMessage="10.0")]
        [string]$MajorVersion
    )

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\Service Studio $MajorVersion"

    try {
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "Service Studio $MajorVersion" -ErrorAction Stop)."Service Studio $MajorVersion"
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"
        return [System.Version]$output
    } catch {
        Throw "Outsystems development environment $MajorVersion is not installed"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}