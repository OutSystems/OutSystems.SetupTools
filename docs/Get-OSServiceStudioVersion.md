---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSServiceStudioVersion

## SYNOPSIS
DEPRECATED - Use Get-OSServiceStudioInfo
Returns the OutSystems development environment (Service Studio) installed version.

## SYNTAX

```
Get-OSServiceStudioVersion [-MajorVersion] <String> [<CommonParameters>]
```

## DESCRIPTION
This will returns the OutSystems platform installed version.
Since we can have multiple development environments installed, you need to specify the major version to get.

## EXAMPLES

### EXAMPLE 1
```
Get-OSServiceStudioVersion -MajorVersion "11"
```

## PARAMETERS

### -MajorVersion
Major version.
11, ...

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Version
## NOTES

## RELATED LINKS
