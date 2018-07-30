---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSPlatformModules

## SYNOPSIS
Returns the list of modules installed on an Outsystems environment.

## SYNTAX

```
Get-OSPlatformModules [[-ServiceCenterHost] <String>] [[-ServiceCenterUser] <String>]
 [[-ServiceCenterPass] <String>] [<CommonParameters>]
```

## DESCRIPTION
This will return the list of modules (espaces and extensions) installed on an Outsystems environment.
The function can be used to query a remote Outsystems environment for the list of modules installed using the ServiceCenterHost parameter.
If not specified, the function will query the local machine.

## EXAMPLES

### EXAMPLE 1
```
Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -ServiceCenterUser "admin" -ServiceenterPass "mypass"
```

## PARAMETERS

### -ServiceCenterHost
Service Center hostname or IP.
If not specified, defaults to localhost.

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

### -ServiceCenterUser
Service Center username.
If not specified, defaults to admin

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $OSSCUser
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceCenterPass
Service Center password.
If not specified, defaults to admin

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $OSSCPass
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

## NOTES

## RELATED LINKS
