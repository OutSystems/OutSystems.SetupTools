function Publish-OSPlatformLifetime
{
    <#
    .SYNOPSIS
    Installs or updates Outsystems Lifetime.

    .DESCRIPTION
    This will install or update OutSystems Lifetime.
    You need to specify a user and a password to connect to Service Center. If you dont specify, the default admin will be used.
    It will skip the installation if already installed with the right version.
    Service Center needs to be installed using the Install-OSPlatformServiceCenter cmdlet and the OutSystems system components needs to be installed using the Publish-OSPlatformSystemComponents cmdlet.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .PARAMETER ServiceCenterUser
    Service Center username (deprecated. will be removed in future module versions).

    .PARAMETER ServiceCenterPass
    Service Center password (deprecated. will be removed in future module versions).

    .PARAMETER Credential
    PSCredential object.

    .EXAMPLE
    Using PSCredentials
    $cred = Get-Credential
    Publish-OSPlatformLifetime -Credential $cred

    .EXAMPLE
    $cred = New-Object System.Management.Automation.PSCredential ("admin", $(ConvertTo-SecureString "admin" -AsPlainText -Force))
    Publish-OSPlatformLifetime -Credential $cred

    .EXAMPLE
    Publish-OSPlatformLifetime -Force -ServiceCenterUser "admin" -ServiceCenterPass "admin"

    .NOTES
    The parameters ServiceCenterUser and ServiceCenterPass will be removed in a future module version.
    Publish-OSPlatformLifetime -Force -ServiceCenterUser "admin" -ServiceCenterPass "admin"

    The recommended way to pass credentials in PowerShell is to use the PSCredential object.

    #>

    [CmdletBinding(DefaultParameterSetName = 'PSCred')]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param (
        [Parameter(ParameterSetName = 'UserAndPass')]
        [Parameter(ParameterSetName = 'PSCred')]
        [switch]$Force,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceCenterUser = $OSSCUser,

        [Parameter(ParameterSetName = 'UserAndPass')]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceCenterPass = $OSSCPass,

        [Parameter(ParameterSetName = 'PSCred')]
        [ValidateNotNull()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$Credential = $OSSCCred
    )

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.InstallResult'
            Success      = $true
            RebootNeeded = $false
            ExitCode     = 0
            Message      = 'Outsystems lifetime successfully installed'
        }

        $osVersion = GetServerVersion
        $osInstallDir = GetServerInstallDir

        switch ($PsCmdlet.ParameterSetName)
        {
            "PSCred"
            {
                $ServiceCenterUser = $Credential.UserName
                $ServiceCenterPass = $Credential.GetNetworkCredential().Password
            }
        }
    }

    process
    {

        if ($(-not $osVersion) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Outsystems platform is not installed'

            return $installResult
        }

        if ($(GetSCCompiledVersion) -ne $osVersion)
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"
            WriteNonTerminalError -Message "Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Service Center version mismatch. You should run the Install-OSPlatformServiceCenter first'

            return $installResult
        }

        if ($(GetLifetimeCompiledVersion) -ne $osVersion)
        {
            $doInstall = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Lifetime was already published with this server version"
        }

        if ($doInstall -or $Force.IsPresent)
        {
            if ( $Force.IsPresent )
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. We will republish lifetime!!"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Lifetime. This can take a while..."

            $onLogEvent = {
                param($logLine)
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message $logLine
            }

            try
            {
                $result = PublishSolution -Solution "$osInstallDir\Lifetime.osp" -SCUser $ServiceCenterUser -SCPass $ServiceCenterPass -OnLogEvent $onLogEvent
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the lifetime installer"
                WriteNonTerminalError -Message "Error lauching the lifetime installer"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error lauching the lifetime installer'

                return $installResult
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTool exit code: $($result.ExitCode)"

            if ($result.ExitCode -ne 0)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing lifetime. Return code: $($result.ExitCode)"
                WriteNonTerminalError -Message "Error installing lifetime. Return code: $($result.ExitCode)"

                $installResult.Success = $false
                $installResult.ExitCode = $result.ExitCode
                $installResult.Message = 'Error installing lifetime'

                return $installResult
            }

            try
            {
                SetLifetimeCompiledVersion -LifetimeVersion $osVersion
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the lifetime version"
                WriteNonTerminalError -Message "Error setting the lifetime version"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error setting the lifetime version'

                return $installResult
            }

        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Lifetime successfully installed!!"
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
