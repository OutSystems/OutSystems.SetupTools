---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSPlatformModules

## SYNOPSIS
Returns the list of modules installed on an Outsystems environment.

## SYNTAX

```
Get-OSPlatformModules [-ServiceCenter <String>] [-Credential <PSCredential>] [-Filter <ScriptBlock>]
 [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
This will return the list of modules (espaces and extensions) installed on an Outsystems environment.
The function can be used to query a remote Outsystems environment for the list of modules installed using the ServiceCenterHost parameter.
If not specified, the function will query the local machine.

## EXAMPLES

### EXAMPLE 1
```
$Credential = Get-Credential
```

Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential $Credential

### EXAMPLE 2
```
$password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
```

$Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential $Credential

### EXAMPLE 3
```
Filter by module name
```

Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential $Credential -Filter {$_.Name -eq 'MyModule'}

### EXAMPLE 4
```
Get all modules with outdated references
```

Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential \<username\> -Filter {$_.StatusMessages.Id -eq 6}

### EXAMPLE 5
```
Get all modules not published since the last version update
```

Get-OSPlatformModules -ServiceCenter "8.8.8.8" -Credential \<username\> -Filter {$_.StatusMessages.Id -eq 13}

### EXAMPLE 6
```
Get modules all the modules from my factory
```

@('dev','test','qa','prd') | Get-OSPlatformModules -ServiceCenter -Credential \<username\>

### EXAMPLE 7
```
Get all outdated modules from my factory
```

@('dev','test','qa','prd') | Get-OSPlatformModules -ServiceCenter -Credential \<username\> -Filter {$_.StatusMessages.Id -eq 6}

## PARAMETERS

### -ServiceCenter
{{ Fill ServiceCenter Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Host, Environment, ServiceCenterHost

Required: False
Position: Named
Default value: 127.0.0.1
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Credential
Username or PSCredential object with credentials for Service Center.
If not specified defaults to admin/admin

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $OSSCCred
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Filter script to filter returned modules

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
If spedified returns the list of modules grouped by environment.
Also returns the ServiceCenter and the Credentials parameters.
Useful for the Publish-OSPlatformModules cmdLet

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### OutSystems.PlatformServices.CS_Module
### OutSystems.PlatformServices.ModuleList
## NOTES
You can run this cmdlet on any machine with HTTP access to Service Center.

## RELATED LINKS
