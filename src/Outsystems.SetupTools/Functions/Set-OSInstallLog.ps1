function Set-OSInstallLog
{
    <#
    .SYNOPSIS
    Sets the module log file location.

    .DESCRIPTION
    This will set the module log location.
    By default the module will log to %temp%\OutSystems.SetupTools\InstallLog-<date>.log

    The log will contain the PowerShell verbose stream. If you set the -LogDebug switch it will also contain the debug stream.

    .PARAMETER Path
    The log file path. The cmdlet will try to create the path if not exists.

    .PARAMETER File
    The log filename.

    .PARAMETER LogDebug
    Writes on the log the debug stream

    .EXAMPLE
    Set-OSInstallLog -Path $ENV:Windir\temp -File Install.log -LogDebug

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$File,

        [Parameter()]
        [switch]$LogDebug,

        [Parameter()]
        [switch]$DisableStandardStreamLogTemplate
    )
    begin
    {
        SendFunctionStartEvent -InvocationInfo $MyInvocation
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
        $Script:OSEnableLogTemplate = (-not $DisableStandardStreamLogTemplate.IsPresent)
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "************* Starting Log **************"
    }
}
