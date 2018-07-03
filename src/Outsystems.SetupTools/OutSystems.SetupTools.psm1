#Get definition files.
$GlobalVars = @( Get-ChildItem -Path $PSScriptRoot\GlobalVars.ps1 -ErrorAction SilentlyContinue )
$Lib  = @( Get-ChildItem -Path $PSScriptRoot\Lib\*.ps1 -ErrorAction SilentlyContinue )
$Functions = @( Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($Import in @($GlobalVars + $Lib + $Functions))
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
