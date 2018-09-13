function Get-OSServerPrivateKey
{
    <#
    .SYNOPSIS
    Returns the Outsystems platform server private key.

    .DESCRIPTION
    This will returns the Outsystems platform server private key. Will throw an exception if the platform is not installed or if the key file doesn't exist.

    .EXAMPLE
    Get-OSServerPrivateKey

    #>

    [CmdletBinding()]
    [OutputType('System.String')]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        $osInstallDir = GetServerInstallDir
    }

    process
    {
        if ($(-not $(GetServerVersion)) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Server is installed at $osInstallDir"

        try
        {
            $path = "$osInstallDir\private.key"
            if (-not (Test-Path -Path $path))
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Cant find the private key at $path"
                WriteNonTerminalError -Message "Cant find the private key at $path"

                return $null
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "private key file found at $path"

            $Regex = "^--*"
            Get-Content $Path -ErrorAction SilentlyContinue | ForEach-Object {
                if (-not ($_ -match $Regex))
                {
                    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
                    $privateKey = $_
                }
            }
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3  -Message "Unknown fatal error"
            WriteNonTerminalError -Message "Unknown fatal error"

            return $null
        }

        if (-not $privateKey)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error processing the file"
            WriteNonTerminalError -Message "Error processing the file"

            return $null
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning $privateKey"
        return $privateKey
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
