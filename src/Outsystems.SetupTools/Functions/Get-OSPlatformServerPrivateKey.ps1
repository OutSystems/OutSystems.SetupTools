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
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        Try {
            $InstallDir = GetServerInstallDir
        }
        Catch {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            Throw "Outsystems platform is not installed"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Server is installed at $InstallDir"

        $Path = "$InstallDir\private.key"
        If ( -not (Test-Path -Path $Path)) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Cant file the file $Path"
            Throw "Cant file the file $Path"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "private.key file found"
    }

    Process {
        $Regex = "^--*"
        Get-Content $Path | ForEach-Object {
            If ( -not ($_ -match $Regex) ) {
                $PrivateKey = $_
            }
        }

        If ( -not $PrivateKey ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error processing the file"
            Throw "Error processing the file"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $PrivateKey"
        Return $PrivateKey
    }

    End {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}