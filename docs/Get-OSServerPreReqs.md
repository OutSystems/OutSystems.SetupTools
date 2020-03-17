---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSServerPreReqs

## SYNOPSIS
Check the status of prerequisites for the OutSystems platform server.

## SYNTAX

```
Get-OSServerPreReqs [-MajorVersion] <String> [<CommonParameters>]
```

## DESCRIPTION
This will check if the prerequisites (e.g.
IIS features, .NET Framework Version and etc.) for the OutSystems platform server are installed.

## EXAMPLES

### EXAMPLE 1
```
Get-OSServerPreReqs -MajorVersion "10"
```

## PARAMETERS

### -MajorVersion
Specifies the platform major version.
Accepted values: 10 or 11

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

## NOTES

## RELATED LINKS
