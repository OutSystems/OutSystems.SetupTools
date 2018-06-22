Function Install-OSPlatformLicense
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    #Checking for admin rights
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights."
    If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console." }

    ## TODO: CHECKS MISSING ###
    ## Check if file exists etc etc...
    ## WILL NOT RETURN ERROR IF FAILS!!!!!

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "License path: $Path"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Uploading outsytems license"
    RunConfigTool -Path $OSInstallDir -Arguments $("/UploadLicense " + [char]34 + $Path + [char]34) -ErrorAction stop
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "License successfully uploaded!!"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}