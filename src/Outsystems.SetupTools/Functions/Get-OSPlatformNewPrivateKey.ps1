Function Get-OSPlatformNewPrivateKey
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Generating private key"
    Try {
        $NewKey = [OutSystems.HubEdition.RuntimePlatform.NewRuntime.Authentication.Keys]::GenerateEncryptKey()
        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning: $NewKey"

    }
    catch {
        Throw "Error generating a private key."
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return $NewKey
}