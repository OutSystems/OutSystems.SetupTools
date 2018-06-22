Function Install-OSPlatformLifetime
{
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER SCUser
    Parameter description

    .PARAMETER SCPass
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [string]$SCUser = $OSSCUser,
        [string]$SCPass = $OSSCPass
    )

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

#TODO!!!! CHECKS!!
    #Checking for admin rights
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights"
    If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console" }

    #Checking if platform server is installed.
    $OSInstallDir = Get-OSPlatformServerInstallDir -ErrorAction stop
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Platform server is installed. Version: $OSVersion"


    #Checking service center is installed and running.
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Check if the service center is installed"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service center is installed. Platform version: $OSVersion"
#TODO!!!! CHECKS!!

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing lifetime components. This can take a while."
    PublishSolution -Solution "$OSInstallDir\LifeTime.osp" -SCUser $SCUser -SCPass $OSSCPass -ErrorAction stop
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Lifetime components successfully installed!!"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}