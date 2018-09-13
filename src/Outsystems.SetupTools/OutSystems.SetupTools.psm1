param(
    [parameter(Position=0,Mandatory=$false)][boolean]$Telemetry=$true,
    [parameter(Position=1,Mandatory=$false)][string]$Tier,
    [parameter(Position=2,Mandatory=$false)][string]$InstKey

)
# Get definition files.
$Lib  = @( Get-ChildItem -Path $PSScriptRoot\Lib\*.ps1 -ErrorAction SilentlyContinue )
$Functions = @( Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
Foreach($Import in @($Lib + $Functions))
{
    Try
    {
        . $Import.Fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($Import.Fullname): $_"
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
Export-ModuleMember -Function *-*

# Telemetry switch
$script:OSTelEnabled = $Telemetry

# Add instrumentation key if provided
if ($Tier)
{
    $script:OSTelTier = $Tier
}

# Add instrumentation key if provided
if ($InstKey)
{
    $script:OSTelAppInsightsKeys += $InstKey
}

# Send module load event
SendModuleLoadEvent
