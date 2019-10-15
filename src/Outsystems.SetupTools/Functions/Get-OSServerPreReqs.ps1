function Get-OSServerPreReqs
{
    <#
    .SYNOPSIS
    Check the status of prerequisites for the OutSystems platform server.

    .DESCRIPTION
    This will check if the prerequisites (e.g. IIS features, .NET Framework Version and etc.) for the OutSystems platform server are installed.

    .PARAMETER MajorVersion
    Specifies the platform major version.
    Accepted values: 10 or 11

    .EXAMPLE
    Get-OSServerPreReqs -MajorVersion "10"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('1[0-1]{1}(\.0)?')]
        [string]$MajorVersion
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        Function CreateRequirementStatus {
            param(
                [Parameter(Mandatory = $true)]
                [String]$Title,

                [Parameter(Mandatory = $true)]
                [ScriptBlock]$ScriptBlock
            )

            $Result = & $ScriptBlock

            $RequirementStatus = @{}
            $RequirementStatus.Title = $Title
            $RequirementStatus.Status = $Result.Status

            $TextStatus = "OK"
            if (-not $($Result.Status))
            {
                $TextStatus = "NOT $TextStatus"
            }

            $RequirementStatus.Messages = @()
            $RequirementStatus.Messages += "$($Title): [$TextStatus]"

            foreach ($Message in $Result.Messages)
            {
                $RequirementStatus.Messages += " > $Message"
            }


            return $RequirementStatus
        }

        Function CreateResult {
            param(
                [Parameter(Mandatory = $true)]
                [Bool]$Status,

                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [String[]]$OKMessages,

                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [String[]]$NOKMessages
            )

            $Result = @{}
            $Result.Status = $Status

            if ($Result.Status)
            {
                $Result.Messages = $OKMessages
            }
            else
            {
                $Result.Messages = $NOKMessages
            }

            return $Result
        }

        $GlobalRequirementsStatus = $True

        $RequirementStatuses = @()
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

        # Base Windows Features
        $winFeatures = $OSWindowsFeaturesBase

        switch ($MajorVersion)
        {
            '10'
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding Microsoft Message Queueing feature to the Windows Features list since its required for OutSystems $MajorVersion"
                $winFeatures += "MSMQ"
            }
            '11'
            {
                $RequirementStatuses += CreateRequirementStatus -Title ".NET Core Windows Server Hosting" `
                                                                -ScriptBlock `
                                                                {
                                                                    $Status = $([version]$(GetWindowsServerHostingVersion) -ge [version]$OS11ReqsMinDotNetCoreVersion)
                                                                    $OKMessages = @("Minimum .NET Core Windows Server Hosting found.")
                                                                    $NOKMessages = @("Minimum .NET Core Windows Server Hosting not found.")

                                                                    return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                                }
            }
        }

        $RequirementStatuses += CreateRequirementStatus -Title "Windows Features" `
                                                        -ScriptBlock `
                                                        {
                                                            $Status = $True
                                                            $OKMessages = @()
                                                            $NOKMessages = @()

                                                            try
                                                            {
                                                                $WindowsFeatures = $(Get-WindowsFeature -Name $winFeatures) 4>$null
                                                                $Features = @()

                                                                foreach ($Feature in $WindowsFeatures)
                                                                {
                                                                    switch ($Feature.InstallState)
                                                                    {
                                                                        'Installed'
                                                                        {
                                                                            $FeatureStatus = 'Installed'
                                                                            $Status = $Status -and $True
                                                                        }

                                                                        'InstallPending'
                                                                        {
                                                                            $FeatureStatus = 'Installed but a reboot is required'
                                                                            $Status = $False
                                                                        }

                                                                        default
                                                                        {
                                                                            $FeatureStatus = 'Not Installed'
                                                                            $Status = $False
                                                                        }
                                                                    }

                                                                    $Features += "$($Feature.DisplayName) ($($Feature.Name)) is $FeatureStatus."
                                                                }

                                                                if ($Status)
                                                                {
                                                                    $OKMessages += $Features
                                                                }
                                                                else
                                                                {
                                                                    $NOKMessages += $Features
                                                                }
                                                            }
                                                            catch
                                                            {
                                                                $Status = $False
                                                                $NOKMessages += "Something went wrong when trying to obtain Windows Features: `"$_`""
                                                            }

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }

        $RequirementStatuses += CreateRequirementStatus -Title "Microsoft.NET Framework Version" `
                                                        -ScriptBlock `
                                                        {
                                                            $MinDotNet4Version = $(GetMinDotNet4VersionForMajor -PlatformMajorVersion $MajorVersion)

                                                            $Status = $(GetDotNet4Version) -ge $MinDotNet4Version.Value
                                                            $OKMessages = @("Minimum .NET version $($MinDotNet4Version.Version) found.")
                                                            $NOKMessages = @("Minimum .NET version $($MinDotNet4Version.Version) not found.")

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }

        $RequirementStatuses += CreateRequirementStatus -Title "Microsoft Build Tools" `
                                                        -ScriptBlock `
                                                        {
                                                            $MSBuildInstallInfo = GetMSBuildToolsInstallInfo

                                                            $Status = $(IsMSBuildToolsVersionValid -MajorVersion $MajorVersion -InstallInfo $MSBuildInstallInfo)
                                                            $OKMessages = @("$($MSBuildInstallInfo.LatestVersionInstalled) is installed.")
                                                            $NOKMessages = @("No valid MS Build Tools version found, this is an OutSystems requirement.")

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }

        $RequirementStatuses += CreateRequirementStatus -Title "Windows Search Service" `
                                                        -ScriptBlock `
                                                        {
                                                            $Status = $(ServiceWindowsSearchIsDisabled)
                                                            $OKMessages = @("Windows Search is disabled.")
                                                            $NOKMessages = @("Windows Search is enabled and/or running.")

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }

        $RequirementStatuses += CreateRequirementStatus -Title "Windows Management Instrumentation Service" `
                                                        -ScriptBlock `
                                                        {
                                                            $Status = $(ServiceWMIIsEnabled)
                                                            $OKMessages = @("Windows Management Instrumentation Service is correctly configured.")
                                                            $NOKMessages = @("Windows Management Instrumentation Service is not correctly configured.")

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }

        $RequirementStatuses += CreateRequirementStatus -Title "Event Logs" `
                                                        -ScriptBlock `
                                                        {
                                                            $Status = $True
                                                            $OKMessages = @("All Event Logs are correctly configured.")
                                                            $NOKMessages = @()

                                                            try
                                                            {
                                                                foreach ($EventLogName in $OSWinEventLogName)
                                                                {
                                                                    $EventLog = $(Get-EventLog -List | Where-Object { $_.Log -eq $EventLogName})

                                                                    $CheckMaxLogSize = ($EventLog.MaximumKilobytes * 1024) -lt $OSWinEventLogSize
                                                                    $CheckOverflowAction = $EventLog.OverflowAction -ne $OSWinEventLogOverflowAction

                                                                    if ($CheckMaxLogSize -or $CheckOverflowAction)
                                                                    {
                                                                        $Status = $False
                                                                        $NOKMessage = "Event Log '$EventLogName' is not correctly configured."

                                                                        if ($CheckMaxLogSize)
                                                                        {
                                                                            $NOKMessage = "$NOKMessage Maximum log size is under $OSWinEventLogOverflowAction."
                                                                        }

                                                                        if ($CheckOverflowAction)
                                                                        {
                                                                            $NOKMessage = "$NOKMessage 'Overwrite events as needed' is not set."
                                                                        }

                                                                        $NOKMessages += $NOKMessage
                                                                    }
                                                                }
                                                            }
                                                            catch
                                                            {
                                                                $Status = $False
                                                                $NOKMessages += "Something went wrong when trying to obtain Event Logs information: `"$_`""
                                                            }

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }

        $RequirementStatuses += CreateRequirementStatus -Title "FIPS Compliant Algorithms" `
                                                        -ScriptBlock `
                                                        {
                                                            $Status = $(IsFIPSDisabled)
                                                            $OKMessages = @("FIPS Compliant Algorithms are disabled.")
                                                            $NOKMessages = @("FIPS Compliant Algorithms are enabled.")

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }

        foreach ($RequirementStatus in $RequirementStatuses)
        {
            foreach ($Message in $RequirementStatus.Messages)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$Message"
            }

            if (-not $RequirementStatus.Status)
            {
                $GlobalRequirementsStatus = $False
            }
        }

        return $GlobalRequirementsStatus
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
