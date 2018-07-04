Function New-OSPlatformPrivateKey {
    <#
    .SYNOPSIS
    Returns a new Outsystems environment private key.

    .DESCRIPTION
    This will return a new platform private key.

    .NOTES
    If you are installing a farm environment, the private keys from the Outsystems controller and the frontends must match (private.key file).
    With this function you can pre-generate the key and use the output in the Invoke-OSConfigurationTool.

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    }

    Process {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Generating private key"
        Try {
            $NewKey = [OutSystems.HubEdition.RuntimePlatform.NewRuntime.Authentication.Keys]::GenerateEncryptKey()
        }
        Catch {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Error generating a new private key"
            Throw "Error generating a new private key"
        }
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $NewKey"
        Return $NewKey
    }

    End {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}