Function Test-OSPlatformSoftwareReqs {
    <#
    .SYNOPSIS
    Checks if the server has a supported operating system and software installed.

    .DESCRIPTION
    This will check if the server has a supported operating system and the right .NET version to run the Outsystems platform.
    Will throw an exception if the server does not meet the requirements.

    #>

    [CmdletBinding()]
    Param()

    Begin {
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    }

    Process {
        #Check Operating System Version
        If ([System.Version]$(GetOperatingSystemVersion) -lt [System.Version]$OSReqsMinOSVersion) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Operating system not supported. Only Windows Server 2012 and superior is supported"
            Throw "Operating system not supported. Only Windows Server 2008R2 and superior is supported"
        }

        #Check Operating System ProductType
        If ($(GetOperatingSystemProductType) -lt $OSReqsMinOSProductType) {
            LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 3 -Message "Operating system not supported. Only Windows Server 2012 and superior is supported"
            Throw "Operating system not supported. Only Windows Server 2008R2 and superior is supported"
        }

        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Operating system is a server product 2012 or higher"

        # TODO: Check PS version
    }

    End {
        Write-Output "Your operating systems and software was validated for Outsystems"
        LogVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
    }
}