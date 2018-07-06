Function Set-OSPlatformPerformanceTunning {
    [CmdletBinding()]
    Param()

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
            $OSVersion = GetServerVersion
            $OSInstallDir = GetServerInstallDir
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }

        Try {
            $SCVersion = GetSCCompiledVersion
        }
        Catch {}

        If ( $SCVersion -ne $OSVersion ) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            Throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }
    }

    Process {

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

        # Configure .NET
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configure .NET"
        Try {
            Add-Type -AssemblyName System.Configuration #Needed for server 2012
            $NETMachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting .NET maxRequestLength to 131072"
            $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.maxRequestLength = 131072
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Setting .NET executionTimeout to 110 seconds"
            $NETMachineConfig.GetSectionGroup("system.web").HttpRuntime.executionTimeout = [TimeSpan]::FromSeconds(110)
            $NETMachineConfig.Save()
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error configuring .NET"
            Throw "Error configuring .NET"
        }


    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}