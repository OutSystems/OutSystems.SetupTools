Function Install-OSPlatformSysComponents
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

    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    #Checking for admin rights
    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights"
    If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console" }

    #Checking if platform server is installed.
    $OSInstallDir = Get-OSPlatformServerInstallDir -ErrorAction stop
    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Platform server is installed. Version: $OSVersion"

#TODO!!!! CHECKS!!
    #Checking service center is installed and running.
    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Check if the service center is installed"
    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service center is installed. Platform version: $OSVersion"
#TODO!!!! CHECKS!!

    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing system components. This can take a while."
    PublishSolution -Solution "$OSInstallDir\System_Components.osp" -SCUser $SCUser -SCPass $OSSCPass -ErrorAction stop
    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "System components successfully installed!!"

    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}