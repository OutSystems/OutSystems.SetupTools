---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Write-OSInstallLog

## SYNOPSIS
Writes a message on the log file and on the verbose stream.

## SYNTAX

```
Write-OSInstallLog [[-Name] <String>] [-Message] <String> [<CommonParameters>]
```

## DESCRIPTION
This will Write a message on the log file and on the verbose stream.

## EXAMPLES

### EXAMPLE 1
```
Write-OSInstallLog -Message 'My Message'
```

## PARAMETERS

### -Name
The name on the log.
Defaults to the function name if not specified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $($MyInvocation.Mycommand)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Message to write on the log

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

## NOTES

## RELATED LINKS
