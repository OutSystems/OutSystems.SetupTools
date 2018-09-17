---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Install-OSServiceStudio

## SYNOPSIS
Installs or updates the Outsystems development environment.

## SYNTAX

### Remote (Default)
```
Install-OSServiceStudio [-InstallDir <String>] -Version <String> [<CommonParameters>]
```

### Local
```
Install-OSServiceStudio [-InstallDir <String>] -SourcePath <String> -Version <String> [<CommonParameters>]
```

## DESCRIPTION
This will installs or updates the development environment.
if the development environment is already installed it will check if version to be installed is higher than the current one.

## EXAMPLES

### EXAMPLE 1
```
Install-OSServiceStudio -Version "10.0.823.0"
```

Install-OSServiceStudio -Version "10.0.823.0" -InstallDir D:\Outsystems
Install-OSServiceStudio -Version "10.0.823.0" -InstallDir D:\Outsystems -SourcePath c:\temp

## PARAMETERS

### -InstallDir
Where the development environment will be installed.
if the development environment is already installed, this parameter has no effect.
If not specified will default to %ProgramFiles%\Outsystems

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $OSDefaultInstallDir
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourcePath
if specified, the function will use the sources in that path.
if not specified it will download the sources from the Outsystems repository.

```yaml
Type: String
Parameter Sets: Local
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
The version to be installed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Outsystems.SetupTools.InstallResult

## NOTES
All error are non-terminating.
The function caller should decide what to do using the -ErrorAction parameter or using the $ErrorPreference variable.

## RELATED LINKS
