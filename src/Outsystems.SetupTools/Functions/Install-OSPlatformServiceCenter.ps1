Function Install-OSPlatformServiceCenter
{
    [CmdletBinding()]
    param ()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    #Checking for admin rights
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights"
    If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console" }

    #Checking if platform server is installed.
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Check if the platform server is installed"
    $OSVersion = Get-OSPlatformServerVersion -ErrorAction stop
    $OSInstallDir = Get-OSPlatformServerInstallDir -ErrorAction stop
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Platform server is installed. Version: $OSVersion"

    ### TODO!!!!  #Checking service center is installed and running.

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing Service Center. This can take a while."
    InstallOSSystemCenter -ErrorAction stop
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service Center successfully installed!!"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}