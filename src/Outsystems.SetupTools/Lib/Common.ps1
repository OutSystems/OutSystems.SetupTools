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
    #(to work around the issue that Write-Error doesn't set $? to $False in the caller's context)
    $PSCmdlet.WriteError((New-Object System.Management.Automation.ErrorRecord $Message, $null, ([System.Management.Automation.ErrorCategory]::InvalidData), $null))
}

function RegWrite([string]$Path, [string]$Name, [string]$Type, [string]$Value)
{
    #RegType: https://docs.microsoft.com/en-us/dotnet/api/microsoft.win32.registryvaluekind?redirectedfrom=MSDN&view=netframework-4.7.2
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Writting at $Path\$Name value $Value, type $Type"

    if (-not $(Test-Path $Path))
    {
        New-Item -Path $Path -ErrorAction Ignore -Force | Out-Null
    }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ErrorAction Stop | Out-Null
}

function RegRead([string]$Path, [string]$Name)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Reading $Path\$Name"

    try
    {
        $output = $(Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).($Name)
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }
    return $output
}

function SetWebConfigurationProperty([string]$PSPath, [string]$Filter, [string]$Name, [PSObject]$Value)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Path: $PSPath"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Filter: $Filter"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Name: $Name"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Value: $Value"

    # Web adminstration cmdLets errors are statement-terminating errors. Try/catch should be used.
    if ($Name)
    {
        Set-WebConfigurationProperty -PSPath $PSPath -Filter $Filter -Name $Name -Value $Value
    }
    else
    {
        # If name is empty is because its a collection.
        $webProperty = Get-WebConfigurationProperty -PSPath $PSPath -Filter "$Filter/add[@name='$($Value.name)']" -Name .
        if($webProperty)
        {
            Set-WebConfigurationProperty -PSPath $PSPath -Filter "$Filter/add[@name='$($Value.name)']" -Name . -Value $value
        }
        else
        {
            Add-WebConfigurationProperty -PSPath $PSPath -Filter $Filter -Name collection -Value $Value
        }
    }
}
