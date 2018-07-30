---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSPlatformVersion

## SYNOPSIS
Gets the platform version from Service Center.

## SYNTAX

```
Get-OSPlatformVersion [[-Host] <String>] [<CommonParameters>]
```

## DESCRIPTION
This will return the Outsystems platform version from Service Center API.
Will throw an exception if cannot get the version.

## EXAMPLES

### EXAMPLE 1
```
Get-OSPlatformVersion -Host "10.0.0.1"
```

## PARAMETERS

### -Host
Service Center address.
If not specofied will default to localhost (127.0.0.1).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 127.0.0.1
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Version

## NOTES

## RELATED LINKS
