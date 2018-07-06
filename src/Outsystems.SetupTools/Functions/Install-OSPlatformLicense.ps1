Function Install-OSPlatformLicense {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Path
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
            $OSVersion = GetServerVersion
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
            throw "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
        }

        If ($Path -and ($Path -ne "")) {
            If ( -not (Test-Path -Path "$Path\license.lic")) {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "License file not found at $Path\license.lic"
                Throw "License file not found at $Path\license.lic"
            }
        }
        Else {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "License path not specified. We will install a trial one"
            $Path = $ENV:TEMP

            Try {
                DownloadOSSources -URL "$OSRepoURL\license.lic" -SavePath "$Path\license.lic"
                $Path = "$Path\license.lic"
            }
            Catch {
                LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error downloading the license from the repository"
                Throw "Error downloading the license from the repository"
            }
        }
    }

    Process {

        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installing outsytems license"
        Try {
            $Result = RunConfigTool -Arguments $("/UploadLicense " + [char]34 + $Path + [char]34)
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error lauching the configuration tool"
            Throw "Error lauching the configuration tool"
        }

        $ConfToolOutputLog = $($Result.Output) -Split("`r`n")
        ForEach($Logline in $ConfToolOutputLog){
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "CONFTOOL: $Logline"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Configuration tool exit code: $($Result.ExitCode)"

        If( $Result.ExitCode -ne 0 ){
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error uploading the license. Return code: $($Result.ExitCode)"
            throw "Error uploading the license. Return code: $($Result.ExitCode)"
        }

        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "License successfully installed!!"
    }

    End {
        Write-Output "Outystems license successfully installed!!"
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}