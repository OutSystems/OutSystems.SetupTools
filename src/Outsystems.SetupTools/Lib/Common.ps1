# Requires Constants.ps1
function LogMessage([string]$Function, [int]$Phase, [int]$Stream, [string]$Message, [object]$Exception)
{
    # Log types
    switch ($Phase)
    {
        0
        {
            $phaseMessage = ' [BEGIN  ]'
        }
        1
        {
            $phaseMessage = ' [PROCESS]'
        }
        2
        {
            $phaseMessage = ' [END    ]'
        }
    }

    $logLineTemplate = $(Get-Date -Format "yyyy-MM-dd HH:mm:ss.ffff") + " [" + $Function.PadRight(40) + "] $phaseMessage "

    switch ($Stream)
    {
        0
        {
            Write-Information -MessageData $Message
            Write-Verbose -Message "$logLineTemplate $Message"
            if ($script:OSLogFile)
            {
                Add-Content -Path $script:OSLogFile -Value "VERBOSE : $logLineTemplate $Message"
            }
        }
        1
        {
            Write-Warning -Message "$logLineTemplate $Message"
            if ($script:OSLogFile)
            {
                Add-Content -Path $script:OSLogFile -Value "WARNING : $logLineTemplate $Message"
            }
        }
        2
        {
            Write-Debug -Message "$logLineTemplate $Message"
            if ($script:OSLogFile -and $script:OSLogDebug)
            {
                Add-Content -Path $script:OSLogFile -Value "DEBUG   : $logLineTemplate $Message"
            }
        }
        3
        {
            Write-Information -MessageData $Message
            Write-Verbose -Message "$logLineTemplate $Message"
            if ($script:OSLogFile)
            {
                Add-Content -Path $script:OSLogFile -Value "ERROR   : $logLineTemplate $Message"
            }

            # Exception info
            if ($Exception)
            {
                $E = $Exception
                Write-Verbose -Message "$logLineTemplate $($E.Message)"
                if ($script:OSLogFile)
                {
                    Add-Content -Path $script:OSLogFile -Value "InnerException:"
                    Add-Content -Path $script:OSLogFile -Value $($E.Message)
                    Add-Content -Path $script:OSLogFile -Value $($E.StackTrace)
                }

                # Drill down to show the full exception chain
                while ($E.InnerException)
                {
                    $E = $E.InnerException
                    Write-Verbose -Message "$logLineTemplate $($E.Message)"
                    if ($script:OSLogFile)
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
        $output = $(Get-ItemProperty -Path $Path -Name $Name -ErrorAction Ignore).($Name)
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message $($_.Exception.Message)
    }
    return $output
}

function GetWebConfigurationProperty([string]$PSPath, [string]$Filter, [string]$Name)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Path: $PSPath"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Filter: $Filter"
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Name: $Name"

    # Web adminstration cmdLets errors are statement-terminating errors. Try/catch should be used.
    if ($Name)
    {
        $webProperty = Get-WebConfigurationProperty -PSPath $PSPath -Filter $Filter -Name $Name
    }
    else
    {
        # If name is empty is because its a collection.
        $webProperty = Get-WebConfigurationProperty -PSPath $PSPath -Filter "$Filter/add[@name='$($Value.name)']" -Name .
    }

    return $webProperty
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
        if ($webProperty)
        {
            Set-WebConfigurationProperty -PSPath $PSPath -Filter "$Filter/add[@name='$($Value.name)']" -Name . -Value $value
        }
        else
        {
            Add-WebConfigurationProperty -PSPath $PSPath -Filter $Filter -Name collection -Value $Value
        }
    }
}

function AppInsightsSendEvent([string]$EventName, [psobject]$EventProperties)
{
    try
    {
        $appInsightsClient = New-Object Microsoft.ApplicationInsights.TelemetryClient

        foreach ($instrumentationKey in $script:OSTelAppInsightsKeys)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Send appinsights event: $EventName"
            $appInsightsClient.InstrumentationKey = $instrumentationKey

            $eventProperties_ = New-Object 'System.Collections.Generic.Dictionary[string, string]'
            foreach ($eventProperty in $EventProperties.Keys)
            {
                $eventProperties_.Add($eventProperty, $($EventProperties.Item($eventProperty)))
            }

            $appInsightsClient.TrackEvent($EventName, $eventProperties_)
            $appInsightsClient.Flush()
        }
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Error sending event: $EventName"
    }
}

