---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version: http://go.microsoft.com/fwlink/?LinkID=217034
schema: 2.0.0
---

# Test-OSServerHardwareReqs

## SYNOPSIS
Checks if the server has the necessary hardware requirements for the OutSystems platform server.

## SYNTAX

```
Test-OSServerHardwareReqs [-MajorVersion] <String> [<CommonParameters>]
```

## DESCRIPTION
This will check if the server has the necessary hardware requirements to run the Outsystems platform.
Checks available RAM and the number of available CPUs.

## EXAMPLES

### EXAMPLE 1
```
Test-OSServerSoftwareReqs -MajorVersion "10.0"
```

## PARAMETERS

### -MajorVersion
Specifies the platform major version.
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
