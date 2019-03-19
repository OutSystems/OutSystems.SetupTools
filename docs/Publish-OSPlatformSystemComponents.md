---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Publish-OSPlatformSystemComponents

## SYNOPSIS
Install or update Outsystems System Components.

## SYNTAX

### PSCred (Default)
```
Publish-OSPlatformSystemComponents [-Force] [-Credential <PSCredential>] [<CommonParameters>]
```

### UserAndPass
```
Publish-OSPlatformSystemComponents [-Force] [-ServiceCenterUser <String>] [-ServiceCenterPass <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This will install or update the System Components.
You need to specify a user and a password to connect to Service Center.
if you dont specify, the default admin will be used.
It will skip the installation if already installed with the right version.
Service Center needs to be installed using the Install-OSPlatformServiceCenter function.

## EXAMPLES

### EXAMPLE 1
```
Using PSCredentials
```

$cred = Get-Credential
Publish-OSPlatformSystemComponents -Credential $cred

### EXAMPLE 2
```
$cred = New-Object System.Management.Automation.PSCredential ("admin", $(ConvertTo-SecureString "admin" -AsPlainText -Force))
```

Publish-OSPlatformSystemComponents -Credential $cred

### EXAMPLE 3
```
Publish-OSPlatformSystemComponents -Force -ServiceCenterUser "admin" -ServiceCenterPass "admin"
```

## PARAMETERS

### -Force
Forces the reinstallation if already installed.

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

### -ServiceCenterUser
Service Center username.

```yaml
Type: String
Parameter Sets: UserAndPass
Aliases:

Required: False
Position: Named
Default value: $OSSCUser
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceCenterPass
Service Center password.

```yaml
Type: String
Parameter Sets: UserAndPass
Aliases:

Required: False
Position: Named
Default value: $OSSCPass
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
PSCredential object.

```yaml
Type: PSCredential
Parameter Sets: PSCred
Aliases:

Required: False
Position: Named
Default value: $OSSCCred
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
The parameters ServiceCenterUser and ServiceCenterPass will be removed in the next major version.
Publish-OSPlatformSystemComponents -Force -ServiceCenterUser "admin" -ServiceCenterPass "admin"

The recommended way to pass credentials in PowerShell is to use the PSCredential object.

## RELATED LINKS
