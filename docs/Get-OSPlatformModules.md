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

### UserAndPass (Default)
```
Get-OSPlatformModules [-ServiceCenterHost <String>] [-ServiceCenterUser <String>] [-ServiceCenterPass <String>]
 [<CommonParameters>]
```

### PSCred
```
Get-OSPlatformModules [-ServiceCenterHost <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
This will return the list of modules (espaces and extensions) installed on an Outsystems environment.
The function can be used to query a remote Outsystems environment for the list of modules installed using the ServiceCenterHost parameter.
If not specified, the function will query the local machine.

## EXAMPLES

### EXAMPLE 1
```
$Credential = Get-Credential
```

Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -Credential $Credential

$password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -Credential $Credential

Unsecure way:
Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -ServiceCenterUser "admin" -ServiceCenterPass "mypass"

## PARAMETERS

### -ServiceCenterHost
Service Center hostname or IP.
If not specified, defaults to localhost.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Host

Required: False
Position: Named
Default value: 127.0.0.1
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceCenterUser
Service Center username.
If not specified, defaults to admin.

```yaml
Type: String
Parameter Sets: UserAndPass
Aliases: User

Required: False
Position: Named
Default value: $OSSCUser
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceCenterPass
Service Center password.
If not specified, defaults to admin.

```yaml
Type: String
Parameter Sets: UserAndPass
Aliases: Pass, Password

Required: False
Position: Named
Default value: $OSSCPass
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Username or PSCredential object.
When you submit the command, you will be prompted for a password.

```yaml
Type: PSCredential
Parameter Sets: PSCred
Aliases:

Required: False
Position: Named
Default value: None
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
Supports both local and remote systems.

## RELATED LINKS
