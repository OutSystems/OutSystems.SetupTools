function Get-OSPerfTuningStatus
{
    <#
    .SYNOPSIS
    Check the status of each of the performance tuning items for the OutSystems platform server.

    .DESCRIPTION
    Gives a detailed description of the status of item of the performance tuning section for the OutSystems platform server.

    .EXAMPLE
    Get-OSPerfTuningStatus
    #>

    [CmdletBinding()]
    param(
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        Function GetCompareText {
            param(
                [bool]$IsGreaterOrEqual
            )

            if ($IsGreaterOrEqual)
            {
                $CompText = "greater or equal"
            }
            else
            {
                $CompText = "lesser"
            }

            return $CompText
        }

        Function GetIsOrIsntText {
            param(
                [bool]$Is
            )

            if ($Is)
            {
                $CompText = "is"
            }
            else
            {
                $CompText = "is not"
            }

            return $CompText
        }

        Function CreatePerfTuningStatus {
            param(
                [Parameter(Mandatory = $true)]
                [String]$Title,

                [Parameter(Mandatory = $true)]
                [ScriptBlock]$ScriptBlock
            )

            $PerfTuningStatus = & $ScriptBlock

            $PerfTuningStatus.Title = $Title

            $TextStatus = "WILL"
            if (-not $PerfTuningStatus.ShouldBeSkipped)
            {
                $TextStatus = "$TextStatus DO"
            } else
            {
                $TextStatus = "$TextStatus SKIP"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$($PerfTuningStatus.Title): [$TextStatus]"

            foreach ($Message in $PerfTuningStatus.Messages)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message " > $Message"
            }

            return $PerfTuningStatus
        }

        Function CreateResult {
            param(
                [Parameter(Mandatory = $true)]
                [Bool]$ShouldBeSkipped,

                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [String[]]$Messages
            )

            $Result = @{}
            $Result.ShouldBeSkipped = $ShouldBeSkipped
            $Result.Messages = $Messages

            return $Result
        }

        $PerfTuning = @{}
        $PerfTuning.SomethingToDo = $False
        $PerfTuning.Sections = @{}
    }

    process
    {
        # Check if user is admin
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $False
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        $PerfTuning.Sections.ProcessSchedulingConfig = CreatePerfTuningStatus -Title "Setting Windows processor scheduling priority to 'background services'" `
            -ScriptBlock `
            {
                $ShouldBeSkipped = $True
                $Messages = @()

                try
                {
                    $Value = RegRead -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Type "Dword"

                    $ShouldBeSkipped = ($Value -eq 24)

                    if ($ShouldBeSkipped)
                    {
                        $Messages = @("Already set to 'background services'.")
                    }
                    else
                    {
                        $Messages = @("Not set to 'background services'.")
                    }
                }
                catch
                {
                    $Messages = @("Unable to determine current value. Skipping.")
                }

                # No current scenarios where we should skip this
                return $(CreateResult -ShouldBeSkipped $ShouldBeSkipped -Messages $Messages)
            }

        $PerfTuning.Sections.NETConfig = CreatePerfTuningStatus -Title ".NET upload size limits and execution timeout configuration" `
            -ScriptBlock `
            {
                $ShouldBeSkipped = $True
                $Messages = @()

                try
                {
                    $NETConfig = $(GetDotNetLimits)

                    $CurrentMaxRequestLength = $NETConfig.SystemWeb.HttpRuntime.maxRequestLength
                    $CurrentMaxRequestLengthInMB = "$($CurrentMaxRequestLength/1024) MB"
                    $CurrentExecutionTimeout = $NETConfig.SystemWeb.HttpRuntime.executionTimeout

                    # upload size limits default is 4096 KB
                    #   https://docs.microsoft.com/en-us/dotnet/api/system.web.configuration.httpruntimesection.maxrequestlength
                    $DefaultMaxRequestLength = 4096
                    $DefaultMaxRequestLengthInMB = "$($DefaultMaxRequestLength/1024) MB"

                    # execution timeout default is 110 seconds
                    #   https://docs.microsoft.com/en-us/dotnet/api/system.web.configuration.httpruntimesection.executiontimeout
                    [TimeSpan]$DefaultExecutionTimeout = "00:01:50"

                    $HasSmashableMaxRequestLength = $CurrentMaxRequestLength -eq $DefaultMaxRequestLength
                    $HasSmashableExecutionTimeout = $CurrentExecutionTimeout -eq $DefaultExecutionTimeout

                    $ShouldBeSkipped = $(-not $HasSmashableMaxRequestLength) -or $(-not $HasSmashableExecutionTimeout)

                    $CompTextMaxRequestLength = $(GetIsOrIsntText $HasSmashableMaxRequestLength)

                    $Messages += @("Current upload limit value ('$CurrentMaxRequestLengthInMB') $CompTextMaxRequestLength the default ('$DefaultMaxRequestLengthInMB').")

                    $CompTextExecutionTimeout = $(GetIsOrIsntText $HasSmashableExecutionTimeout)

                    $Messages += @("Current execution timeout value ('$CurrentExecutionTimeout') $CompTextExecutionTimeout the default ('$DefaultExecutionTimeout').")
                }
                catch
                {
                    $Messages = @("Unable to determine current values. Skipping.")
                }

                return $(CreateResult -ShouldBeSkipped $ShouldBeSkipped -Messages $Messages)
            }

        $PerfTuning.Sections.IISUploadSizeLimitsConfig = CreatePerfTuningStatus -Title "IIS upload size limits configuration" `
            -ScriptBlock `
            {
                $ShouldBeSkipped = $True
                $Messages = @()

                try
                {
                    $Filter = "system.webServer/security/requestFiltering/requestLimits"
                    $Name = "maxAllowedContentLength"

                    $MaxAllowedContentLength = $(GetWebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "$Filter" -Name "$Name")
                    # MaxAllowedContentLength default value is 30000000
                    #  https://docs.microsoft.com/en-us/iis/configuration/system.webserver/security/requestfiltering/requestlimits/#configuration
                    $DefaultMaxAllowedContentLength = 30000000

                    $ShouldBeSkipped = $MaxAllowedContentLength -ne $DefaultMaxAllowedContentLength

                    $CompTextMaxAllowedContentLength = $(GetIsOrIsntText (-not $ShouldBeSkipped))

                    $Messages = @("Current max allowed content length value ('$($MaxAllowedContentLength.Value) Bytes') $CompTextMaxAllowedContentLength the default ('$DefaultMaxAllowedContentLength Bytes').")
                }
                catch
                {
                    $Messages = @("Unable to determine current value. Skipping.")
                }

                return $(CreateResult -ShouldBeSkipped $ShouldBeSkipped -Messages $Messages)
            }

        $PerfTuning.Sections.IISConnectionsConfig = CreatePerfTuningStatus -Title "IIS for unlimited connections configuration" `
            -ScriptBlock `
            {
                $ShouldBeSkipped = $True
                $Messages = @()

                try
                {
                    $IISConfigs = $(GetWebConfigurationProperty -PSPath "IIS:\" -Filter "system.applicationHost/sites/site[@name='Default Web Site']" -Name "Limits")

                    $CurrentValue = $IISConfigs.maxConnections
                    $RecommendedValue = $OSPerfTuningMaxConnections

                    $ShouldBeSkipped = $CurrentValue -ge $RecommendedValue

                    $CompText = $(GetCompareText -IsGreaterOrEqual $ShouldBeSkipped)

                    $Messages = @("Current value ('$CurrentValue') is $CompText than our recommended ('$RecommendedValue').")
                }
                catch
                {
                    $Messages = @("Unable to determine current value. Skipping.")
                }

                return $(CreateResult -ShouldBeSkipped $ShouldBeSkipped -Messages $Messages)
            }

        $PerfTuning.Sections.AppPoolsConfig = CreatePerfTuningStatus -Title "IIS Application Pools configuration" `
            -ScriptBlock `
            {
                $ShouldBeSkipped = $True
                $Messages = @()
                $AppPoolsToForciblyCreateAndConfig = @()

                try
                {
                    foreach ($AppPool in @("OutSystemsApplications", "ServiceCenterAppPool"))
                    {
                        if (-not $(Get-ChildItem -Path "IIS:\AppPools\$($AppPool)" -ErrorAction SilentlyContinue))
                        {
                            $AppPoolsToForciblyCreateAndConfig += $AppPool
                            $Messages += "'$AppPool' will be created and configured."
                        }
                        else
                        {
                            $Messages += "Detected that '$AppPool' may have user configurations. Skipping."
                        }
                    }

                    $ShouldBeSkipped = $($AppPoolsToForciblyCreateAndConfig.Count -eq 0)
                }
                catch
                {
                    $Messages += "Unable to determine application pools status. Skipping."
                }

                $Result = $(CreateResult -ShouldBeSkipped $ShouldBeSkipped -Messages $Messages)
                $Result.AppPoolsToForciblyCreateAndConfig = $AppPoolsToForciblyCreateAndConfig

                return $Result
            }

        foreach ($Status in $PerfTuning.Sections.values)
        {
            if (-not $Status.ShouldBeSkipped)
            {
                $PerfTuning.SomethingToDo = $True
                break
            }
        }

        return $PerfTuning
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
