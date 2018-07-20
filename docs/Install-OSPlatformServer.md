---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Install-OSPlatformServer

## SYNOPSIS
Installs or updates the Outsystems Platform server.

## SYNTAX

### Remote
```
Install-OSPlatformServer [-InstallDir <String>] -Version <String> [<CommonParameters>]
```

### Local
```
Install-OSPlatformServer [-InstallDir <String>] -SourcePath <String> -Version <String> [<CommonParameters>]
```

## DESCRIPTION
This will installs or updates the platform server.
If the platform is already installed it will check if version to be installed is higher than the current one.
If the platform is already installed with an higher version it will throw an exception.

## EXAMPLES

### EXAMPLE 1
```
Install-OSPlatformServer -Version "10.0.823.0"
```

Install-OSPlatformServer -Version "10.0.823.0" -InstallDir D:\Outsystems
Install-OSPlatformServer -Version "10.0.823.0" -InstallDir D:\Outsystems -SourcePath c:\temp

## PARAMETERS

### -InstallDir
Where the platform will be installed.
If the platform is already installed, this parameter has no effect.
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
If specified, the function will use the sources in that path.
If not specified it will download the sources from the Outsystems repository.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
