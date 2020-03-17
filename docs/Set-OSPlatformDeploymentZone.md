---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Set-OSPlatformDeploymentZone

## SYNOPSIS
Sets the OutSystems environment deployment zone

## SYNTAX

```
Set-OSPlatformDeploymentZone [[-DeploymentZone] <String>] [-ZoneAddress] <String> [[-EnableHTTPS] <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
This will return set an OutSystems environment deployment zone

## EXAMPLES

### EXAMPLE 1
```
Set-OSPlatformDeploymentZone -ZoneAddress 8.8.8.8
```

### EXAMPLE 2
```
Set-OSPlatformDeploymentZone -DeploymentZone 'myzone' -ZoneAddress 8.8.8.8 -EnableHTTPS:$true
```

## PARAMETERS

### -DeploymentZone
The name of the deployment zone.
Defaults to Global

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Global
Accept pipeline input: False
Accept wildcard characters: False
```

### -ZoneAddress
The new address for the target Deployment Zone

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

### -EnableHTTPS
Enable HTTPS for the target Deployment Zone.
If this parameter is not provided the setting will remain unchanged

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This cmdLet requires at least OutSystems 11

## RELATED LINKS
