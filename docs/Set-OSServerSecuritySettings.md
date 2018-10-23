---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version: http://go.microsoft.com/fwlink/?LinkID=217034
schema: 2.0.0
---

# Set-OSServerSecuritySettings

## SYNOPSIS
Configures Windows and IIS with the recommended security settings for OutSystems.

## SYNTAX

```
Set-OSServerSecuritySettings [<CommonParameters>]
```

## DESCRIPTION
This will configure Windows and IIS with the recommended security settings for the OutSystems platform.
Will disable unsafe SSL protocols on Windows and add custom headers to protect IIS from click jacking.

## EXAMPLES

### EXAMPLE 1
```
Set-OSServerSecuritySettings
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
