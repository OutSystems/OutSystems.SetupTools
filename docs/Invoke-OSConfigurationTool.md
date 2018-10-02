---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Invoke-OSConfigurationTool

## SYNOPSIS
Documentation to be done!

## SYNTAX

```
Invoke-OSConfigurationTool [[-Controller] <String>] [[-PrivateKey] <String>] [-OverwritePrivateKey]
 [[-DBProvider] <String>] [-DBSAUser] <String> [-DBSAPass] <String> [[-DBAdminUser] <String>]
 [-DBAdminPass] <String> [[-DBRuntimeUser] <String>] [-DBRuntimePass] <String> [[-DBSessionUser] <String>]
 [-DBSessionPass] <String> [<CommonParameters>]
```

## DESCRIPTION
Documentation to be done!

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Controller
{{Fill Controller Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 127.0.0.1
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrivateKey
{{Fill PrivateKey Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverwritePrivateKey
{{Fill OverwritePrivateKey Description}}

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

### -DBProvider
{{Fill DBProvider Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: SQL
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBSAUser
{{Fill DBSAUser Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBSAPass
{{Fill DBSAPass Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBAdminUser
{{Fill DBAdminUser Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: OSADMIN
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBAdminPass
{{Fill DBAdminPass Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBRuntimeUser
{{Fill DBRuntimeUser Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: OSRUNTIME
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBRuntimePass
{{Fill DBRuntimePass Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBSessionUser
{{Fill DBSessionUser Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: OSSTATE
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBSessionPass
{{Fill DBSessionPass Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Outsystems.SetupTools.InstallResult
## NOTES

## RELATED LINKS
