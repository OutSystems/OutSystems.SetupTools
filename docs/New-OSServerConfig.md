---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version: http://go.microsoft.com/fwlink/?LinkID=217034
schema: 2.0.0
---

# New-OSServerConfig

## SYNOPSIS
Generates an empty OutSystems configuration file

## SYNTAX

```
New-OSServerConfig [-DatabaseProvider] <String> [[-PrivateKey] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
This will generate an empty OutSystems configuration file.
You can specify the envrionment private key using the -PrivateKey parameter
The cmdlet will not overwrite an existing configuration and/or private key.
If you wish to overwrite you need to specify the -Force switch

## EXAMPLES

### EXAMPLE 1
```
New-OSServerConfig -DatabaseProvider 'SQL'
```

### EXAMPLE 2
```
New-OSServerConfig -DatabaseProvider 'Oracle' -PrivateKey '42bGTaGWPkWmbmGLDbkQwA==' -Force
```

### EXAMPLE 3
```
New-OSPlatformPrivateKey | New-OSServerConfig -DatabaseProvider 'Oracle' -Force
```

## PARAMETERS

### -DatabaseProvider
Configuration will be generated for this database provider.
Available database provider are 'SQL' and 'Oracle'

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

### -PrivateKey
Used to specify the environment private key.
If you dont specified this, a random one will be generated

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
Allows cmdlet to override an existing configuration

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Use the Force switch with caution.
Overwritting an existing configuration may cause your environment to become inaccessible

## RELATED LINKS
