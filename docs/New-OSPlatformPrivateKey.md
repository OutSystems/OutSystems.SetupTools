---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# New-OSPlatformPrivateKey

## SYNOPSIS
Returns a new Outsystems environment private key.

## SYNTAX

```
New-OSPlatformPrivateKey [<CommonParameters>]
```

## DESCRIPTION
This will return a new platform private key.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES
If you are installing a farm environment, the private keys from the Outsystems controller and the frontends must match (private.key file).
With this function you can pre-generate the key and use the output in the Invoke-OSConfigurationTool.

## RELATED LINKS
