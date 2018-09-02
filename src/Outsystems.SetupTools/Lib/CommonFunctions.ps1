function LogMessage([string]$Function, [int]$Phase, [int]$Stream, [string]$Message, [object]$Exception)
{

    # Log types
    switch ($Phase)
    {
        0
        {
            $PhaseMessage += ' [BEGIN  ]'
        }

        1
        {
            $PhaseMessage += ' [PROCESS]'
        }

        2
        {
            $PhaseMessage += ' [END    ]'
        }
    }

    $LogLineTemplate = $((get-date).TimeOfDay.ToString()) + " [" + $Function.PadRight(40) + "] $PhaseMessage "

    switch ($Stream)
    {
        0
        {
            Write-Verbose  "$LogLineTemplate $Message"
            if ($script:OSLogFile -and ($script:OSLogFile -ne ""))
            {
                Add-Content -Path $script:OSLogFile -Value "VERBOSE : $LogLineTemplate $Message"
            }
        }

        1
        {
            Write-Warning  "$LogLineTemplate $Message"
            if ($script:OSLogFile -and ($script:OSLogFile -ne ""))
            {
                Add-Content -Path $script:OSLogFile -Value "WARNING : $LogLineTemplate $Message"
            }
        }

        2
        {
            Write-Debug  "$LogLineTemplate $Message"
            if ($script:OSLogFile -and ($script:OSLogFile -ne "") -and $script:OSLogDebug)
            {
                Add-Content -Path $script:OSLogFile -Value "DEBUG   : $LogLineTemplate $Message"
            }
        }

        3
        {
            Write-Verbose "$LogLineTemplate $Message"

            # Exception info
            if ($Exception)
            {
                $E = $Exception
                Write-Verbose "$LogLineTemplate $($E.Message)"
                if ($script:OSLogFile -and ($script:OSLogFile -ne ""))
                {
                    Add-Content -Path $script:OSLogFile -Value "ERROR   : $LogLineTemplate $Message"
                    Add-Content -Path $script:OSLogFile -Value "InnerException:"
                    Add-Content -Path $script:OSLogFile -Value $($E.Message)
                    Add-Content -Path $script:OSLogFile -Value $($E.StackTrace)
                }

                # Drill down to show the full exception chain
                while ($E.InnerException)
                {
                    $E = $E.InnerException
                    Write-Verbose "$LogLineTemplate $($E.Message)"
                    if ($script:OSLogFile -and ($script:OSLogFile -ne ""))
                    {
                        Add-Content -Path $script:OSLogFile -Value $($E.Message)
                        Add-Content -Path $script:OSLogFile -Value $($E.StackTrace)
                    }
                }
            }
        }
    }
}

Function CheckRunAsAdmin()
{

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    if ((New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Current user is admin."
    }
    Else
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Current user is NOT admin!!."
        Throw "The current user is not Administrator or not running this script in an elevated session"
    }

}

function IsAdmin()
{
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    if ((New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Current user is admin."
        return $true
    }
    else
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Current user is NOT admin!!."
        return $false
    }
}

function WriteNonTerminalError([string]$Message)
{
    #(to work around the issue that Write-Error doesn't set$? to $False in the caller's context)
    $PSCmdlet.WriteError((New-Object System.Management.Automation.ErrorRecord $Message, $null, ([System.Management.Automation.ErrorCategory]::InvalidData), $null))
}