function SendModuleLoadEvent
{
    if ($script:OSTelEnabled)
    {
        $script:OSTelSessionId = New-Guid
        $script:OSTelOperationId = New-Guid

        $eventProperties = @{
            'sessionId'   = $script:OSTelSessionId
            'operationId' = $script:OSTelOperationId
            'tier'        = $script:OSTelTier
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Sending ModuleLoad event"
        AppInsightsSendEvent -EventName 'ModuleLoad' -EventProperties $eventProperties
    }
    else
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "ModuleLoad event not send. Telemetry is disabled"
    }
}

function SendFunctionStartEvent([psobject]$InvocationInfo)
{
    if ($script:OSTelEnabled)
    {
        $script:OSTelOperationId = New-Guid
        $script:OSTelOperationIdStartTime = Get-Date

        $eventProperties = @{
            'sessionId'     = $script:OSTelSessionId
            'operationId'   = $script:OSTelOperationId
            'tier'          = $script:OSTelTier
            'name'          = $($InvocationInfo.Mycommand)
            'parameters'    = $($InvocationInfo.BoundParameters.Keys | ConvertTo-Json)
            'osVersion'     = $(GetServerVersion)
            'moduleVersion' = $($InvocationInfo.MyCommand.Module.Version)
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Sending FunctionStart event"
        AppInsightsSendEvent -EventName 'FunctionStart' -EventProperties $eventProperties
    }
    else
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "FunctionStart event not send. Telemetry is disabled"
    }
}

function SendFunctionEndEvent([psobject]$InvocationInfo)
{
    if ($script:OSTelEnabled)
    {
        $eventProperties = @{
            'sessionId'     = $script:OSTelSessionId
            'operationId'   = $script:OSTelOperationId
            'tier'          = $script:OSTelTier
            'name'          = $($InvocationInfo.Mycommand)
            'parameters'    = $($InvocationInfo.BoundParameters.Keys | ConvertTo-Json)
            'osVersion'     = $(GetServerVersion)
            'moduleVersion' = $($InvocationInfo.MyCommand.Module.Version)
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Sending FunctionEnd event"
        AppInsightsSendEvent -EventName 'FunctionEnd' -EventProperties $eventProperties
    }
    else
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "FunctionEnd event not send. Telemetry is disabled"
    }
}

function TestFileLock([string]$Path)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Checking if file $Path is locked"

    $file = New-Object System.IO.FileInfo $Path

    if ((Test-Path -Path $Path) -eq $false) {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "File does not exist. Returning false."
        return $false
    }

    try {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Openning"
        $stream = $file.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

        if ($stream) {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Sucessfully open the file. File is not locked"
            $stream.Close()
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Closing and Returning false"
        }
        return $false
    }
    catch
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "File is locked!!! Returning true!!"
        return $true
    }
}

function GetHashedPassword([string]$Password)
{
    $objPass = New-Object -TypeName OutSystems.FrameworkExtensions.Password -ArgumentList $Password
    $hashedPass = $('#' + $objPass.EncryptedValue)
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Encrypted string $hashedPass"

    return $hashedPass
}

function MaskKey([String]$Text)
{
    $startchar = [math]::min($Text.length - 4, $Text.length)
    $startchar = [math]::max(0, $startchar)
    $right = "**********$($Text.SubString($startchar ,[math]::min($Text.length, 4)))"
    return $right
}

function ValidateVersion([System.Version]$Version, [string]$Major, [string]$Minor, [string]$Build)
{
    # Version is not null or empty and is not $Major and minor is less than $Minor
    if ($Version -and $($Version.Major -ne $Major -or $Version.Minor -lt $Minor -or $Version.Build -lt $Build))
    {
        $message = "Required version is $($Major).$($Minor).$($Build)"
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message $message
        return $false
    }

    return $true
}

function ValidateMinimumRequiredVersion()
{
    $psVersion = [System.Version]$(GetServerVersion)
    $ltVersion = [System.Version]$(GetLifetimeVersion)

    #If there is LifeTime
    if ($ltVersion)
    {
        # PS 11.23.0
        return ValidateVersion -Version $ltVersion -Major "11" -Minor "19" -Build "0"
    }
    elseif ($psVersion)
    {
        return ValidateVersion -Version $psVersion -Major "11" -Minor "23" -Build "0"
    }

    return $true
}
