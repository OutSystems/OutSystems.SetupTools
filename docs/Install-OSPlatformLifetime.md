---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Install-OSPlatformLifetime

## SYNOPSIS
Install or update Outsystems Lifetime.

## SYNTAX

```
Install-OSPlatformLifetime [[-SystemCenterUser] <String>] [[-SystemCenterPass] <String>] [<CommonParameters>]
```

## DESCRIPTION
This will install or update Lifetime.
You need to specify a user and a password to connect to Service Center.
If you dont specify, the default admin will be used.
It will skip the installation if already installed with the right version.
Service Center needs to be installed using the Install-OSPlatformServiceCenter function.
Outsystems system components needs to be installed using the Install-OSPlatformSystemComponents function.

## EXAMPLES

### EXAMPLE 1
```
Install-OSPlatformLifetime -Force -SystemCenterUser "admin" -SystemCenterPass "mypass"
```

## PARAMETERS

### -SystemCenterUser
System Center username.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $OSSCUser
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemCenterPass
System Center password.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $OSSCPass
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS