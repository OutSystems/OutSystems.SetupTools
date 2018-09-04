function Set-OSInstallLog
{
    <#
    .SYNOPSIS
    Sets the log file location.

    .DESCRIPTION
    This will set the name and location where the log file will be stored.
    By default, the log will have the verbose stream. If you set the -LogDebug switch it will also contain the debug stream.

    .PARAMETER Path
    The log file path. The function will try to create the path if not exists.

    .PARAMETER File
    The log filename.

    .PARAMETER LogDebug
    If should log also the debug stream

    .EXAMPLE
    Set-OSInstallLog -Path $ENV:Windir\temp -File Install.log -LogDebug

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$File,

        [Parameter()]
        [switch]$LogDebug
    )
    begin
    {
    }

    process
    {
        If ( -not (Test-Path -Path $Path))
        {
            try
            {
                New-Item -Path $Path -ItemType directory -Force -ErrorAction Stop | Out-Null
            }
            catch
            {
                WriteNonTerminalError -Message "Error creating the log file location"

                return
            }
        }

        $Script:OSLogFile = "$Path\$File"
        $Script:OSLogDebug = $LogDebug
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "************* Starting Log **************"
    }
}
