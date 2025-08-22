---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Install-OSServerPreReqs

## SYNOPSIS
Installs the pre-requisites for the OutSystems platform server.

## SYNTAX

```
Install-OSServerPreReqs [-MajorVersion] <String> [[-SourcePath] <String>] [[-InstallIISMgmtConsole] <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
This will install the pre-requisites for the OutSystems platform server.
You should run first the Test-OSServerSoftwareReqs and the Test-OSServerHardwareReqs cmdlets to check if the server is supported for OutSystems.

## EXAMPLES

### EXAMPLE 1
```
Install-OSServerPreReqs -MajorVersion "11"
```

### EXAMPLE 2
```
Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false
```

### EXAMPLE 3
```
Install-OSServerPreReqs -MajorVersion "11" -InstallIISMgmtConsole:$false -SourcePath "c:\downloads"
```

## PARAMETERS

### -MajorVersion
Specifies the platform major version.
Accepted values: 11.

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

### -SourcePath
Specifies a local path having the pre-requisites binaries.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Sources

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InstallIISMgmtConsole
Specifies if the IIS Managament Console will be installed.
On servers without GUI this feature can't be installed so you should set this parameter to $false.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Outsystems.SetupTools.InstallResult
## NOTES

## RELATED LINKS
