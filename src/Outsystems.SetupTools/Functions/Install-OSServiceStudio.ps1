function Install-OSServiceStudio
{
    <#
    .SYNOPSIS
    Installs or updates the OutSystems development environment (Service Studio).

    .DESCRIPTION
    This will install or update the OutSystems Service Studio.
    if Service Studio is already installed it will check if version to be installed is higher than the current one and update it.

    .PARAMETER InstallDir
    Where Service Studio will be installed. If Service Studio is already installed, this parameter has no effect.
    If not specified will default to %ProgramFiles%\Outsystems

    .PARAMETER SourcePath
    If specified, the function will use the sources in that path. if not specified it will download the sources from the OutSystems repository.

    .PARAMETER Version
    The version to be installed.

    .PARAMETER FullPathInstallDir
    If specified, the InstallDir will not be appended with \<InstallerNamePrefix>-<Version>

    .EXAMPLE
    Install-OSServiceStudio -Version "11.55.35"

    .EXAMPLE
    Install-OSServiceStudio -Version "11.55.35" -InstallDir D:\Outsystems

    .EXAMPLE
    Install-OSServiceStudio -Version "11.55.35" -InstallDir D:\Outsystems -SourcePath c:\temp

    .EXAMPLE
    Install-OSServiceStudio -Version "11.55.35" -InstallDir D:\Outsystems -SourcePath c:\temp -FullPathInstallDir

    #>

    [CmdletBinding(DefaultParameterSetName = 'Remote')]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(ParameterSetName = 'Local')]
        [Parameter(ParameterSetName = 'Remote')]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir = $OSDefaultInstallDir,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Sources')]
        [string]$SourcePath,

        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Remote', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Version
    )

    dynamicParam
    {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($InstallDir)
        {
            $FullPathInstallDirAttrib = New-Object System.Management.Automation.ParameterAttribute
            $FullPathInstallDirAttribCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $FullPathInstallDirAttribCollection.Add($FullPathInstallDirAttrib)
            $FullPathInstallDirAttribCollection.Add($(New-Object Management.Automation.ValidateNotNullOrEmptyAttribute))
            $FullPathInstallDirParam = New-Object System.Management.Automation.RuntimeDefinedParameter('FullPathInstallDir', [switch], $FullPathInstallDirAttribCollection)

            $paramDictionary.Add('FullPathInstallDir', $FullPathInstallDirParam)
        }

        return $paramDictionary
    }

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.InstallResult'
            Success      = $true
            RebootNeeded = $false
            ExitCode     = 0
            Message      = 'Outsystems service studio successfully installed'
        }

        $osVersion = GetServiceStudioVersion -MajorVersion "$(([System.Version]$Version).Major)"
        $osInstallDir = GetServiceStudioInstallDir -MajorVersion "$(([System.Version]$Version).Major)"

        $InstallerNamePrefix = "DevelopmentEnvironment"
        $InstallerFolderPrefix = "Development Environment"
    }

    process
    {
        ### Check phase ###
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        if ([Version]"$Version" -gt [Version]"11.50.0.0")
        {
            $InstallerNamePrefix = "ServiceStudio"
            $InstallerFolderPrefix = "Service Studio"
        }

        if (-not $osVersion )
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems service studio is not installed"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Proceeding with normal installation"

            if (-not $PSBoundParameters.FullPathInstallDir.IsPresent)
            {
                $InstallDir = "$InstallDir\$InstallerFolderPrefix $(([System.Version]$Version).Major)"
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "FullPathInstallDir specified. Not appending \$InstallerFolderPrefix <version>"
            }
            $doInstall = $true
        }
        elseif ([version]$osVersion -lt [version]$Version)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems service studio already installed. Updating!!"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Current version $osVersion will be updated to $Version"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Ignoring InstallDir since this is an update"
            $InstallDir = $osInstallDir
            $doInstall = $true
        }
        elseif ([version]$osVersion -gt [version]$Version)
        {
            $doInstall = $false
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems service studio already installed with an higher version $osVersion"
            WriteNonTerminalError -Message "Outsystems service studio already installed with an higher version $osVersion"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = "Outsystems service studio already installed with an higher version $osVersion"

            return $installResult
        }
        else
        {
            $doInstall = $false
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems service studio already installed with the specified version $osVersion"
        }

        if ( $doInstall )
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing version $Version"
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing in $InstallDir"

            #Check if installer is local or is to be downloaded.
            switch ($PsCmdlet.ParameterSetName)
            {
                "Remote"
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SourcePath not specified. Downloading installer from repository"

                    $Installer = "$ENV:TEMP\$InstallerNamePrefix-$Version.exe"
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Saving installer to $Installer"

                    try
                    {
                        DownloadOSSources -URL "$OSRepoURL\$InstallerNamePrefix-$Version.exe" -SavePath $Installer
                    }
                    catch
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading the installer from repository. Check if version is correct"
                        WriteNonTerminalError -Message "Error downloading the installer from repository. Check if version is correct"

                        $installResult.Success = $false
                        $installResult.ExitCode = -1
                        $installResult.Message = 'Error downloading the installer from repository. Check if version is correct'

                        return $installResult
                    }

                }
                "Local"
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "SourcePath specified. Using the local installer"
                    $Installer = "$SourcePath\$InstallerNamePrefix-$Version.exe"
                }
            }

            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting the installation. This can take a while..."
                $result = Start-Process -FilePath $Installer -ArgumentList "/S /D=$InstallDir" -Wait -PassThru
                $exitCode = $result.ExitCode
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the service center installation"
                WriteNonTerminalError -Message "Error starting the service center installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error starting the service center installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems service studio successfully installed"
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Outsystems service studio successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing the Outsystems service studio. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing the Outsystems service studio. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = "Error installing the Outsystems service studio"

                    return $installResult
                }
            }

        }

        if ($installResult.RebootNeeded)
        {
            $installResult.ExitCode = 3010
            $installResult.Message = 'Outsystems service studio successfully installed but a reboot is needed'
        }
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
