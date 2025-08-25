---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSRepoAvailableVersions

## SYNOPSIS
Lists the available OutSystems applications versions available in the online repository

## SYNTAX

```
Get-OSRepoAvailableVersions [-Application] <String> [-MajorVersion] <String> [-Latest] [<CommonParameters>]
```

## DESCRIPTION
This will list the available OutSystems applications versions available in the online repository
Usefull for the Install-OSServer and Install-OSServiceStudio cmdLets

## EXAMPLES

### EXAMPLE 1
```
Get all available versions of the OutSystems 11 platform server
```

Get-OSRepoAvailableVersions -Application 'PlatformServer' -MajorVersion '11'

### EXAMPLE 2
```
Get the latest available version of the OutSystems 11 development environment
```

Get-OSRepoAvailableVersions -Application 'ServiceStudio' -MajorVersion '11' -Latest

## PARAMETERS

### -Application
Specifies which application to retrieve the version
This can be 'PlatformServer', 'ServiceStudio', 'Lifetime'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MajorVersion
Specifies the platform major version
Accepted values: 11

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Latest
If specified, will only return the latest version

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### String
## NOTES

## RELATED LINKS
