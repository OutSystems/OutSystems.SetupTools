---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Install-OSPlatformLicense

## SYNOPSIS
Installs the OutSystems platform license.

## SYNTAX

```
Install-OSPlatformLicense [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
This will install the OutSystems platform license.
If the license file is not specified, a 30 days trial license will be installed.

## EXAMPLES

### EXAMPLE 1
```
Install-OSPlatformLicense -Path c:\temp
```

## PARAMETERS

### -Path
The path of the license.lic file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

## NOTES

## RELATED LINKS
