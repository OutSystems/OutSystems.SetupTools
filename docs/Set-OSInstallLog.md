---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Set-OSInstallLog

## SYNOPSIS
Sets the module log file location.

## SYNTAX

```
Set-OSInstallLog [-Path] <String> [-File] <String> [-LogDebug] [<CommonParameters>]
```

## DESCRIPTION
This will set the module log location.
By default the module will log to %temp%\OutSystems.SetupTools\InstallLog-\<date\>.log

The log will contain the PowerShell verbose stream.
If you set the -LogDebug switch it will also contain the debug stream.

## EXAMPLES

### EXAMPLE 1
```
Set-OSInstallLog -Path $ENV:Windir\temp -File Install.log -LogDebug
```

## PARAMETERS

### -Path
The log file path.
The cmdlet will try to create the path if not exists.

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

### -File
The log filename.

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

### -LogDebug
Writes on the log the debug stream

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

## NOTES

## RELATED LINKS
