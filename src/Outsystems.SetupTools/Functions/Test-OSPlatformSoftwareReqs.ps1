Function Test-OSPlatformSoftwareReqs
{
    <#
    .SYNOPSIS
    Checks if the server has a supported operating system and software installed.

    .DESCRIPTION
    This will check if the server has a supported operating system and the right .NET version to run the Outsystems platform.
    Will throw an exception if the server does not meet the requirements.

    #>

    [CmdletBinding()]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"

    #Check Operating System Version
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking Operating System version"
    If([System.Version]$(GetOperatingSystemVersion) -lt [System.Version]$OSReqsMinOSVersion) { Throw "Operating system not supported. Only Windows Server 2008R2 and superior is supported" }
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Operating system is supported"

    #Check Operating System ProductType
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking Operating System product type"
    If($(GetOperatingSystemProductType) -lt $OSReqsMinOSProductType) { Throw "Operating system not supported. Only Windows Server 2008R2 and superior is supported" }
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Operating system is a server product"

    #Check for Operating System GUI
    ## TODO!!

    #Check .NET
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking .NET version"
    If($(GetDotNet4Version) -lt $OSReqsMinDotNetVersion) { Throw "Minimum .NET version not installed. NET4.6.1 or higher needs to be installed first" }
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Installed .NET is supported for OutSystems"

    #Check .NET deployment tools
    ## TODO!!


    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"

}