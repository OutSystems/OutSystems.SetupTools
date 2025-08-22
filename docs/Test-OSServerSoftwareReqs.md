---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Test-OSServerSoftwareReqs

## SYNOPSIS
Checks if the server has a supported operating system for OutSystems.

## SYNTAX

```
Test-OSServerSoftwareReqs [-MajorVersion] <String> [<CommonParameters>]
```

## DESCRIPTION
This will check if the server has a supported operating system to run the Outsystems platform.

## EXAMPLES

### EXAMPLE 1
```
Test-OSServerSoftwareReqs -MajorVersion "11"
```

## PARAMETERS

### -MajorVersion
Specifies the platform major version.
Accepted values: 11

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

### Outsystems.SetupTools.TestResult
## NOTES

## RELATED LINKS
