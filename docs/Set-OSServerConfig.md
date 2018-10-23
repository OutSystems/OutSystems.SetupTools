---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version: http://go.microsoft.com/fwlink/?LinkID=217034
schema: 2.0.0
---

# Set-OSServerConfig

## SYNOPSIS
Configure or apply the current configuration to the OutSystems server

## SYNTAX

### ChangeSettings (Default)
```
Set-OSServerConfig -SettingSection <String> -Setting <String> -Value <String> [<CommonParameters>]
```

### ApplyConfig
```
Set-OSServerConfig [-PlatformDBCredential <PSCredential>] [-SessionDBCredential <PSCredential>] [-Apply]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdLet has two modes.
Configure or Apply:

In configure mode you can change configuration tool settings using the -SettingSection, -Setting, -Value and -Encrypted parameter
The cmdLet will not check if SettingSection and Setting are valid OutSystems parameters.
You need to know what you are doing here

The Apply mode will run the OutSystems configuration tool with the configured settings
For that you need to specify the -Apply parameter
You can also specify the admin credentials for the platform, session and logging (only in OS11) databases
In OS11 you may also add the -ConfigureCacheInvalidationService to configure RabbitMQ

## EXAMPLES

### EXAMPLE 1
```
Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'ServiceUsername' -Value 'admin'
```

### EXAMPLE 2
```
Set-OSServerConfig -SettingSection 'CacheInvalidationConfiguration' -Setting 'ServicePassword' -Value 'mysecretpass'
```

### EXAMPLE 3
```
Set-OSServerConfig -Apply -PlatformDBCredential sa
```

### EXAMPLE 4
```
Set-OSServerConfig -Apply -PlatformDBCredential sa -SessionDBCredential sa -LogDBCredential sa -ConfigureCacheInvalidationService
```

## PARAMETERS

### -SettingSection
The setting section.
When this is specified, the cmdLet will run in configure mode

```yaml
Type: String
Parameter Sets: ChangeSettings
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Setting
The setting

```yaml
Type: String
Parameter Sets: ChangeSettings
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The value

```yaml
Type: String
Parameter Sets: ChangeSettings
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PlatformDBCredential
PSCredential object with the admin credentials to the platform database

```yaml
Type: PSCredential
Parameter Sets: ApplyConfig
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionDBCredential
PSCredential object with the admin credentials to the session database

```yaml
Type: PSCredential
Parameter Sets: ApplyConfig
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Apply
This will switch the cmdLet to apply mode

```yaml
Type: SwitchParameter
Parameter Sets: ApplyConfig
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
Check the server.hsconf file on the platform server installation folder to know which section settings and settings are available

If you dont specify database credentials, the configuration tool will try the current user credentials and then admin user specified on the configuration

## RELATED LINKS
