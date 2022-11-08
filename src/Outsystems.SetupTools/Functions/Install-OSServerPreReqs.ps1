function Install-OSServerPreReqs
{
    <#
    .SYNOPSIS
    Installs the pre-requisites for the OutSystems platform server.

    .DESCRIPTION
    This will install the pre-requisites for the OutSystems platform server.
    You should run first the Test-OSServerSoftwareReqs and the Test-OSServerHardwareReqs cmdlets to check if the server is supported for OutSystems.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    Accepted values: 10 or 11.

    .PARAMETER MinorVersion
    Specifies the platform minor version.
    Accepted values: one or more digit numbers.

    .PARAMETER PatchVersion
    Specifies the platform patch version.
    Accepted values: single digits only.

    .PARAMETER InstallIISMgmtConsole
    Specifies if the IIS Managament Console will be installed.
    On servers without GUI this feature can't be installed so you should set this parameter to $false.

    .PARAMETER SourcePath
    Specifies a local path having the pre-requisites binaries.

    .PARAMETER OnlyMostRecentHostingBundlePackage
    Specifies whether the installer should skip the installation of .NET Core Runtime and the ASP.NET Runtime and remove previous installations of the Hosting Bundle.
    Accepted values: $false and $true. By default this is set to $false.

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "10"

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -MinorVersion "12" -PatchVersion "3"

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false

     .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false -SourcePath "c:\downloads"

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('\d\d+(\.0)?$')]
        [string]$MajorVersion,

        [Parameter()]
        [Alias('Sources')]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter()]
        [bool]$InstallIISMgmtConsole = $true,

        [Parameter()]
        [ValidatePattern('\d+')]
        [string]$MinorVersion = "0",

        [Parameter()]
        [ValidatePattern('\d$')]
        [string]$PatchVersion = "0",

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OnlyMostRecentHostingBundlePackage = "0"
    )

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
            Message      = 'OutSystems platform server pre-requisites successfully installed'
        }

        #The MajorVersion parameter supports 11.0 or 11. Therefore, we need to remove the '.0' part
        $MajorVersion = $MajorVersion.replace(".0", "")
    }

    process
    {
        # Check if user is admin
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        # Base Windows Features
        $winFeatures = $OSWindowsFeaturesBase

        # Check if IISMgmtConsole is needed. In a server without GUI, the management console is not available
        if ($InstallIISMgmtConsole)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding IIS Management console feature to the Windows Features list"
            $winFeatures += "Web-Mgmt-Console"
        }

        #region check
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Checking pre-requisites for OutSystems major version $MajorVersion"

        # MS Buld Tools minimum version is different depending on the Platform Major Version
        # 10 : 2015 and 2015 Update 3 are allowed but 2017 is not
        # 11 : All the above three are allowed
        $MSBuildInstallInfo = $(GetMSBuildToolsInstallInfo)

        if (-not $(IsMSBuildToolsVersionValid -MajorVersion $MajorVersion -InstallInfo $MSBuildInstallInfo))
        {
            if ($MSBuildInstallInfo.LatestVersionInstalled)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$($MSBuildInstallInfo.LatestVersionInstalled) found but this version is not supported by OutSystems. We will try to download and install MS Build Tools 2015."
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "No valid MS Build Tools version found, this is an OutSystems requirement. We will try to download and install MS Build Tools 2015."
            }

            $installBuildTools = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$($MSBuildInstallInfo.LatestVersionInstalled) found"

            $installResult.RebootNeeded = $MSBuildInstallInfo.RebootNeeded
        }

        # Version specific pre-reqs checks.
        switch ($MajorVersion)
        {
            '10'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding Microsoft Message Queueing feature to the Windows Features list since its required for OutSystems $MajorVersion"
                $winFeatures += "MSMQ"
            }
            default
            {
                # Check .NET Core / .NET Windows Server Hosting version
                $fullVersion = [version]"$MajorVersion.$MinorVersion.$PatchVersion.0"
                if ($fullVersion -eq [version]"$MajorVersion.0.0.0")
                {
                    # Here means that no specific minor and patch version were specified
                    # So we install all versions
                    $installDotNetCoreHostingBundle2 = $true
                    $installDotNetCoreHostingBundle3 = $true
                    $installDotNetHostingBundle6 = $true
                }
                elseif ($fullVersion -ge [version]"11.17.1.0")
                {
                    # Here means that minor and patch version were specified and we are equal or above version 11.17.1.0
                    # We install .NET 6.0 only
                    $installDotNetCoreHostingBundle2 = $false
                    $installDotNetCoreHostingBundle3 = $false
                    $installDotNetHostingBundle6 = $true
                    $mostRecentHostingBundleVersion = [version]$script:OSDotNetCoreHostingBundleReq['6']['Version']
                }
                elseif ($fullVersion -ge [version]"11.12.2.0")
                {
                    # Here means that minor and patch version were specified and we are equal or above version 11.12.2.0
                    # We install version 3 only
                    $installDotNetCoreHostingBundle2 = $false
                    $installDotNetCoreHostingBundle3 = $true
                    $installDotNetHostingBundle6 = $false
                    $mostRecentHostingBundleVersion = [version]$script:OSDotNetCoreHostingBundleReq['3']['Version']
                }
                else
                {
                    # Here means that minor and patch version were specified and we are below version 11.12.2.0
                    # We install version 2 only
                    $installDotNetCoreHostingBundle2 = $true
                    $installDotNetCoreHostingBundle3 = $false
                    $installDotNetHostingBundle6 = $false
                    $mostRecentHostingBundleVersion = [version]$script:OSDotNetCoreHostingBundleReq['2']['Version']
                }

                foreach ($version in GetDotNetCoreHostingBundleVersions)
                {
                    # Check .NET Core 2.1
                    if (([version]$version).Major -eq 2 -and ([version]$version) -ge [version]$script:OSDotNetCoreHostingBundleReq['2']['Version']) {
                        $installDotNetCoreHostingBundle2 = $false
                    }
                    # Check .NET Core 3.1
                    if (([version]$version).Major -eq 3 -and ([version]$version) -ge [version]$script:OSDotNetCoreHostingBundleReq['3']['Version']) {
                        $installDotNetCoreHostingBundle3 = $false
                    }
                }

                foreach ($version in GetDotNetHostingBundleVersions)
                {
                    # Check .NET 6.0
                    if (([version]$version).Major -eq 6 -and ([version]$version) -ge [version]$script:OSDotNetCoreHostingBundleReq['6']['Version']) {
                        $installDotNetHostingBundle6 = $false
                    }
                }

                if ($installDotNetCoreHostingBundle2) {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET Core Windows Server Hosting version 2.1 for OutSystems $MajorVersion not found. We will try to download and install the latest .NET Core Windows Server Hosting bundle"
                }
                if ($installDotNetCoreHostingBundle3) {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET Core Windows Server Hosting version 3.1 for OutSystems $MajorVersion not found. We will try to download and install the latest .NET Core Windows Server Hosting bundle"
                }
                if ($installDotNetHostingBundle6) {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET Windows Server Hosting version 6.0.6 for OutSystems $MajorVersion not found. We will try to download and install the latest .NET Windows Server Hosting bundle"
                }
            }
        }

        # Check .NET version
        if ($(GetDotNet4Version) -lt $script:OSDotNetReqForMajor[$MajorVersion]['Value'])
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion not found. We will try to download and install NET $($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion'])"
            $installDotNet = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET version for OutSystems $MajorVersion found"
        }
        #endregion

        #region install
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing pre-requisites for OutSystems major version $MajorVersion"

        # Windows Features
        # Exit codes available at: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc733119(v=ws.11)
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Windows Features"
        try
        {
            $result = InstallWindowsFeatures -Features $winFeatures
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the Windows Features installation"
            WriteNonTerminalError -Message "Error starting the Windows Features installation"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = "Error starting the Windows Features installation"

            return $installResult
        }

        if ($result.Success)
        {
            if ($result.RestartNeeded.value__ -ne 1)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows Features successfully installed but a reboot is needed."
                $installResult.RebootNeeded = $true
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows Features successfully installed"
            }
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing Windows Features. Exit code: $($result.ExitCode.value__)"
            WriteNonTerminalError -Message "Error installing Windows Features. Exit code: $($result.ExitCode.value__)"

            $installResult.Success = $false
            $installResult.ExitCode = $result.ExitCode.value__
            $installResult.Message = 'Error installing Windows Features'

            return $installResult
        }

        # Install build tools 2015
        if ($installBuildTools)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Build Tools 2015"
                $exitCode = InstallBuildTools -Sources $SourcePath
            }
            catch [System.IO.FileNotFoundException]
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Build Tools installer not found"
                WriteNonTerminalError -Message "Build Tools installer not found"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Build Tools installer not found'

                return $installResult
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the Build Tools installation"
                WriteNonTerminalError -Message "Error downloading or starting the Build Tools installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the Build Tools installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools 2015 successfully installed"
                }

                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Build Tools 2015 successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing Build Tools 2015. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing Build Tools 2015. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing Build Tools 2015'

                    return $installResult
                }
            }
        }

        # Install .NET Core Windows Server Hosting bundle version 2.1
        if ($installDotNetCoreHostingBundle2)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET Core 2.1 Windows Server Hosting bundle"
                $exitCode = InstallDotNetCoreHostingBundle -MajorVersion '2' -Sources $SourcePath
            }
            catch [System.IO.FileNotFoundException]
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message ".NET Core 2.1 installer not found"
                WriteNonTerminalError -Message ".NET Core 2.1 installer not found"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = '.NET Core 2.1 installer not found'

                return $installResult
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET Core 2.1 installation"
                WriteNonTerminalError -Message "Error downloading or starting the .NET Core 2.1 installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the .NET Core 2.1 installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Core 2.1 Windows Server Hosting bundle successfully installed."
                }

                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Core 2.1 Windows Server Hosting bundle successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET Core 2.1 Windows Server Hosting bundle. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET Core 2.1 Windows Server Hosting bundle. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing .NET Core 2.1 Windows Server Hosting bundle'

                    return $installResult
                }
            }

        }

        # Install .NET Core Windows Server Hosting bundle version 3.1
        if ($installDotNetCoreHostingBundle3)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET Core 3.1 Windows Server Hosting bundle"
                $exitCode = InstallDotNetCoreHostingBundle -MajorVersion '3' -Sources $SourcePath
            }
            catch [System.IO.FileNotFoundException]
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message ".NET Core 3.1 installer not found"
                WriteNonTerminalError -Message ".NET Core 3.1 installer not found"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = '.NET Core 3.1 installer not found'

                return $installResult
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET Core 3.1 installation"
                WriteNonTerminalError -Message "Error downloading or starting the .NET Core 3.1 installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the .NET Core 3.1 installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Core 3.1 Windows Server Hosting bundle successfully installed."
                }

                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Core 3.1 Windows Server Hosting bundle successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET Core 3.1 Windows Server Hosting bundle. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET Core 3.1 Windows Server Hosting bundle. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing .NET Core 3.1 Windows Server Hosting bundle'

                    return $installResult
                }
            }
        }

        # Install .NET Windows Server Hosting bundle version 6
        if ($installDotNetHostingBundle6)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET 6.0 Windows Server Hosting bundle"
                $exitCode = InstallDotNetCoreHostingBundle -MajorVersion '6' -Sources $SourcePath -OnlyMostRecentHostingBundlePackage $OnlyMostRecentHostingBundlePackage
            }
            catch [System.IO.FileNotFoundException]
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message ".NET 6.0 installer not found"
                WriteNonTerminalError -Message ".NET 6.0 installer not found"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = '.NET 6.0 installer not found'

                return $installResult
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET 6.0 installation"
                WriteNonTerminalError -Message "Error downloading or starting the .NET 6.0 installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the .NET 6.0 installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 6.0 Windows Server Hosting bundle successfully installed."
                }

                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 6.0 Windows Server Hosting bundle successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET 6.0 Windows Server Hosting bundle. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET 6.0 Windows Server Hosting bundle. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing .NET 6.0 Windows Server Hosting bundle'

                    return $installResult
                }
            }
        }

        if ($mostRecentHostingBundleVersion -and $OnlyMostRecentHostingBundlePackage -eq "1")
        {
            $isInstalled = IsDotNetCoreUninstallToolInstalled
            if (-not $isInstalled)
            {
                try
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET Uninstall Tool"
                    $exitCode = InstallDotNetCoreUninstallTool -MajorVersion '1.5' -Sources $SourcePath
                }
                catch [System.IO.FileNotFoundException]
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message ".NET Uninstall Tool installer not found"
                    WriteNonTerminalError -Message ".NET Uninstall Tool installer not found"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = '.NET Uninstall Tool installer not found'

                    return $installResult
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET Uninstall Tool installation"
                    WriteNonTerminalError -Message "Error downloading or starting the .NET Uninstall Tool installation"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = 'Error downloading or starting the .NET Uninstall Tool installation'

                    return $installResult
                }
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET Uninstall Tool found"
            }

            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Uninstalling previous ASP.NET Core Runtime packages"
            $isUninstalled = UninstallPreviousDotNetCorePackages -Package '--aspnet-runtime' -Version $mostRecentHostingBundleVersion
            if (-not $isUninstalled)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error uninstalling previous ASP.NET Core Runtime packages"
                WriteNonTerminalError -Message "Error uninstalling previous ASP.NET Core Runtime packages"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error uninstalling previous ASP.NET Core Runtime packages'

                return $installResult
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Uninstalling previous .NET Core Runtime packages"
            $isUninstalled = UninstallPreviousDotNetCorePackages -Package '--runtime' -Version $mostRecentHostingBundleVersion
            if (-not $isUninstalled)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error uninstalling previous .NET Core Runtime packages"
                WriteNonTerminalError -Message "Error uninstalling previous .NET Core Runtime packages"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error uninstalling previous .NET Core Runtime packages'

                return $installResult
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Uninstalling previous .NET Hosting Bundle packages"
            $isUninstalled = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -Version $mostRecentHostingBundleVersion
            if (-not $isUninstalled)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error uninstalling previous .NET Hosting Bundle packages"
                WriteNonTerminalError -Message "Error uninstalling previous .NET Hosting Bundle packages"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error uninstalling previous .NET Hosting Bundle packages'

                return $installResult
            }
        }

        # Install .NET
        if ($installDotNet)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET $($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion'])"
                $exitCode = InstallDotNet -Sources $SourcePath -URL $script:OSDotNetReqForMajor[$MajorVersion]['ToInstallDownloadURL']
            }
            catch [System.IO.FileNotFoundException]
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message ".NET installer not found"
                WriteNonTerminalError -Message ".NET installer not found"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = '.NET installer not found'

                return $installResult
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET installation"
                WriteNonTerminalError -Message "Error downloading or starting the .NET installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the .NET installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET $($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion']) successfully installed"
                }

                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET $($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion']) successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET $($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion']). Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET $($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion']). Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = "Error installing .NET $($script:OSDotNetReqForMajor[$MajorVersion]['ToInstallVersion'])"

                    return $installResult
                }
            }
        }
        #endregion

        #region configuration
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring pre-requisites for OutSystems major version $MajorVersion"

        #Configure the WMI windows service
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the WMI windows service"
        try
        {
            ConfigureServiceWMI
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the WMI service"
            WriteNonTerminalError -Message "Error configuring the WMI service"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error configuring the WMI service'

            return $installResult
        }

        #Configure the Windows search service
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring the Windows search service"
        try
        {
            ConfigureServiceWindowsSearch
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the Windows search service"
            WriteNonTerminalError -Message "Error configuring the Windows search service"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error configuring the Windows search service'

            return $installResult
        }

        #Disable FIPS compliant algorithms checks
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Disabling FIPS compliant algorithms checks"
        try
        {
            DisableFIPS
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error disabling FIPS compliant algorithms checks"
            WriteNonTerminalError -Message "Error disabling FIPS compliant algorithms checks"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Error disabling FIPS compliant algorithms checks'

            return $installResult
        }

        #Configure event log
        foreach ($eventLog in $OSWinEventLogName)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring $eventLog Event Log"
            try
            {
                ConfigureWindowsEventLog -LogName $eventLog -LogSize $OSWinEventLogSize -LogOverflowAction $OSWinEventLogOverflowAction
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring $eventLog Event Log"
                WriteNonTerminalError -Message "Error configuring $eventLog Event Log"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = "Error configuring $eventLog Event Log"

                return $installResult
            }
        }

        # Version specific configuration.
        switch ($MajorVersion)
        {
            '10'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configure Message Queuing service to to always try to contact a message queue server when running on a server registered in a domain."
                try
                {
                    ConfigureMSMQDomainServer
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the Message Queuing service"
                    WriteNonTerminalError -Message "Error configuring the Message Queuing service"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = 'Error configuring the Message Queuing service'

                    return $installResult
                }
            }
            default
            {
                # Nothing to be done here
            }
        }
        #endregion

        if ($installResult.RebootNeeded)
        {
            $installResult.ExitCode = 3010
            $installResult.Message = 'OutSystems platform server pre-requisites successfully installed but a reboot is required'
        }
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
