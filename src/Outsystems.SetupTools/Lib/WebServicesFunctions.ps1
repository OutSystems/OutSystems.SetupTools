function GetHashedPassword([string]$SCPass)
{
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Password to hash $SCPass"
    $objPass = New-Object -TypeName OutSystems.Common.Password -ArgumentList $SCPass
    $HashedPass = $('#' + $objPass.EncryptedValue)
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Password hashed $HashedPass"

    return $HashedPass
}

function GetPlatformServicesWS([string]$SCHost)
{
    $PlatformServicesUri = "http://$SCHost/ServiceCenter/PlatformServices_v8_0_0.asmx?WSDL"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connecting to: $PlatformServicesUri"
    $PlatformServicesWS = New-WebServiceProxy -Uri $PlatformServicesUri -ErrorAction Stop
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connection successful"

    Return $PlatformServicesWS
}

function GetSolutionsWS([string]$SCHost)
{
    $SolutionsUri = "http://$SCHost/ServiceCenter/Solutions.asmx?WSDL"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connecting to: $SolutionsUri"
    $SolutionsWS = New-WebServiceProxy -Uri $SolutionsUri -ErrorAction Stop
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connection successful"

    Return $SolutionsWS
}

function GetOutSystemsPlatformWS([string]$SCHost)
{
    $OutSystemsPlatformUri = "http://$Host/ServiceCenter/OutSystemsPlatform.asmx?WSDL"

    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connecting to: $OutSystemsPlatformUri"
    $OutSystemsPlatformWS = New-WebServiceProxy -Uri $OutSystemsPlatformUri -ErrorAction Stop
    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 2 -Message "Connection successful"

    Return $OutSystemsPlatformWS
}
