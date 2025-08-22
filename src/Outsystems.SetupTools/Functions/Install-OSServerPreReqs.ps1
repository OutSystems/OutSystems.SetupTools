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
    Accepted values: 11.

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

    .PARAMETER RemovePreviousHostingBundlePackages
    Specifies whether the installer should remove previous installations of the Hosting Bundle.
    Accepted values: $false and $true. By default this is set to $false.

    .PARAMETER SkipRuntimePackages
    Specifies whether the installer should skip the installation of .NET Core Runtime and the ASP.NET Runtime.
    Accepted values: $false and $true. By default this is set to $true.

    .PARAMETER InstallMSBuildTools
    Specifies whether the installer should install Microsoft Build Tools 2015.
    Accepted values: $false and $true. By default this is set to $false.

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11"

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -MinorVersion "23" -PatchVersion "0"

    .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false

     .EXAMPLE
    Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false -SourcePath "c:\downloads"

    #>

    [CmdletBinding()]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('11(\.0)?$')]
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
        [bool]$RemovePreviousHostingBundlePackages = $false,

        [Parameter()]
        [bool]$SkipRuntimePackages = $true,

        [Parameter(Mandatory = $false)]
        [bool]$InstallMSBuildTools = $false
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

        if ($MinorVersion -lt 23)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minor version was not specified or it was less than 23. Minimum version will be set to 23."
            $MinorVersion = "23"
        }
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

        if (-not $(ValidateVersion -Version [System.Version]("$($MajorVersion).$($MinorVersion).$($PatchVersion).0") -Major "11" -Minor "23" -Build "0"))
        {
            WriteNonTerminalError -Message 'Unsupported version installed version'
            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Unsupported version installed version'

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
        # 11 : 2015 and 2015 Update 3 are allowed, and 2017
        function ValidateMSBuildTools
        {
            $MSBuildInstallInfo = $(GetMSBuildToolsInstallInfo)

            if (-not $(IsMSBuildToolsVersionValid -InstallInfo $MSBuildInstallInfo))
            {
                if ($MSBuildInstallInfo.LatestVersionInstalled)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$($MSBuildInstallInfo.LatestVersionInstalled) found but this version is not supported by OutSystems. We will try to download and install MS Build Tools 2015."
                }
                else
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "No valid MS Build Tools version found, this is an OutSystems requirement. We will try to download and install MS Build Tools 2015."
                }
                return $true
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$($MSBuildInstallInfo.LatestVersionInstalled) found"

                $installResult.RebootNeeded = $MSBuildInstallInfo.RebootNeeded
            }

            return $false
        }

        # Version specific pre-reqs checks.
        $fullVersion = [version]"$MajorVersion.$MinorVersion.$PatchVersion.0"
        if (($fullVersion -lt [version]"11.35.0.0") -or $InstallMSBuildTools)
        {
            $installBuildTools = ValidateMSBuildTools
        }
        else
        {
            $installBuildTools = $false
        }

        if ($fullVersion -eq [version]"$MajorVersion.0.0.0")
        {
            # Here means that no specific minor and patch version were specified
            # So we install all versions
            $installDotNetHostingBundle6 = $true
            $installDotNetHostingBundle8 = $true
        }
        elseif ($fullVersion -ge [version]"11.27.0.0")
        {
            # Here means that minor and patch version were specified and we are equal or above version 11.27.0.0
            # We install .NET 8.0 only
            $installDotNetHostingBundle6 = $false
            $installDotNetHostingBundle8 = $true
            $mostRecentHostingBundleVersion = [version]$script:OSDotNetHostingBundleReq['8']['Version']
        }
        else
        {
            # Here means that minor and patch version were specified and we are below version 11.27.0.0
            $installDotNetHostingBundle6 = $true
            $installDotNetHostingBundle8 = $false
            $mostRecentHostingBundleVersion = [version]$script:OSDotNetHostingBundleReq['6']['Version']
        }

        foreach ($version in GetDotNetHostingBundleVersions)
        {
            # Check .NET 6.0
            if (([version]$version).Major -eq 6 -and ([version]$version) -ge [version]$script:OSDotNetHostingBundleReq['6']['Version']) {
                $installDotNetHostingBundle6 = $false
            }
            # Check .NET 8.0
            if (([version]$version).Major -eq 8 -and ([version]$version) -ge [version]$script:OSDotNetHostingBundleReq['8']['Version']) {
                $installDotNetHostingBundle8 = $false
            }
        }

        if ($installDotNetHostingBundle6) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET Windows Server Hosting version 6.0.6 for OutSystems $MajorVersion not found. We will try to download and install the latest .NET Windows Server Hosting bundle"
        }
        if ($installDotNetHostingBundle8) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Minimum .NET Windows Server Hosting version 8.0.0 for OutSystems $MajorVersion not found. We will try to download and install the latest .NET Windows Server Hosting bundle"
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

        # Install .NET Windows Server Hosting bundle version 6
        if ($installDotNetHostingBundle6)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET 6.0 Windows Server Hosting bundle"
                $exitCode = InstallDotNetHostingBundle -MajorVersion '6' -Sources $SourcePath -SkipRuntimePackages $SkipRuntimePackages
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

        # Install .NET Windows Server Hosting bundle version 8
        if ($installDotNetHostingBundle8)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing .NET 8.0 Windows Server Hosting bundle"
                $exitCode = InstallDotNetHostingBundle -MajorVersion '8' -Sources $SourcePath -SkipRuntimePackages $SkipRuntimePackages
            }
            catch [System.IO.FileNotFoundException]
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message ".NET 8.0 installer not found"
                WriteNonTerminalError -Message ".NET 8.0 installer not found"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = '.NET 8.0 installer not found'

                return $installResult
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the .NET 8.0 installation"
                WriteNonTerminalError -Message "Error downloading or starting the .NET 8.0 installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the .NET 8.0 installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 8.0 Windows Server Hosting bundle successfully installed."
                }

                { $_ -in 3010, 3011 }
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message ".NET 8.0 Windows Server Hosting bundle successfully installed but a reboot is needed. Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing .NET 8.0 Windows Server Hosting bundle. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing .NET 8.0 Windows Server Hosting bundle. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing .NET 8.0 Windows Server Hosting bundle'

                    return $installResult
                }
            }
        }


        if ($mostRecentHostingBundleVersion -and $RemovePreviousHostingBundlePackages)
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
                    return LogErrorMessage -InstallResult $installResult -Message '.NET Uninstall Tool installer not found'
                }
                catch
                {
                    return LogErrorMessage -InstallResult $installResult -Message 'Error downloading or starting the .NET Uninstall Tool installation'
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
                return LogErrorMessage -InstallResult $installResult -Message 'Error uninstalling previous ASP.NET Core Runtime packages'
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Uninstalling previous .NET Core Runtime packages"
            $isUninstalled = UninstallPreviousDotNetCorePackages -Package '--runtime' -Version $mostRecentHostingBundleVersion
            if (-not $isUninstalled)
            {
                return LogErrorMessage -InstallResult $installResult -Message 'Error uninstalling previous .NET Core Runtime packages'
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Uninstalling previous .NET Hosting Bundle packages"
            $isUninstalled = UninstallPreviousDotNetCorePackages -Package '--hosting-bundle' -Version $mostRecentHostingBundleVersion
            if (-not $isUninstalled)
            {
                return LogErrorMessage -InstallResult $installResult -Message 'Error uninstalling previous .NET Hosting Bundle packages'
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

        # Disable FIPS requirement only for versions lower than 11.38.0
        if ([int]$MajorVersion -lt 11 -or ([int]$MajorVersion -eq 11 -and [int]$MinorVersion -lt 38)) {
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
