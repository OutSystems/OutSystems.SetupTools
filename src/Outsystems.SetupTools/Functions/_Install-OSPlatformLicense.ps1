Function Install-OSPlatformLicense
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Path
    )

    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    #Checking for admin rights
    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights."
    If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console." }

    ## TODO: CHECKS MISSING ###
    ## Check if file exists etc etc...
    ## WILL NOT RETURN ERROR IF FAILS!!!!!

    If($Path -and ($Path -ne "")){
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "License path specified on the command line. Path: $Path"
    } Else {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "License path NOT specified on the command line. Downloading from repo"
        $Path = $ENV:TEMP

        Try {
            DownloadOSSources -URL "$OSRepoURL\license.lic" -SavePath "$Path\license.lic"
            $Path = "$Path\license.lic"
        }
        Catch {
            Throw "Error downloading the installer."
        }
    }

    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing outsytems license"
    RunConfigTool -Path $OSInstallDir -Arguments $("/UploadLicense " + [char]34 + $Path + [char]34) -ErrorAction stop
    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "License successfully installed!!"

    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}