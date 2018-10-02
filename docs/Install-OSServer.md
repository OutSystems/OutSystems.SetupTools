---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Install-OSServer

## SYNOPSIS
Installs or updates the OutSystems Platform server.

## SYNTAX

### Remote (Default)
```
Install-OSServer [-InstallDir <String>] -Version <String> [<CommonParameters>]
```

### Local
```
Install-OSServer [-InstallDir <String>] -SourcePath <String> -Version <String> [<CommonParameters>]
```

## DESCRIPTION
This will install or update the OutSystems platform server.
If the platform is already installed, the function will check if version to be installed is higher than the current one and update it.

## EXAMPLES

### EXAMPLE 1
```
Install-OSServer -Version "10.0.823.0"
```

### EXAMPLE 2
```
Install-OSServer -Version "10.0.823.0" -InstallDir D:\Outsystems
```

### EXAMPLE 3
```
Install-OSServer -Version "10.0.823.0" -InstallDir D:\Outsystems -SourcePath c:\temp
```

## PARAMETERS

### -InstallDir
Where the platform will be installed.
if the platform is already installed, this parameter has no effect.
If not specified, it will default to %ProgramFiles%\Outsystems

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
If specified, the cmdlet will use the sources in that path.
If not specified it will download the sources from the OutSystems repository.

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

## RELATED LINKS
