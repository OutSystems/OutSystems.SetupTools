---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSServerConfig

## SYNOPSIS
Returns the OutSystems server configuration

## SYNTAX

```
Get-OSServerConfig [-SettingSection] <String> [-Setting] <String> [<CommonParameters>]
```

## DESCRIPTION
This will return the OutSystems server current configuration
Encrypted settings are returned un-encrypted

## EXAMPLES

### EXAMPLE 1
```
Get-OSServerConfig -SettingSection 'PlatformDatabaseConfiguration' -Setting 'AdminUser'
```

## PARAMETERS

### -SettingSection
{{ Fill SettingSection Description }}

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

### -Setting
{{ Fill Setting Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Check the server.hsconf file on the platform server installation folder to know which section settings and settings are available

## RELATED LINKS
