---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version: http://go.microsoft.com/fwlink/?LinkID=217034
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
Test-OSServerSoftwareReqs -MajorVersion "10.0"
```

## PARAMETERS

### -MajorVersion
Specifies the platform major version.
The function will install the pre-requisites for the version specified on this parameter.
Accepted values: 10.0 or 11.0

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

### Outsystems.SetupTools.TestResult

## NOTES

## RELATED LINKS
