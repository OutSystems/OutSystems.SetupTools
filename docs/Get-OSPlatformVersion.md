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
Get-OSPlatformVersion [[-ServiceCenterHost] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This will return the Outsystems platform version from Service Center API.

## EXAMPLES

### EXAMPLE 1
```
Get-OSPlatformVersion -ServiceCenterHost "10.0.0.1"
```

Using the pipeline
"10.0.0.1", "10.0.0.1", "10.0.0.3" | Get-OSPlatformVersion

## PARAMETERS

### -ServiceCenterHost
{{Fill ServiceCenterHost Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Host

Required: False
Position: 1
Default value: 127.0.0.1
Accept pipeline input: True (ByValue)
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
