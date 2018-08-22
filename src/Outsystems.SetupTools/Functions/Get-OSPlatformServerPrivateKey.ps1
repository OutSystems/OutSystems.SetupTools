function Get-OSPlatformServerPrivateKey {
    <#
    .SYNOPSIS
    Returns the Outsystems platform server private key.

    .DESCRIPTION
    This will returns the Outsystems platform server private key. Will throw an exception if the platform is not installed or if the key file doesn't exist.

    .EXAMPLE
    Get-OSPlatformServerPrivateKey

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"

        $OSInstallDir = GetServerInstallDir
        if ($(-not $(GetServerVersion)) -or $(-not $OSInstallDir)){
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Exception $_.Exception -Stream 3 -Message "Outsystems platform is not installed"
            throw "Outsystems platform is not installed"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Server is installed at $OSInstallDir"

        $Path = "$OSInstallDir\private.key"
        if (-not (Test-Path -Path $Path)) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Cant find the private key at $Path"
            throw "Cant find the private key at $Path"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "private key file found at $Path"
    }

    process {
        $Regex = "^--*"
        Get-Content $Path | ForEach-Object {
            if ( -not ($_ -match $Regex) ) {
                $PrivateKey = $_
            }
        }

        if ( -not $PrivateKey ) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error processing the file"
            throw "Error processing the file"
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $PrivateKey"
        return $PrivateKey
    }

    end {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
