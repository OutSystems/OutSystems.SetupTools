#requires -Version 5.1
#requires -Modules @{ModuleName="InvokeBuild";ModuleVersion="3.0.0"}

# Include: Settings
. "$PSScriptRoot/outsystems.setuptools.settings.ps1"

# Synopsis: Install build prerequisites
Task InstallDependencies {

    # platyPS
    if (-not (Get-Module platyPS -ListAvailable))
    {
        Install-Module platyPS -Scope CurrentUser -Force
    }
}

# Synopsis: Initialize the release folder folders
Task Clean {

    Write-Output "Initializing the release folder"
    if (Test-Path -Path $Release)
    {
        Remove-Item "$Release/*" -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Release -Force | Out-Null
}

# Synopsis: Lint Code with PSScriptAnalyzer
Task Analyze Clean, {

    # Check for PSScriptAnalyzer module
    Write-Output "Check for PSScripAnalyzer module"
    if (-not (Get-Module PSScriptAnalyzer -ListAvailable))
    {
        Write-Output "Trying to install missing module"
        Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -ErrorAction Stop
    }

    Write-Output "Analyzing code"
    $analysisResult = Invoke-ScriptAnalyzer -Path $ModulePath -Settings "$PSScriptRoot\ScriptAnalyzerSettings.psd1" -Recurse

    # Save Analyze Results as JSON
    $analysisResult | ConvertTo-Json | Set-Content (Join-Path $Release "ScriptAnalysisResults.json")

    if ($analysisResult)
    {
        $analysisResult | Format-Table
        throw "One or more issues where found."
    }
    Write-Output "All checks passed"
}

Task UnitTestsPublicFunctions {

    # Check for Pester module
    Write-Output "Check for Pester module"
    if ((Get-Module -Name Pester -ListAvailable)[0].Version -lt [version]"3.4.0")
    {
        Write-Output "Trying to install missing module"
        Install-Module Pester -Scope CurrentUser -Force -ErrorAction Stop
    }

    Write-Output "Running unit tests on public functions"
    $invokePesterParams = @{
        Path = './test/*'
        OutputFile =  (Join-Path $Release "TestResults.xml")
        OutputFormat = 'NUnitXml'
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\Functions\*.ps1" -Recurse).FullName
    }

    # Publish Test Results as NUnitXml
    $testResult = Invoke-Pester @invokePesterParams;
    $testCoverage = [int]($testResult.CodeCoverage.NumberOfCommandsExecuted / $testResult.CodeCoverage.NumberOfCommandsAnalyzed * 100)

    Write-Output "Test coverage: $testCoverage%"
}

Task . Clean, Analyze, UnitTestsPublicFunctions
