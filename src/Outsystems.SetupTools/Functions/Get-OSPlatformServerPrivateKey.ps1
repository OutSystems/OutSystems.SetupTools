Function Get-OSPlatformServerPrivateKey
{
    <#
    .SYNOPSIS
    Returns where the Outsystems platform server private key.

    .DESCRIPTION
    This will returns the Outsystems platform server private key. Will throw an exception if the platform is not installed.

    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    Param()

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 0 -Message "Starting"
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking if server is installed."

    $InstallDir = GetServerInstallDir
    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Server is installed at $InstallDir"

    $Path = "$InstallDir\private.key"

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Checking if file exists at $Path"
    If( -not (Test-Path -Path $Path)){ Throw "Cant file the setup file: $Path"}

    Get-Content $Path | ForEach-Object {

        $Regex = "^--*"

        If(-not ($_ -match $regex)){
            $pKey = $_
            Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 1 -Message "Found private key: $pKey"
        }
    }

    If( -not $pKey){ Throw "Error getting the private key in file: $Path"}

    return $pKey

    Write-MyVerbose -FuncName $($MyInvocation.Mycommand) -Phase 2 -Message "Ending"
}