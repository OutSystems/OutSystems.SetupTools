Function Set-OSServerPerformanceTunning {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER IISNetCompilationPath
    Parameter description

    .PARAMETER IISHttpCompressionPath
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param(
        [Parameter()]
        [string]$IISNetCompilationPath,

        [Parameter()]
        [string]$IISHttpCompressionPath
    )

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        try {
            CheckRunAsAdmin | Out-Null
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            throw "The current user is not Administrator or not running this script in an elevated session"
        }

        if ($(-not $(GetServerVersion)) -or $(-not $(GetServerInstallDir))) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }
    }

    process {

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "---- Tuning Windows ----"

        # Configure process scheduling -- http://technet.microsoft.com/library/Cc976120
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting processor scheduling priority to background services"
        try {
            New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -ErrorAction Ignore
            Set-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 24
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting processor scheduling priority"
            throw "Error setting processor scheduling priority"
        }

        # Configure IIS and .NET
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "---- Tuning Internet Information Services ----"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "** Configure upload size limits and .NET execution timeout **"
        try {
            Add-Type -AssemblyName System.Configuration #Needed for server 2012
            $NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting .NET maximum request size (maxRequestLength = 131072)"
            $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength = 131072
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting .NET execution timeout (executionTimeout = 110 seconds)"
            $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout = [TimeSpan]::FromSeconds(110)
            $NETMachineConfig.Save()
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring .NET settings"
            throw "Error configuring .NET settings"
        }

        try {
            # Configure IIS request limits (Server Level)
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting IIS upload size limits (maxAllowedContentLength = 134217728)"
            Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxAllowedContentLength" -Value 134217728
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting IIS upload size limits"
            throw "Error setting IIS upload size limits"
        }

        # Configure IIS worker processes
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "** Configure worker process **"
        $DefaultWebSiteApps = $(Get-WebApplication -Site "Default Web Site").Path

        foreach ($Config in $OSIISConfig) {

            # Reset array at each loop
            $InterestingApps = @()

            # Build an array with all matching Apps.
            foreach ($App in $($Config.Match)) {
                $InterestingApps += $DefaultWebSiteApps -like $App
            }

            # if an app was found
            if ($InterestingApps.Count -gt 0) {

                # Check if AppPool exists. if not, create a new one.
                if (-not $(Get-ChildItem -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction SilentlyContinue)) {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Creating IIS AppPool $($Config.PoolName)"
                    try {
                        New-Item -Path "IIS:\AppPools\$($Config.PoolName)" | Out-Null
                    } catch {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating AppPool $($Config.PoolName)"
                        throw "Error creating AppPool $($Config.PoolName)"
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

                $AppPoolItem.recycling.periodicRestart.privateMemory = [int]((($(Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory) / 1024) * ($($Config.MemoryPercentage) / 100))

                $AppPoolItem | Set-Item

                # Move the InterestingApp to the AppPool
                foreach ($InterestingApp In $InterestingApps) {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Moving App $InterestingApp to AppPool $($Config.PoolName)"
                    Set-ItemProperty -Path "IIS:\Sites\Default Web Site$InterestingApp" -Name applicationPool -Value $($Config.PoolName)
                }

                # Commit everything on one shot
                try {
                    Stop-WebCommitDelay
                } catch {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error applying setting to AppPool $($Config.PoolName)"
                    throw "Error applying setting to AppPool $($Config.PoolName)"
                }

                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "AppPool $($Config.PoolName) configuration done"
            }
        }

        # Configure unlimited connections. (Default Web Site) - This should not be needed cause IIS defaults to maximum.
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "** Configure unlimited connections **"
        try {
            Set-WebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].OverrideModeDefault" -Value Allow
            Set-WebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].allowDefinition" -Value Everywhere
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Setting unlimited connections (MaxConnections = 4294967295)"
            Set-WebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost/sites/site[@name='Default Web Site']" -Name "Limits" -Value @{MaxConnections = 4294967295}
        } catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring IIS for unlimited connections"
            throw "Error configuring IIS for unlimited connections"
        }

        # Configure .NET compilation folder (Server Level)
        if ($IISNetCompilationPath -and ($IISNetCompilationPath -ne "")) {

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IISNetCompilationPath specified on the command line"
            if ( -not (Test-Path -Path $IISNetCompilationPath)) {
                try {
                    New-Item -Path $IISNetCompilationPath -ItemType directory -Force | Out-Null
                } catch {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the IIS Net compilation folder"
                    throw "Error creating the IIS Net compilation folder"
                }
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Changing IIS compilation folder to $IISNetCompilationPath"
            try {
                Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT" -Filter "system.web/compilation" -Name 'tempDirectory' -Value $IISNetCompilationPath
            } catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the IIS compilation folder"
                throw "Error setting the IIS compilation folder"
            }

        }

        # Configure HTTP Compression folder (Server Level)
        if ($IISHttpCompressionPath -and ($IISHttpCompressionPath -ne "")) {

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "IISHttpCompressionPath specified on the command line"
            if ( -not (Test-Path -Path $IISHttpCompressionPath)) {
                try {
                    New-Item -Path $IISHttpCompressionPath -ItemType directory -Force | Out-Null
                } catch {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error creating the IIS HTTP compression folder"
                    throw "Error creating the IIS HTTP compression folder"
                }
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Changing IIS HTTP compression folder to $IISHttpCompressionPath"
            try {
                Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST"  -Filter "system.webServer/httpCompression" -Name "directory" -Value $IISHttpCompressionPath
            } catch {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the IIS HTTP compression folder"
                throw "Error setting the IIS HTTP compression folder"
            }
        }
    }

    end {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
