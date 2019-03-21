---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSServiceStudioInstallDir

## SYNOPSIS
DEPRECATED - Use Get-OSServiceStudioInfo
Returns where the OutSystems development environment (Service Studio) is installed.

## SYNTAX

```
Get-OSServiceStudioInstallDir [-MajorVersion] <String> [<CommonParameters>]
```

## DESCRIPTION
This will returns where the OutSystems development environment is installed.
Since we can have multiple development environments installed, you need to specify the major version to get.

## EXAMPLES

### EXAMPLE 1
```
Get-OSServiceStudioInstallDir -MajorVersion "10.0"
```

## PARAMETERS

### -MajorVersion
Major version.
9.0, 9.1, 10.0, 11.0, ...

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
