function Set-OSServerPerformanceTunning
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]

    <#
    .SYNOPSIS
    Configures windows and IIS with the recommended performance settings for OutSystems.

    .DESCRIPTION
    This will configure Windows and IIS with the recommended performance settings for the OutSystems platform.

    .PARAMETER IISNetCompilationPath
    Sets the IIS compilation folder.

    .PARAMETER IISHttpCompressionPath
    Sets the IIS compression folder.

    .EXAMPLE
    Set-OSServerPerformanceTunning

    .EXAMPLE
    Set-OSServerPerformanceTunning -IISNetCompilationPath d:\IISTemp\Compilation -IISHttpCompressionPath d:\IISTemp\Compression

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$IISNetCompilationPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$IISHttpCompressionPath
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
    }

    process
    {

        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        if ($(-not $(GetServerVersion)) -or $(-not $(GetServerInstallDir)))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            return
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "---- Tuning Windows ----"

        # Configure process scheduling -- http://technet.microsoft.com/library/Cc976120
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting processor scheduling priority to background services"
        try
        {
            RegWrite -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Type "Dword" -Value 24
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting processor scheduling priority"
            WriteNonTerminalError -Message "Error setting processor scheduling priority"

            return
        }

        # Configure IIS and .NET
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "---- Tuning Internet Information Services ----"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "** Configure upload size limits and .NET execution timeout **"
        try
        {
            #$NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
            #LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting .NET maximum request size (maxRequestLength = 131072)"
            #$NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength = 131072
            #LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting .NET execution timeout (executionTimeout = 110 seconds)"
            #$NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout = [TimeSpan]::FromSeconds(110)
            #$NETMachineConfig.Save()

            SetDotNetLimits -UploadLimit 131072 -ExecutionTimeout [TimeSpan]::FromSeconds(110)
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring .NET settings"
            WriteNonTerminalError -Message "Error configuring .NET settings"

            return
        }

        try
        {
            # Configure IIS request limits (Server Level)
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting IIS upload size limits (maxAllowedContentLength = 134217728)"
            SetWebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxAllowedContentLength" -Value 134217728
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting IIS upload size limits"
            WriteNonTerminalError -Message "Error setting IIS upload size limits"

            return
        }

        # Configure IIS worker processes
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "** Configure worker process **"
        $DefaultWebSiteApps = $(Get-WebApplication -Site "Default Web Site").Path

        foreach ($Config in $OSIISConfig)
        {
            # Reset array at each loop
            $InterestingApps = @()

            # Build an array with all matching Apps.
            foreach ($App in $($Config.Match))
            {
                $InterestingApps += $DefaultWebSiteApps -like $App
            }

            # if an app was found
            if ($InterestingApps.Count -gt 0)
            {

                # Check if AppPool exists. if not, create a new one.
                if (-not $(Get-ChildItem -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction SilentlyContinue))
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating IIS AppPool $($Config.PoolName)"
                    try
                    {
                        New-Item -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction Stop | Out-Null
                    }
                    catch
                    {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating AppPool $($Config.PoolName)"
                        WriteNonTerminalError -Message "Error creating AppPool $($Config.PoolName)"

                        return
                    }
                }

                # Configure the AppPool
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Configuring AppPool $($Config.PoolName)"
                $AppPoolItem = Get-Item "IIS:\AppPools\$($Config.PoolName)"

                # Commit everything on one shot
                Start-WebCommitDelay

                $AppPoolItem.managedRuntimeVersion = "v4.0"
                $AppPoolItem.managedPipelineMode = "Classic"

                $AppPoolItem.recycling.periodicRestart.time = [TimeSpan]::FromMinutes(0)
                $AppPoolItem.recycling.periodicRestart.requests = 0
                #$AppPoolItem.recycling.periodicRestart.requests = 0 -- specific times #TODO: specific times

                $AppPoolItem.recycling.logEventOnRecycle = "Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory"
                $AppPoolItem.processModel.idleTimeout = [TimeSpan]::FromMinutes(0)

                #TODO: Set maximum failures to 0

                $AppPoolItem.recycling.periodicRestart.privateMemory = [int]($(GetInstalledRAM) * ($($Config.MemoryPercentage) / 100))

                $AppPoolItem | Set-Item

                # Move the InterestingApp to the AppPool
                foreach ($InterestingApp In $InterestingApps)
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Moving App $InterestingApp to AppPool $($Config.PoolName)"
                    Set-ItemProperty -Path "IIS:\Sites\Default Web Site$InterestingApp" -Name applicationPool -Value $($Config.PoolName)
                }

                # Commit everything on one shot
                try
                {
                    Stop-WebCommitDelay
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error applying setting to AppPool $($Config.PoolName)"
                    throw "Error applying setting to AppPool $($Config.PoolName)"
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "AppPool $($Config.PoolName) configuration done"
            }
        }

        # Configure unlimited connections. (Default Web Site) - This should not be needed cause IIS defaults to maximum.
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "** Configure unlimited connections **"
        try
        {
            SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].OverrideModeDefault" -Value "Allow"
            SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].allowDefinition" -Value "Everywhere"

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting unlimited connections (MaxConnections = 4294967295)"
            SetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost/sites/site[@name='Default Web Site']" -Name "Limits" -Value @{MaxConnections = 4294967295}
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring IIS for unlimited connections"
            WriteNonTerminalError -Message "Error configuring IIS for unlimited connections"

            return
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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
