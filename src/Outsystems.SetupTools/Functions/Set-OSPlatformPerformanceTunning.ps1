Function Set-OSPlatformPerformanceTunning {
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

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        Try {
            CheckRunAsAdmin | Out-Null
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            Throw "The current user is not Administrator or not running this script in an elevated session"
        }

        Try {
            GetServerVersion | Out-Null
            GetServerInstallDir | Out-Null
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }
    }

    Process {

        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "---- Tuning Windows ----"

        # Configure process scheduling -- http://technet.microsoft.com/library/Cc976120
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting processor scheduling priority to background services"
        Try {
            New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -ErrorAction Ignore
            Set-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 24
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error setting processor scheduling priority"
            Throw "Error setting processor scheduling priority"
        }

        # Configure IIS and .NET
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "---- Tuning Internet Information Services ----"
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "** Configure upload size limits and .NET execution timeout **"
        Try {
            Add-Type -AssemblyName System.Configuration #Needed for server 2012
            $NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting .NET maximum request size (maxRequestLength = 131072)"
            $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength = 131072
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting .NET execution timeout (executionTimeout = 110 seconds)"
            $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout = [TimeSpan]::FromSeconds(110)
            $NETMachineConfig.Save()
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error configuring .NET settings"
            Throw "Error configuring .NET settings"
        }

        Try {
            # Configure IIS request limits (Server Level)
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting IIS upload size limits (maxAllowedContentLength = 134217728)"
            Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/security/requestFiltering/requestLimits" -Name "maxAllowedContentLength" -Value 134217728
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error setting IIS upload size limits"
            Throw "Error setting IIS upload size limits"
        }

        # Configure IIS worker processes
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "** Configure worker process **"
        $DefaultWebSiteApps = $(Get-WebApplication -Site "Default Web Site").Path

        ForEach ($Config in $OSIISConfig) {

            # Reset array at each loop
            $InterestingApps = @()

            # Build an array with all matching Apps.
            ForEach ($App In $($Config.Match)) {
                $InterestingApps += $DefaultWebSiteApps -like $App
            }

            # If an app was found
            If ($InterestingApps.Count -gt 0) {

                # Check if AppPool exists. If not, create a new one.
                If (-not $(Get-ChildItem -Path "IIS:\AppPools\$($Config.PoolName)" -ErrorAction SilentlyContinue)) {
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Creating IIS AppPool $($Config.PoolName)"
                    Try {
                        New-Item -Path "IIS:\AppPools\$($Config.PoolName)" | Out-Null
                    }
                    Catch {
                        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error creating AppPool $($Config.PoolName)"
                        Throw "Error creating AppPool $($Config.PoolName)"
                    }
                }

                # Configure the AppPool
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuring AppPool $($Config.PoolName)"
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
                ForEach ($InterestingApp In $InterestingApps) {
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Moving App $InterestingApp to AppPool $($Config.PoolName)"
                    Set-ItemProperty -Path "IIS:\Sites\Default Web Site$InterestingApp" -Name applicationPool -Value $($Config.PoolName)
                }

                # Commit everything on one shot
                Try {
                    Stop-WebCommitDelay
                }
                Catch {
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error applying setting to AppPool $($Config.PoolName)"
                    Throw "Error applying setting to AppPool $($Config.PoolName)"
                }

                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "AppPool $($Config.PoolName) configuration done"
            }
        }

        # Configure unlimited connections. (Default Web Site) - This should not be needed cause IIS defaults to maximum.
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "** Configure unlimited connections **"
        Try {
            Set-WebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].OverrideModeDefault" -Value Allow
            Set-WebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost" -Name "sections['webLimits'].allowDefinition" -Value Everywhere
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting unlimited connections (MaxConnections = 4294967295)"
            Set-WebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost/sites/site[@name='Default Web Site']" -Name "Limits" -Value @{MaxConnections = 4294967295}
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error configuring IIS for unlimited connections"
            Throw "Error configuring IIS for unlimited connections"
        }

        # Configure .NET compilation folder (Server Level)
        If ($IISNetCompilationPath -and ($IISNetCompilationPath -ne "")) {

            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "IISNetCompilationPath specified on the command line"
            If ( -not (Test-Path -Path $IISNetCompilationPath)) {
                Try {
                    New-Item -Path $IISNetCompilationPath -ItemType directory -Force | Out-Null
                }
                Catch {
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error creating the IIS Net compilation folder"
                    Throw "Error creating the IIS Net compilation folder"
                }
            }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Changing IIS compilation folder to $IISNetCompilationPath"
            Try {
                Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT" -Filter "system.web/compilation" -Name 'tempDirectory' -Value $IISNetCompilationPath
            }
            Catch {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error setting the IIS compilation folder"
                Throw "Error setting the IIS compilation folder"
            }

        }

        # Configure HTTP Compression folder (Server Level)
        If ($IISHttpCompressionPath -and ($IISHttpCompressionPath -ne "")) {

            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "IISHttpCompressionPath specified on the command line"
            If ( -not (Test-Path -Path $IISHttpCompressionPath)) {
                Try {
                    New-Item -Path $IISHttpCompressionPath -ItemType directory -Force | Out-Null
                }
                Catch {
                    LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error creating the IIS HTTP compression folder"
                    Throw "Error creating the IIS HTTP compression folder"
                }
            }
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Changing IIS HTTP compression folder to $IISHttpCompressionPath"
            Try {
                Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST"  -Filter "system.webServer/httpCompression" -Name "directory" -Value $IISHttpCompressionPath
            }
            Catch {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error setting the IIS HTTP compression folder"
                Throw "Error setting the IIS HTTP compression folder"
            }
        }
    }

    End {
        Write-Output "Performance settings successfully applied"
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}