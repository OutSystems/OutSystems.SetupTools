function Set-OSServerWindowsDefender {

    <#

    .SYNOPSIS
    Creates exclusions in Windows Defender for directories and processes according to OutSystems and Microsoft recommendations.

    .DESCRIPTION
    This will create exclusions in Windows Defender for critical directories and processes used by IIS, .NET Framework and OutSystems services, according to OutSystems and Microsoft recommendations.
    https://success.outsystems.com/documentation/11/setup_outsystems_infrastructure_and_platform/setting_up_outsystems/performance_best_practices_for_your_outsystems_infrastructure/


    .PARAMETER SkipSystemTempExclusion
    If specified, the exclusion for the System TEMP folder (usually C:\Windows\Temp) will not be added
    This can be useful for cases where the security team doesn't agree with applying this exclusion.

    .EXAMPLE
    Set-OSServerWindowsDefender -SkipSystemTempExclusion

    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$SkipSystemTempExclusion
    )

    begin {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        #region Check status of Windows Defender

        $WinDefenderStatus = Get-MpComputerStatus
        if ( ($null -eq $WinDefenderStatus) -or 
            ($WinDefenderStatus.AntivirusEnabled -eq $false) -or 
            ($WinDefenderStatus.AMRunningMode -eq 'Not running') ) {
            Write-Error 'Windows Defender is either not installed, not running or has AntiVirus features disabled.' -ErrorAction Stop
        }

        #endregion
    }

    process {

        #region Get variables

        # Get platform installation path variables
        $PSInstallDir = Get-OSServerInstallDir -ErrorAction Stop

        # Get path to the profile of the account running the OutSystems Deployment Controller Service
        $CntrllrSvcAccountName = (Get-CimInstance -ClassName CIM_Service -Filter "name='OutSystems Deployment Controller Service'").StartName
        $CntrllrSvcAccount = New-Object System.Security.Principal.NTAccount($CntrllrSvcAccountName)
        $CntrllrSvcAccountSID = $CntrllrSvcAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
        $CntrllrSvcAccountProfilePath = (Get-CimInstance -ClassName Win32_UserProfile -Filter "SID='$CntrllrSvcAccountSID'").LocalPath

        # Get path to Temporary .NET Files directory
        $TempDotNETFilesPath = (Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT' -Filter 'system.web/compilation' -Name 'tempDirectory').Value
        if ($TempDotNETFilesPath -eq '') {
            $TempDotNETFilesPath = "$env:SystemRoot\Microsoft.Net\Framework64\v4.0.30319\Temporary ASP.NET Files"
        }

        # Get path to IIS Temporary Compression Files directory
        $IISTempCompFilesPath = [System.Environment]::ExpandEnvironmentVariables((Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
                                                                                                            -Filter 'system.webServer/httpCompression' `
                                                                                                            -Name 'directory').Value)
        

        # Get path to IIS Logs directory
        $IISLogFilesPath = [System.Environment]::ExpandEnvironmentVariables((Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
                                                                                                        -Filter 'system.applicationHost/log/centralW3CLogFile' `
                                                                                                        -Name 'directory').Value)

        #endregion

        #region Add OutSystems recommended exclusions to Windows Defender
    
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding OutSystems recomended exclusions to Windows Defender"
        try {
            # Platform installation directory
            Add-MpPreference -ExclusionPath $PSInstallDir

            # .NET Framework config directory
            Add-MpPreference -ExclusionPath "$env:SystemRoot\Microsoft.Net\Framework64\v4.0.30319\Config"

            # Temporary .NET Files directory
            Add-MpPreference -ExclusionPath $TempDotNETFilesPath

            # OutSystems Services processes
            Add-MpPreference -ExclusionProcess "$PSInstallDir\CompilerService\CompilerService.exe"
            Add-MpPreference -ExclusionProcess "$PSInstallDir\DeployService\DeployService.exe"
            Add-MpPreference -ExclusionProcess "$PSInstallDir\Scheduler\Scheduler.exe"

            # Controller service account Temp directory
            Add-MpPreference -ExclusionPath "$CntrllrSvcAccountProfilePath\AppData\Local\Temp"

            # System Temp directory
            if ($SkipSystemTempExclusion -ne $true) {
                Add-MpPreference -ExclusionPath "$env:SystemRoot\Temp"
            }
        }
        catch {
            Write-Error 'Failed to add the OutSystems recommended exclusions to Windows Defender'
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows Defender exclusions added successfully"

    #endregion

        #region Add Microsoft recomended exclusions to Windows Defender

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding Microsoft recomended exclusions to Windows Defender"
        try {
            # IIS Config directory
            Add-MpPreference -ExclusionPath "$env:SystemRoot\System32\inetsrv\config"

            # IIS temp files directory
            Add-MpPreference -ExclusionPath "$env:SystemDrive\inetpub\temp"

            # IIS Temporary Compressed Files (by defaut inthe above dir, but can be changed)
            Add-MpPreference -ExclusionPath $IISTempCompFilesPath

            # IIS Logs directory
            Add-MpPreference -ExclusionPath $IISLogFilesPath

        }
        catch {
            Write-Error 'Failed to add the Microsoft recommended exclusions to Windows Defender'
        }
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Windows Defender exclusions added successfully"

        #endregion

    }

    end {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }

}