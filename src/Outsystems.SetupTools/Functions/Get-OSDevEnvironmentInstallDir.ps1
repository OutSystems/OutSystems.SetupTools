Function Get-OSDevEnvironmentInstallDir
{
    <#
    .SYNOPSIS
    Returns where the Outsystems development environment is installed.

    .DESCRIPTION
    This will returns where the Outsystems development environment is installed. Cause you can have multiple development environments installed, you need to specify the major version.
    Will throw an exception if the platform is not installed.

    .PARAMETER MajorVersion
    Major version. 9.0, 9.1, 10.0, 11.0, ...

    .EXAMPLE
    Get-OSDevEnvironmentInstallDir -MajorVersion 10.0

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true, HelpMessage="10.0")]
        [string]$MajorVersion
    )

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Getting the contents of the registry key HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion\(Default)"

    try{
        $output = $(Get-ItemProperty -Path "HKLM:SOFTWARE\OutSystems\Installer\Service Studio $MajorVersion" -Name "(default)" -ErrorAction Stop)."(default)"
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $output"

    } catch {
        Throw "Outsystems development environment $MajorVersion is not installed"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    return $output
}