Function Get-OSPlatformServerPrivateKey {
    <#
    .SYNOPSIS
    Returns the Outsystems platform server private key.

    .DESCRIPTION
    This will returns the Outsystems platform server private key. Will throw an exception if the platform is not installed or if the key file doesn't exist.

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    Param()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
        Try {
            $InstallDir = GetServerInstallDir
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Server is installed at $InstallDir"

        $Path = "$InstallDir\private.key"
        If ( -not (Test-Path -Path $Path)) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Cant file the file $Path"
            Throw "Cant file the file $Path"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "private.key file found"
    }

    Process {
        $Regex = "^--*"
        Get-Content $Path | ForEach-Object {
            If ( -not ($_ -match $Regex) ) {
                $PrivateKey = $_
            }
        }

        If ( -not $PrivateKey ) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error processing the file"
            Throw "Error processing the file"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning $PrivateKey"
        Return $PrivateKey
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}