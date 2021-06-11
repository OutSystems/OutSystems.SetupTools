function New-OSPlatformPrivateKey
{
    <#
    .SYNOPSIS
    Returns a new OutSystems environment private key.

    .DESCRIPTION
    This will return a new OutSystems platform private key.

    .NOTES
    If you are installing a farm environment, the private keys from the OutSystems controller and the frontends must match (private.key file).
    With this cmdlet you can pre-generate the key and use the output in the Invoke-OSConfigurationTool.

    #>

    [CmdletBinding()]
    [OutputType('System.String')]
    param ()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Generating private key"

        try
        {
            $newKey = GenerateEncryptKey
        }
        catch
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error generating a new private key"
            WriteNonTerminalError -Message "Error generating a new private key"

            return $null
        }

        $maskedNewKey = Mask-Key -Text $newKey
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Returning new generated private key: $maskedNewKey"
        return $newKey
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
