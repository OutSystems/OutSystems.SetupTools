param(
    [parameter(Position=0,Mandatory=$false)][boolean]$ParamTelemetry=$true,
    [parameter(Position=1,Mandatory=$false)][string]$ParamTier,
    [parameter(Position=2,Mandatory=$false)][string]$ParamInstKey

)
# Module global preference variables
$script:ErrorActionPreference = "Continue"

# Get definition files
$moduleLibs  = @( Get-ChildItem -Path $PSScriptRoot\Lib\*.ps1 -ErrorAction SilentlyContinue )
$moduleFunctions = @( Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
foreach($moduleToImport in @($moduleLibs + $moduleFunctions))
{
    try
    {
        . $moduleToImport.Fullname
    }
    catch
    {
        Write-Error -Message "Failed to import function $($moduleToImport.Fullname): $_"
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
Export-ModuleMember -Function *-*

# Telemetry switch
$script:OSTelEnabled = $ParamTelemetry

# Add instrumentation key if provided
if ($ParamTier)
{
    $script:OSTelTier = $ParamTier
}

# Add instrumentation key if provided
if ($ParamInstKey)
{
    $script:OSTelAppInsightsKeys += $ParamInstKey
}

# Send module load event
SendModuleLoadEvent
