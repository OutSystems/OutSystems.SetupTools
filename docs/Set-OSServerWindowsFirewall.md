---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version: http://go.microsoft.com/fwlink/?LinkID=217034
schema: 2.0.0
---

# Set-OSServerWindowsFirewall

## SYNOPSIS
Creates a windows firewall allow rule for the OutSystems services.

## SYNTAX

```
Set-OSServerWindowsFirewall [-IncludeRabbitMQ] [<CommonParameters>]
```

## DESCRIPTION
This will create a firewall rule named Outsystems and will opens the TCP Ports 12000, 12001, 12002, 12003, 12004 in all firewall profiles.

## EXAMPLES

### EXAMPLE 1
```
Set-OSServerWindowsFirewall -IncludeRabbitMQ
```

## PARAMETERS

### -IncludeRabbitMQ
If specified, it will open the TCP Port 5672 needed for RabbitMQ.

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

## RELATED LINKS
