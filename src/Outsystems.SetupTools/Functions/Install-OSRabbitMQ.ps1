function Install-OSRabbitMQ
{
    <#
    .SYNOPSIS
    Installs and configures RabbitMQ for OutSystems.

    .DESCRIPTION
    This will install and configure RabbitMQ for Outsystems.
    It will use the default guest user to perform the RabbitMQ configuration.
    It will skip the configuration and installation if RabbitMQ is already installed.

    .PARAMETER VirtualHosts
    List of virtual hosts to add to RabbitMQ.

    .PARAMETER AdminUser
    Add the specified user as admin of RabbitMQ.

    .PARAMETER RemoveGuestUser
    Removes the default guest user.

    .EXAMPLE
    Install-OSRabbitMQ

    .EXAMPLE
    Install-OSRabbitMQ -VirtualHosts '/OutSystems'

    .EXAMPLE
    Install-OSRabbitMQ -VirtualHosts @('/OutSystems', '/AnotherHost')

    .EXAMPLE
    $user = Get-Credential
    Install-OSRabbitMQ -VirtualHosts @('/OutSystems', '/AnotherHost') -AdminUser $user -RemoveGuestUser

    .EXAMPLE
    $user = New-Object System.Management.Automation.PSCredential ('superuser', $(ConvertTo-SecureString 'superpass' -AsPlainText -Force))
    Install-OSRabbitMQ -VirtualHosts @('/OutSystems', '/AnotherHost') -AdminUser $user -RemoveGuestUser

    .NOTES
    After uninstalling RabbitMQ you need to reboot the machine. Some registry keys are only deleted after rebooting.
    So in case you want to reinstall RabbitMQ, you need to uninstall, reboot and then you can rerun this cmdlet
    RabbitMQ configuration is only done when installed. Rerunning this CmdLet will not reconfigure RabbitMQ

    #>

    [CmdletBinding(DefaultParameterSetName='__AllParameterSets')]
    [OutputType('Outsystems.SetupTools.InstallResult')]
    param(
        [Parameter()]
        [string[]]$VirtualHosts,

        [Parameter(ParameterSetName = 'AddAdminUser')]
        [switch]$RemoveGuestUser,

        [Parameter(ParameterSetName = 'AddAdminUser', Mandatory = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$AdminUser
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
            Message      = 'RabbitMQ for Outsystems successfully installed'
        }

        $osInstallDir = GetServerInstallDir
        $rabbitMQErlangInstallDir = "$osInstallDir\thirdparty\Erlang"
        $rabbitMQInstallDir = "$osInstallDir\thirdparty\RabbitMQ Server"
    }

    process
    {
        #region check
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'The current user is not Administrator or not running this script in an elevated session'

            return $installResult
        }

        if ($(-not $(GetServerVersion)) -or $(-not $osInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Outsystems platform is not installed"
            WriteNonTerminalError -Message "Outsystems platform is not installed"

            $installResult.Success = $false
            $installResult.ExitCode = -1
            $installResult.Message = 'Outsystems platform is not installed'

            return $installResult
        }

        # Check if Erlang is installed on the right folder and has the right version
        if (-not $(GetErlangInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang not found. We will try to download and install"
            $installErlang = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang already installed at $(GetErlangInstallDir)"
        }

        if (-not $(GetRabbitInstallDir))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ not found. We will try to download and install"
            $installRabbitMQ = $true
        }
        else
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ already installed at $(GetRabbitInstallDir)"
        }
        #endregion

        #region install
        if ($installErlang)
        {
            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing Erlang"
                $exitCode = InstallErlang -InstallDir $rabbitMQErlangInstallDir
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the Erlang installation"
                WriteNonTerminalError -Message "Error downloading or starting the Erlang installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the Erlang installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang successfully installed"
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Erlang successfully installed but a reboot is needed!!!!! Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing Erlang. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing Erlang. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing Erlang'

                    return $installResult
                }
            }
        }

        if ($installRabbitMQ)
        {
            try
            {
                InstallRabbitMQPreReqs -RabbitBaseDir $OSRabbitMQBaseDir
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error configuring the pre-requisites for RabbitMQ"
                WriteNonTerminalError -Message "Error configuring the pre-requisites for RabbitMQ"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error configuring the pre-requisites for RabbitMQ'

                return $installResult
            }

            try
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Installing RabbitMQ"
                $exitCode = InstallRabbitMQ -InstallDir $rabbitMQInstallDir
            }
            catch
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error downloading or starting the RabbitMQ installation"
                WriteNonTerminalError -Message "Error downloading or starting the RabbitMQ installation"

                $installResult.Success = $false
                $installResult.ExitCode = -1
                $installResult.Message = 'Error downloading or starting the RabbitMQ installation'

                return $installResult
            }

            switch ($exitCode)
            {
                0
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ successfully installed"
                }

                {$_ -in 3010, 3011}
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ successfully installed but a reboot is needed!!!!! Exit code: $exitCode"
                    $installResult.RebootNeeded = $true
                }

                default
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Error installing RabbitMQ. Exit code: $exitCode"
                    WriteNonTerminalError -Message "Error installing RabbitMQ. Exit code: $exitCode"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Error installing RabbitMQ'

                    return $installResult
                }
            }

            # Rabbit installed. Lets wait to become available
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Waiting for RabbitMQ to become available"
            $waitCounter = 0
            do
            {
                $wait = $false
                if (-not $(isRabbitMQAvailable))
                {
                    $wait = $true
			        Start-Sleep -Seconds 5
                    $waitCounter += 5
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "$waitCounter secs have passed while waiting for RabbitMQ to become available ..."
                }

                if($waitCounter -ge $OSRabbitMQServiceWaitTimeout) {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "Timeout occurred while waiting for RabbitMQ to become available"
                    WriteNonTerminalError -Message "Timeout occurred while waiting for RabbitMQ to become available"

                    $installResult.Success = $false
                    $installResult.ExitCode = $exitCode
                    $installResult.Message = 'Timeout occurred while waiting for RabbitMQ to become available'

                    return $installResult
                }
            }
            while ($wait)

            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "RabbitMQ is now available!!"

            #region RabbitConfig
            foreach ($virtualHost in $VirtualHosts)
            {
                try {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding virtual host $virtualHost"
                    RabbitMQAddVirtualHost -VirtualHost $virtualHost
                }
                catch {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error adding the virtual host $virtualHost to RabbitMQ"
                    WriteNonTerminalError -Message "Error adding the virtual host $virtualHost to RabbitMQ"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = "Error adding the virtual host $virtualHost to RabbitMQ"

                    return $installResult
                }
            }

            if ($PsCmdlet.ParameterSetName -eq 'AddAdminUser')
            {
                try {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Adding admin user $($AdminUser.UserName)"
                    RabbitMQAddAdminUser -Credential $AdminUser
                    RabbitMQAddAPermisionToAllVirtualHosts -User $($AdminUser.UserName)
                }
                catch {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error adding admin user $($AdminUser.UserName) or setting permissions on the virtual hosts"
                    WriteNonTerminalError -Message "Error adding admin user $($AdminUser.UserName) or setting permissions on the virtual hosts"

                    $installResult.Success = $false
                    $installResult.ExitCode = -1
                    $installResult.Message = "Error adding admin user $($AdminUser.UserName) or setting permissions on the virtual hosts"

                    return $installResult
                }

                if ($RemoveGuestUser)
                {
                    try {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Removing guest user from RabbitMQ"
                        RabbitMQRemoveGuestUser -Credential $AdminUser
                    }
                    catch {
                        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error removing guest user from RabbitMQ"
                        WriteNonTerminalError -Message "Error removing guest user from RabbitMQ"

                        $installResult.Success = $false
                        $installResult.ExitCode = -1
                        $installResult.Message = "Error removing guest user from RabbitMQ"

                        return $installResult
                    }
                }
            }
            #endregion
        }
        #endregion

        if ($installResult.RebootNeeded)
        {
            $installResult.ExitCode = 3010
            $installResult.Message = 'RabbitMQ for Outsystems successfully installed but a reboot is needed'
        }
        return $installResult
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
