Function Install-OSDevEnvironment
{
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER InstallDir
    Parameter description

    .PARAMETER SourcePath
    Parameter description

    .PARAMETER Version
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    #TODO: Log file of the installer.

    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName='Local')]
        [Parameter(ParameterSetName='Remote')]
        [string]$InstallDir=$OSDefaultInstallDir,

        [Parameter(ParameterSetName='Local', Mandatory=$true)]
        [string]$SourcePath,

        [Parameter(ParameterSetName='Local', Mandatory=$true)]
        [Parameter(ParameterSetName='Remote', Mandatory=$true)]
        [string]$Version
    )

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    #Checking for admin rights
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking for admin rights."
    If( -not $(CheckRunAsAdmin) ) { Throw "Current user is not admin. Please open an elevated powershell console." }



    #Check if dev environment is already installed.
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Check if the dev environment major version is already installed."
    $OSDevVersion = Get-OSDevEnvironmentVersion -MajorVersion "$($([System.Version]$version).Major).$($([System.Version]$version).Minor)" -ErrorAction SilentlyContinue

    If(-not $OSDevVersion){
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems dev platform server not installed. Proceeding with the installation."
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing version: $Version"
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing in: $InstallDir"

        #Check if installer is local or is to be downloaded.
        switch ($PsCmdlet.ParameterSetName)
        {
            "Remote"
            {
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installer is remote."
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Downloading installer from: $OSRepoURL"

                $Installer = "$ENV:TEMP\DevelopmentEnvironment-$Version.exe"
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Save to: $Installer"

                Try {
                    DownloadOSSources -URL "$OSRepoURL\DevelopmentEnvironment-$Version.exe" -SavePath $Installer
                }
                Catch {
                    Throw "Error downloading the installer."
                }
            }
            "Local"
            {
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installer is local."
                Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Check if the installer is available in the supplied path."
                $Installer = "$SourcePath\DevelopmentEnvironment-$Version.exe"
                If( -not (Test-Path -Path $Installer)){ Throw "Cant file the setup file: $Installer"}
            }
        }

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Starting the installation."
        $IntReturnCode = Start-Process -FilePath $Installer -ArgumentList "/S", "/D=$InstallDir\Development Environment $($([System.Version]$version).Major).$($([System.Version]$version).Minor)" -Wait -PassThru
        If( $IntReturnCode.ExitCode -ne 0 ){
            throw "Error installing Outsystems dev environment. Exit code:$IntReturnCode.ExitCode"
        }

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems dev environment successfully installed."

    } Else {
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Outsystems dev environment is already installed. Version: $OSDevVersion"
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}