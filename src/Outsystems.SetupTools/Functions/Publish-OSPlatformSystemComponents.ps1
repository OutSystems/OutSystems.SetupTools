function Publish-OSPlatformSystemComponents
{
    <#
    .SYNOPSIS
    Install or update Outsystems System Components.

    .DESCRIPTION
    This will install or update the System Components.
    You need to specify a user and a password to connect to Service Center. if you dont specify, the default admin will be used.
    It will skip the installation if already installed with the right version.
    Service Center needs to be installed using the Install-OSPlatformServiceCenter function.

    .PARAMETER Force
    Forces the reinstallation if already installed.

    .PARAMETER ServiceCenterUser
    Service Center username.

    .PARAMETER ServiceCenterPass
    Service Center password.

    .PARAMETER Credential
    PSCredential object.

    .EXAMPLE
    Using PSCredentials
    $cred = Get-Credential
    Publish-OSPlatformSystemComponents -Credential $cred

    Another way
    $cred = New-Object System.Management.Automation.PSCredential ("admin", $(ConvertTo-SecureString "admin" -AsPlainText -Force))
    Publish-OSPlatformSystemComponents -Credential $cred

    This is deprecated and removed in the next version
    Publish-OSPlatformSystemComponents -Force -ServiceCenterUser "admin" -ServiceCenterPass "admin"

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

        # Initialize the results object
        $installResult = [pscustomobject]@{
            PSTypeName   = 'Outsystems.SetupTools.InstallResult'
            Success      = $true
            RebootNeeded = $false
            ExitCode     = 0
            Message      = 'Outsystems system components successfully installed'
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

        if ( $(GetSysComponentsCompiledVersion) -ne $osVersion )
        {
            $doInstall = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "The system components were already compiled with this server version"
        }

        if ($doInstall -or $Force.IsPresent)
        {
            if ( $Force.IsPresent )
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Force switch specified. Will be reinstalled!!"
            }

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Outsystems System Components. This can take a while..."
            try
            {
                $result = PublishSolution -Solution "$osInstallDir\System_Components.osp" -SCUser $ServiceCenterUser -SCPass $ServiceCenterPass
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error lauching the system components installer"
                WriteNonTerminalError -Message "Error lauching the system components installer"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error lauching the system components installer'

                return $installResult
            }

            $outputLog = $($result.Output) -Split ("`r`n")
            foreach ($logline in $outputLog)
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTOOL: $logline"
            }
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "OSPTool exit code: $($result.ExitCode)"

            if ( $result.ExitCode -ne 0 )
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing the system components. Return code: $($result.ExitCode)"
                WriteNonTerminalError -Message "Error installing the system components. Return code: $($result.ExitCode)"

                $installResult.Success = $false
                $installResult.ExitCode = $result.ExitCode
                $installResult.Message = 'Error installing the system components'

                return $installResult
            }

            try {
                SetSysComponentsCompiledVersion -SysComponentsVersion $osVersion
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error setting the system components version"
                WriteNonTerminalError -Message "Error setting the system components version"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error setting the system components version'

                return $installResult
            }
        }

        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "System components successfully installed!!"
        return $installResult
    }

    end
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
