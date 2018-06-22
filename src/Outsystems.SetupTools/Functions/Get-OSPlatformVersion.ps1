Function Get-OSPlatformVersion
{
    [CmdletBinding()]
    [OutputType([System.Version])]
    Param(
        [Parameter()]
        [string]$Host = "127.0.0.1"
    )

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    Try{
        $ServiceProxy = New-WebServiceProxy -Uri "http://$Host/ServiceCenter/OutSystemsPlatform.asmx?wsdl" -Namespace Outsystems -ErrorAction Stop
        $RefDummy = ""
        $Version = $ServiceProxy.GetPlatformInfo(([ref]$RefDummy))

        Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Returning $Version"

    } Catch {
        Throw "Error contacting service center."
    }

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

    Return [System.Version]$Version
}