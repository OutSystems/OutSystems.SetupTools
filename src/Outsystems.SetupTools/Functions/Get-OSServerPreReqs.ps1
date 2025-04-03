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

    .PARAMETER MinorVersion
    Specifies the platform minor version.
    Accepted values: one or more digit numbers.

    .PARAMETER PatchVersion
    Specifies the platform patch version.
    Accepted values: single digits only.

    .EXAMPLE
    Get-OSServerPreReqs -MajorVersion "10"

    .EXAMPLE
    Get-OSServerPreReqs -MajorVersion "11" -MinorVersion "12" -PatchVersion "3"
    #>

    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('1[0-1]{1}(\.0)?')]
        [string]$MajorVersion,

        [Parameter()]
        [ValidatePattern('\d+')]
        [string]$MinorVersion = "0",

        [Parameter()]
        [ValidatePattern('\d$')]
        [string]$PatchVersion = "0"
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
            $RequirementStatus.OptionalsStatus = $Result.OptionalsStatus
            $RequirementStatus.IISStatus = $Result.IISStatus

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

                [Parameter(Mandatory = $false)]
                [Bool]$OptionalsStatus = $True,

                [Parameter(Mandatory = $false)]
                [Bool]$IISStatus = $True,

                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [String[]]$OKMessages,

                [Parameter(Mandatory = $true)]
                [AllowEmptyCollection()]
                [String[]]$NOKMessages
            )

            $Result = @{}
            $Result.Status = $Status
            $Result.OptionalsStatus = $OptionalsStatus
            $Result.IISStatus = $IISStatus


            if ($Result.Status -and $Result.OptionalsStatus)
            {
                $Result.Messages = $OKMessages
            }
            elseif ($Result.Status -and -not $Result.OptionalsStatus)
            {
                $Result.Messages = $NOKMessages
            }
            elseif (-not $Result.IISStatus)
            {
                $Result.Messages = $NOKMessages
            }
            else
            {
                $Result.Messages = $NOKMessages
            }

            return $Result
        }

        $GlobalRequirementsResults = @{}
        $GlobalRequirementsResults.Success = $True
        $GlobalRequirementsResults.OptionalsStatus = $True
        $GlobalRequirementsResults.IISStatus = $True

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

                $requireMSBuildTools = $true
            }
            default
            {
                # Deprecated Build Tools is no longer mandatory in system requirements
                $requireMSBuildTools = $false

                # Check .NET Core / .NET Windows Server Hosting version
                $fullVersion = [version]"$MajorVersion.$MinorVersion.$PatchVersion.0"
                if ($fullVersion -eq [version]"$MajorVersion.0.0.0")
                {
                    # Here means that no specific minor and patch version were specified
                    # So we install all versions
                    $requireDotNetCoreHostingBundle2 = $true
                    $requireDotNetCoreHostingBundle3 = $true
                    $requireDotNetHostingBundle6 = $true
                    $requireDotNetHostingBundle8 = $true
                }
                elseif ($fullVersion -ge [version]"11.25.1.0")  # TODO: DECIDE WHICH VERSION!!!!!
                {
                    # Here means that minor and patch version were specified and we are equal or above version 11.25.1.0
                    # We install .NET 8.0 only
                    $requireDotNetCoreHostingBundle2 = $false
                    $requireDotNetCoreHostingBundle3 = $false
                    $requireDotNetHostingBundle6 = $false
                    $requireDotNetHostingBundle8 = $true
                }
                elseif ($fullVersion -ge [version]"11.17.1.0")
                {
                    # Here means that minor and patch version were specified and we are equal or above version 11.17.1.0
                    # We install .NET 6.0 only
                    $requireDotNetCoreHostingBundle2 = $false
                    $requireDotNetCoreHostingBundle3 = $false
                    $requireDotNetHostingBundle6 = $true
                }
                elseif ($fullVersion -ge [version]"11.12.2.0")
                {
                    # Here means that minor and patch version were specified and we are equal or above version 11.12.2.0
                    # We install .NET Core 3.1 only
                    $requireDotNetCoreHostingBundle2 = $false
                    $requireDotNetCoreHostingBundle3 = $true
                    $requireDotNetHostingBundle6 = $false
                }
                else
                {
                    # Here means that minor and patch version were specified and we are below version 11.12.2.0
                    # We install .NET Core 2.1 only
                    $requireDotNetCoreHostingBundle2 = $true
                    $requireDotNetCoreHostingBundle3 = $false
                    $requireDotNetHostingBundle6 = $false
                }

                if($requireDotNetCoreHostingBundle2) {
                    $RequirementStatuses += CreateRequirementStatus -Title ".NET Core 2.1 Windows Server Hosting" `
                                                                    -ScriptBlock `
                                                                    {
                                                                        $Status = $False
                                                                        foreach ($version in GetDotNetCoreHostingBundleVersions)
                                                                        {
                                                                            # Check .NET Core 2.1
                                                                            if (([version]$version).Major -eq 2 -and ([version]$version) -ge [version]$script:OSDotNetCoreHostingBundleReq['2']['Version']) {
                                                                                $Status = $True
                                                                            }
                                                                        }
                                                                        $OKMessages = @("Minimum .NET Core 2.1 Windows Server Hosting found.")
                                                                        $NOKMessages = @("Minimum .NET Core 2.1 Windows Server Hosting not found.")
                                                                        $IISStatus = $True

                                                                        if (Get-Command Get-WebGlobalModule -errorAction SilentlyContinue)
                                                                        {
                                                                            $aspModules = Get-WebGlobalModule | Where-Object { $_.Name -like "aspnetcoremodule*" }
                                                                            if ($Status)
                                                                            {
                                                                                # Check if IIS can find ASP.NET modules
                                                                                if ($aspModules.Count -lt 1)
                                                                                {
                                                                                    $Status = $False
                                                                                    $IISStatus = $False
                                                                                    $NOKMessages = @("IIS can't find ASP.NET modules")
                                                                                }
                                                                                else
                                                                                {
                                                                                    $IISStatus = $True
                                                                                }
                                                                            }
                                                                        }


                                                                        return $(CreateResult -Status $Status -IISStatus $IISStatus -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                                    }
                }

                if($requireDotNetCoreHostingBundle3) {
                    $RequirementStatuses += CreateRequirementStatus -Title ".NET Core 3.1 Windows Server Hosting" `
                                                                    -ScriptBlock `
                                                                    {
                                                                        $Status = $False
                                                                        foreach ($version in GetDotNetCoreHostingBundleVersions)
                                                                        {
                                                                            # Check .NET Core 3.1
                                                                            if (([version]$version).Major -eq 3 -and ([version]$version) -ge [version]$script:OSDotNetCoreHostingBundleReq['3']['Version']) {
                                                                                $Status = $True
                                                                            }
                                                                        }
                                                                        $OKMessages = @("Minimum .NET Core 3.1 Windows Server Hosting found.")
                                                                        $NOKMessages = @("Minimum .NET Core 3.1 Windows Server Hosting not found.")
                                                                        $IISStatus = $True

                                                                        if (Get-Command Get-WebGlobalModule -errorAction SilentlyContinue)
                                                                        {
                                                                            $aspModules = Get-WebGlobalModule | Where-Object { $_.Name -eq "aspnetcoremodulev2" }
                                                                            if ($Status)
                                                                            {
                                                                                # Check if IIS can find ASP.NET modules
                                                                                if ($aspModules.Count -lt 1)
                                                                                {
                                                                                    $Status = $False
                                                                                    $IISStatus = $False
                                                                                    $NOKMessages = @("IIS can't find ASP.NET modules")
                                                                                }
                                                                                else
                                                                                {
                                                                                    $IISStatus = $True
                                                                                }
                                                                            }
                                                                        }


                                                                        return $(CreateResult -Status $Status -IISStatus $IISStatus -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                                    }
                }

                if ($requireDotNetHostingBundle6) {
                    $RequirementStatuses += CreateRequirementStatus -Title ".NET 6.0 Windows Server Hosting" `
                                                                    -ScriptBlock `
                                                                    {
                                                                        $Status = $False
                                                                        foreach ($version in GetDotNetHostingBundleVersions)
                                                                        {
                                                                            # Check version 6.0
                                                                            if (([version]$version).Major -eq 6 -and ([version]$version) -ge [version]$script:OSDotNetCoreHostingBundleReq['6']['Version']) {
                                                                                $Status = $True
                                                                            }
                                                                        }
                                                                        $OKMessages = @("Minimum .NET 6.0.6 Windows Server Hosting found.")
                                                                        $NOKMessages = @("Minimum .NET 6.0.6 Windows Server Hosting not found.")
                                                                        $IISStatus = $True

                                                                        if (Get-Command Get-WebGlobalModule -errorAction SilentlyContinue)
                                                                        {
                                                                            $aspModules = Get-WebGlobalModule | Where-Object { $_.Name -eq "aspnetcoremodulev2" }
                                                                            if ($Status)
                                                                            {
                                                                                # Check if IIS can find ASP.NET modules
                                                                                if ($aspModules.Count -lt 1)
                                                                                {
                                                                                    $Status = $False
                                                                                    $IISStatus = $False
                                                                                    $NOKMessages = @("IIS can't find ASP.NET modules")
                                                                                }
                                                                                else
                                                                                {
                                                                                    $IISStatus = $True
                                                                                }
                                                                            }
                                                                        }


                                                                        return $(CreateResult -Status $Status -IISStatus $IISStatus -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                                    }
                }

                if ($requireDotNetHostingBundle8) {
                    $RequirementStatuses += CreateRequirementStatus -Title ".NET 8.0 Windows Server Hosting" `
                                                                    -ScriptBlock `
                                                                    {
                                                                        $Status = $False
                                                                        foreach ($version in GetDotNetHostingBundleVersions)
                                                                        {
                                                                            # Check version 8.0
                                                                            if (([version]$version).Major -eq 8 -and ([version]$version) -ge [version]$script:OSDotNetCoreHostingBundleReq['8']['Version']) {
                                                                                $Status = $True
                                                                            }
                                                                        }
                                                                        $OKMessages = @("Minimum .NET 8.0.0 Windows Server Hosting found.")
                                                                        $NOKMessages = @("Minimum .NET 8.0.0 Windows Server Hosting not found.")
                                                                        $IISStatus = $True

                                                                        if (Get-Command Get-WebGlobalModule -errorAction SilentlyContinue)
                                                                        {
                                                                            $aspModules = Get-WebGlobalModule | Where-Object { $_.Name -eq "aspnetcoremodulev2" }
                                                                            if ($Status)
                                                                            {
                                                                                # Check if IIS can find ASP.NET modules
                                                                                if ($aspModules.Count -lt 1)
                                                                                {
                                                                                    $Status = $False
                                                                                    $IISStatus = $False
                                                                                    $NOKMessages = @("IIS can't find ASP.NET modules")
                                                                                }
                                                                                else
                                                                                {
                                                                                    $IISStatus = $True
                                                                                }
                                                                            }
                                                                        }


                                                                        return $(CreateResult -Status $Status -IISStatus $IISStatus -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                                    }
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
                                                            $Status = $(GetDotNet4Version) -ge $script:OSDotNetReqForMajor[$MajorVersion]['Value']
                                                            $OKMessages = @("Minimum .NET version $($script:OSDotNetReqForMajor[$MajorVersion]['Version']) found.")
                                                            $NOKMessages = @("Minimum .NET version $($script:OSDotNetReqForMajor[$MajorVersion]['Version']) not found.")

                                                            return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                                                        }
        if ($requireMSBuildTools)
        {
            $RequirementStatuses += CreateRequirementStatus -Title "Microsoft Build Tools" `
                -ScriptBlock `
                {
                    $MSBuildInstallInfo = $(GetMSBuildToolsInstallInfo)

                    $Status = $(IsMSBuildToolsVersionValid -MajorVersion $MajorVersion -InstallInfo $MSBuildInstallInfo)
                    $OKMessages = @("$($MSBuildInstallInfo.LatestVersionInstalled) is installed.")
                    $NOKMessages = @("No valid MS Build Tools version found, this is an OutSystems requirement.")

                    return $(CreateResult -Status $Status -OKMessages $OKMessages -NOKMessages $NOKMessages)
                }
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
                                                            $OptionalsStatus = $True
                                                            $OKMessages = @("All Event Logs are correctly configured.")
                                                            $NOKMessages = @()

                                                            try
                                                            {
                                                                foreach ($EventLogName in $OSWinEventLogName)
                                                                {
                                                                    $EventLog = $(Get-EventLog -List | Where-Object { $_.Log -eq $EventLogName})

                                                                    $CheckMaxLogSize = ($EventLog.MaximumKilobytes * 1024) -lt $OSWinEventLogSize
                                                                    $CheckOverflowAction = ($EventLog.OverflowAction -ne $OSWinEventLogOverflowAction)

                                                                    if ($CheckOverflowAction) {
                                                                        #If the overflow action is OverwriteAsNeeded the registry entry we check might not exist
                                                                        $AutoBackUp = (Get-ItemPropertyValue "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\$EventLogName" -Name $OSWinEventLogAutoBackup) -eq 1
                                                                        $CheckOverflowAction = (-not $AutoBackUp)
                                                                    }

                                                                    if ($CheckMaxLogSize -or $CheckOverflowAction)
                                                                    {
                                                                        $OptionalsStatus = $False
                                                                        $NOKMessage += "Event Log '$EventLogName' is not correctly configured."

                                                                        if ($CheckMaxLogSize)
                                                                        {
                                                                            $NOKMessage += "$NOKMessage Maximum log size is under $OSWinEventLogSize."
                                                                        }

                                                                        if ($CheckOverflowAction)
                                                                        {
                                                                            $NOKMessage += "$NOKMessage 'Overwrite events as needed' or 'Archive the log when full' is not set."
                                                                        }

                                                                        $NOKMessages += $NOKMessage
                                                                    }
                                                                }
                                                            }
                                                            catch
                                                            {
                                                                $OptionalsStatus = $False
                                                                $NOKMessages += "Something went wrong when trying to obtain Event Logs information: `"$_`""
                                                            }

                                                            return $(CreateResult -Status $Status -OptionalsStatus $OptionalsStatus -OKMessages $OKMessages -NOKMessages $NOKMessages)
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
                $GlobalRequirementsResults.Success = $False
            }
            if (-not $RequirementStatus.OptionalsStatus)
            {
                $GlobalRequirementsResults.OptionalsStatus = $False
            }
            if (-not $RequirementStatus.IISStatus)
            {
                $GlobalRequirementsResults.IISStatus = $False
            }
        }

        return $GlobalRequirementsResults
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
