Function Install-OSPlatformServiceCenter {
    [CmdletBinding()]
    param ()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        If ( -not $(CheckRunAsAdmin)) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "The current user is not Administrator of the machine"
            Throw "The current user is not Administrator of the machine"
        }

        Try {
            $OSVersion = GetServerVersion
            $OSInstallDir = GetServerInstallDir
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }
    }

    ### TODO!!!!  #Checking service center is installed and running.
    Process {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing Service Center. This can take a while"

        Try {
            $Result = InstallOSServiceCenter
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error lauching the service center installer"
            Throw "Error lauching the service center installer"
        }

        $OutputLog = $($Result.Output) -Split("`r`n")
        ForEach($Logline in $OutputLog){
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "SCINSTALLER: $Logline"
        }

        If( $Result.ExitCode -ne 0 ){
            throw "Error installing service center. Return code: $($Result.ExitCode)"
        }

        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Service Center successfully installed!!"
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}