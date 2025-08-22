---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSServiceStudioInfo

## SYNOPSIS
Returns where the OutSystems Service Studio install location and version.

## SYNTAX

```
Get-OSServiceStudioInfo [-MajorVersion] <String> [<CommonParameters>]
```

## DESCRIPTION
This will returns where the OutSystems Service Studio install location and version.
Since we can have multiple development environments installed, you need to specify the major version to get.

## EXAMPLES

### EXAMPLE 1
```
Get-OSServiceStudioInfo -MajorVersion "11"
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

### Outsystems.SetupTools.ServiceStudioInfo
## NOTES

## RELATED LINKS
