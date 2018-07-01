Function Set-OSPlatformSecuritySettings
{

    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    # Disable unsafe SSL protocols
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Disabling unsafe SSL protocols"
    $Protocols = @("SSL 2.0", "SSL 3.0")
    ForEach ($Protocol in $Protocols) {
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Disabling $Protocol"
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Server" -Force | Set-ItemProperty -Name "Enable" -Value 0
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Client" -Force | Set-ItemProperty -Name "DisabledByDefault" -Value 1
    }



    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}