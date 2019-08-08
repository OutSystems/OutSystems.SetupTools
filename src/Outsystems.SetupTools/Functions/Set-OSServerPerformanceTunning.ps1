function Set-OSServerPerformanceTunning
{
    <#
    .SYNOPSIS
    Configures Windows and IIS with the recommended performance settings for OutSystems.

    .DESCRIPTION
    This will configure Windows and IIS with the recommended performance settings for the OutSystems platform.
    An advanced configuration object can be used to control which sections are and are not done. Also, some values (namely, .NET and IIS upload size limits) can be set that will used to fine tune the respective settings.

    .PARAMETER IISNetCompilationPath
    Sets the IIS compilation folder.

    .PARAMETER IISHttpCompressionPath
    Sets the IIS compression folder.

    .PARAMETER AdvancedConfigurations
    Sets which of the sections should be completed, also allowing more specific configurations for some of these sections.

    This parameter is represent by an object with the following structure type (semi-JSONfied with the expected types enclosed in <>):

    {

        "SkipPlatformCheck" :  <BOOL>,
        "Sections" :
        {
            "ProcessSchedulingConfig" :
            {
                "ShouldBeSkipped" : <BOOL>
            },
            "NETConfig" :
            {
                "ShouldBeSkipped" :  <BOOL>,
                "NewMaxRequestLength" : <INT>
            },
            "IISUploadSizeLimitsConfig" :
            {
                "ShouldBeSkipped" : <BOOL>,
                "NewMaxAllowedContentLength" : <INT>
            },
            "IISConnectionsConfig" :
            {
                "ShouldBeSkipped" :  <BOOL>
            },
            "AppPoolsConfig" :
            {
                "ShouldBeSkipped" : <BOOL>,
                "SkipMoveAppsToOSAppPools" : <BOOL>
                "AppPoolsToForciblyCreateAndConfig" : <STRING[]>,
            }
        }
    }

    The aboved properties have the following semantic:

    > SkipPlatformCheck
        If true, proceeds even if the platform is not yet installed.


    > ProcessSchedulingConfig
        > ShouldBeSkipped
        If true, skips the section where Windows processor scheduling priority is set to 'background services'.


    > NETConfig
        > ShouldBeSkipped
        If true, skips the section where .NET upload size limits and execution timeout are configured.

        > NewMaxRequestLength
        The value in KBytes that applied to the .NET Framework "MaxRequestLength" property.


    > IISUploadSizeLimitsConfig
        > ShouldBeSkipped
        If true, skips the section where IIS upload size limits are configured.

        > NewMaxAllowedContentLength
        The value in Bytes that applied to the .NET Framework "MaxRequestLength" property.


    > IISConnectionsConfig
        > ShouldBeSkipped
        If true, skips the section where IIS is configured for unlimited connections.


    > AppPoolsConfig
        > ShouldBeSkipped
        If true, skips the section where OutSystems apps are moved to the respective OutSystems app pool.

        > SkipMoveAppsToOSAppPools
        If true, will not move OutSytems apps to the corresponding IIS app pools created by OutSystems (e.g. 'ServiceCenter' to 'ServiceCenterAppPool').

        > AppPoolsToForciblyCreateAndConfig
        If this list is not empty and has valid app pool names, will force the creation and configuration of the app pools.
        Valid app pool names: "OutSystemsApplications", "ServiceCenterAppPool", "LifeTimeAppPool".

    .EXAMPLE
    Set-OSServerPerformanceTunning

    .EXAMPLE
    Set-OSServerPerformanceTunning -IISNetCompilationPath d:\IISTemp\Compilation -IISHttpCompressionPath d:\IISTemp\Compression

    .EXAMPLE
    Set-OSServerPerformanceTunning -AdvancedConfigurations  @{ "Sections" = @{ "NETConfig" = @{ "ShouldBeSkipped" = $True } ; "IISConnectionsConfig" = @{ "ShouldBeSkipped" = $True } ; "ProcessSchedulingConfig" = @{ "ShouldBeSkipped" = $True } ; "IISUploadSizeLimitsConfig" = @{ "NewMaxAllowedContentLength" = 10000000 ; "ShouldBeSkipped" = $True } ; "AppPoolsConfig" = @{ "ShouldBeSkipped" = $True } } ; "SkipPlatformCheck" = $True ; "SkipMoveAppsToOSAppPools" = $True }

    #>

    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$IISNetCompilationPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$IISHttpCompressionPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [object]$AdvancedConfigurations
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osVersion = GetServerVersion
    }

    process
    {
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        $SkipPlatformCheck = $AdvancedConfigurations.SkipPlatformCheck
        $SkipProcessSchedulingConfig = $($AdvancedConfigurations.Sections.ProcessSchedulingConfig.ShouldBeSkipped)
        $SkipNETConfig = $($AdvancedConfigurations.Sections.NETConfig.ShouldBeSkipped)
        $SkipIISUploadSizeLimitsConfig = $($AdvancedConfigurations.Sections.IISUploadSizeLimitsConfig.ShouldBeSkipped)
        $SkipIISConnectionsConfig = $($AdvancedConfigurations.Sections.IISConnectionsConfig.ShouldBeSkipped)
        $SkipAppPoolsConfig = $($AdvancedConfigurations.Sections.AppPoolsConfig.ShouldBeSkipped)
        $SkipMoveAppsToOSAppPools = $($AdvancedConfigurations.Sections.AppPoolsConfig.SkipMoveAppsToOSAppPools)

        if ($(-not $SkipPlatformCheck) -and ($(-not $osVersion) -or $(-not $(GetServerInstallDir))))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            return
        }

        if (-not $SkipProcessSchedulingConfig)
        {
            # Configure process scheduling -- http://technet.microsoft.com/library/Cc976120
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring Windows processor scheduling priority to background services"
            try
            {
                RegWrite -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Type "Dword" -Value 24
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring processor scheduling priority"
                WriteNonTerminalError -Message "Error configuring processor scheduling priority"

                return
            }
        }

        if (-not $SkipNETConfig)
        {
            $MaxRequestLength = $AdvancedConfigurations.Sections.NETConfig.NewMaxRequestLength

            if (-not $MaxRequestLength)
            {
                $MaxRequestLength = $OSPerfTuningMaxRequestLength
            }

            # Configure .NET
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring .NET upload size limits and execution timeout (maxRequestLength = $MaxRequestLength, executionTimeout = $($OSPerfTuningExecutionTimeout.TotalSeconds) seconds)"
            try
            {
                SetDotNetLimits -UploadLimit $MaxRequestLength -ExecutionTimeout $OSPerfTuningExecutionTimeout
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring .NET settings"
                WriteNonTerminalError -Message "Error configuring .NET settings"

                return
            }
        }

        if (-not $SkipIISUploadSizeLimitsConfig)
        {
            $MaxAllowedContentLength = $AdvancedConfigurations.Sections.IISUploadSizeLimitsConfig.NewMaxAllowedContentLength

            if (-not $MaxAllowedContentLength)
            {
                $MaxAllowedContentLength = $OSPerfTuningMaxAllowedContentLength
            }

            # Configure IIS requests limits (Server Level)
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring IIS upload size limits (maxAllowedContentLength = $MaxAllowedContentLength)"
            try
            {
                SetWebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxAllowedContentLength" -Value $MaxAllowedContentLength
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring IIS upload size limits"
                WriteNonTerminalError -Message "Error configuring IIS upload size limits"

                return
            }
        }

        if (-not $SkipIISConnectionsConfig)
        {
            # Configure IIS for unlimited connections. (Default Web Site) - This should not be needed cause IIS defaults to maximum.
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring IIS for unlimited connections (MaxConnections = $OSPerfTuningMaxConnections)"
            try
            {
                SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].OverrideModeDefault" -Value "Allow"
                SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].allowDefinition" -Value "Everywhere"
                SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost/sites/site[@name='Default Web Site']" -Name "Limits" -Value @{MaxConnections = $OSPerfTuningMaxConnections }
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring IIS for unlimited connections"
                WriteNonTerminalError -Message "Error configuring IIS for unlimited connections"

                return
            }
        }

        if (-not $SkipAppPoolsConfig)
        {
            # Configure IIS Application Pools
            $DefaultWebSiteApps = $(Get-WebApplication -Site "Default Web Site").Path

            foreach ($Config in $OSIISConfig)
            {
                # Reset array at each loop
                $interestingApps = @()

                if (-not $SkipMoveAppsToOSAppPools)
                {
                    # Build an array with all matching Apps.
                    foreach ($appMatchPattern in $($Config.Match))
                    {
                        $interestingApps += $DefaultWebSiteApps | Where-Object -FilterScript { $_ -like $appMatchPattern }
                    }
                }

                # if an app was found
                $HasAppsToMove = ($interestingApps.Count -gt 0)

                # if the app pool was set to be forcibly configured
                $AppPoolsToForciblyCreateAndConfig = $($AdvancedConfigurations.Sections.AppPoolsConfig.AppPoolsToForciblyCreateAndConfig)
                $ForceCreateAndConfigAppPool = ($AppPoolsToForciblyCreateAndConfig -and $AppPoolsToForciblyCreateAndConfig.Contains($Config.PoolName))

                # if we should try to configure app pool
                if ($HasAppsToMove -or $ForceCreateAndConfigAppPool)
                {
                    # Check if AppPool exists. if not, create a new one.
                    if (-not $(Get-ChildItem -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction SilentlyContinue))
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating IIS Application Pool $($Config.PoolName)"
                        try
                        {
                            New-Item -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction Stop | Out-Null
                        }
                        catch
                        {
                            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating Application Pool $($Config.PoolName)"
                            WriteNonTerminalError -Message "Error creating AppPool $($Config.PoolName)"

                            return
                        }
                    }

                    # Configure the AppPool
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring IIS Application Pool $($Config.PoolName)"
                    $AppPoolItem = Get-Item "IIS:\AppPools\$($Config.PoolName)"

                    # Commit everything on one shot
                    Start-WebCommitDelay

                    $AppPoolItem.managedRuntimeVersion = "v4.0"

                    $AppPoolItem.recycling.periodicRestart.time = [TimeSpan]::FromMinutes(0)
                    $AppPoolItem.recycling.periodicRestart.requests = 0

                    $AppPoolItem.recycling.logEventOnRecycle = "Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory"
                    $AppPoolItem.processModel.idleTimeout = [TimeSpan]::FromMinutes(0)

                    $AppPoolItem.failure.rapidFailProtection = $false

                    $AppPoolItem.recycling.periodicRestart.privateMemory = [int]($(GetInstalledRAM) * 1MB * ($($Config.MemoryPercentage) / 100))

                    # Version specific config
                    switch ("$(([version]$osVersion).Major)")
                    {
                        '10'
                        {
                            $AppPoolItem.managedPipelineMode = "Classic"
                        }
                        '11'
                        {
                            $AppPoolItem.managedPipelineMode = "Integrated"
                        }
                    }

                    $AppPoolItem | Set-Item

                    # Clear periodic restarts schedule
                    $AppPoolItem | Clear-ItemProperty -Name recycling.periodicRestart.schedule

                    # Explicit cher here for clarity, the foreach implicity ensures this
                    if ($HasAppsToMove)
                    {
                        # Move the InterestingApp to the AppPool
                        foreach ($InterestingApp In $interestingApps)
                        {
                            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Moving Application $InterestingApp to Application Pool $($Config.PoolName)"
                            Set-ItemProperty -Path "IIS:\Sites\Default Web Site$InterestingApp" -Name applicationPool -Value $($Config.PoolName)
                        }
                    }

                    # Commit everything in one shot
                    try
                    {
                        Stop-WebCommitDelay
                    }
                    catch
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error applying setting to Application Pool $($Config.PoolName)"
                        WriteNonTerminalError -Message "Error applying setting to Application Pool $($Config.PoolName)"

                        return
                    }

                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Application Pool $($Config.PoolName) configuration done"
                }
            }
        }

        # Configure .NET compilation folder (Server Level)
        if ($IISNetCompilationPath)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IISNetCompilationPath specified on the command line"
            if (-not (Test-Path -Path $IISNetCompilationPath))
            {
                try
                {
                    New-Item -Path $IISNetCompilationPath -ItemType directory -Force -ErrorAction Stop | Out-Null
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the IIS Net compilation folder"
                    WriteNonTerminalError -Message "Error creating the IIS Net compilation folder"

                    return
                }
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Changing IIS compilation folder to $IISNetCompilationPath"
            try
            {
                SetWebConfigurationProperty -PSPath "MACHINE/WEBROOT" -Filter "system.web/compilation" -Name 'tempDirectory' -Value $IISNetCompilationPath
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the IIS compilation folder"
                WriteNonTerminalError -Message "Error setting the IIS compilation folder"

                return
            }
        }

        # Configure HTTP Compression folder (Server Level)
        if ($IISHttpCompressionPath)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IISHttpCompressionPath specified on the command line"
            if (-not (Test-Path -Path $IISHttpCompressionPath))
            {
                try
                {
                    New-Item -Path $IISHttpCompressionPath -ItemType directory -Force -ErrorAction Stop | Out-Null
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the IIS HTTP compression folder"
                    WriteNonTerminalError -Message "Error creating the IIS HTTP compression folder"

                    return
                }
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Changing IIS HTTP compression folder to $IISHttpCompressionPath"
            try
            {
                SetWebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST"  -Filter "system.webServer/httpCompression" -Name "directory" -Value $IISHttpCompressionPath
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the IIS HTTP compression folder"
                WriteNonTerminalError -Message "Error setting the IIS HTTP compression folder"

                return
            }
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
