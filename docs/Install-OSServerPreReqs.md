---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Install-OSServerPreReqs

## SYNOPSIS
Install the pre-requisites for the platform server.

## SYNTAX

```
Install-OSServerPreReqs [-MajorVersion] <String> [[-InstallIISMgmtConsole] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
This will install the pre-requisites for the platform server version specified.
It will install .NET 4.6.1 if needed.
After installing .NET a reboot will be probably needed.
You should also run the Test-OSServerSoftwareReqs and the Test-OSServerHardwareReqs to check if your server is supported for Outsystems.

## EXAMPLES

### EXAMPLE 1
```
Install-OSServerPreReqs -MajorVersion "10.0"
```

Install-OSServerPreReqs -MajorVersion "11.0" -InstallIISMgmtConsole:$false

## PARAMETERS

### -MajorVersion
Specifies the platform major version.
The function will install the pre-requisites for the version specified on this parameter.
Supported values: 10.0 or 11.0

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

### -InstallIISMgmtConsole
Specifies if the IIS Managament Console will be installed.
On servers without GUI this feature can't be installed.
So you should set this parameter to $false.
Defaults to $true

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
