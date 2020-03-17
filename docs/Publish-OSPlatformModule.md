---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Publish-OSPlatformModule

## SYNOPSIS
Creates and publish an OutSystems solution with all modules that are outdated.

## SYNTAX

```
Publish-OSPlatformModule [[-ServiceCenter] <String>] [-Modules] <Object> [[-Credential] <PSCredential>] [-Wait]
 [-StopOnWarning] [[-StagingName] <String>] [<CommonParameters>]
```

## DESCRIPTION
This will create and publish an OutSystems solution with all modules that are outdated.

## EXAMPLES

### EXAMPLE 1
```
$Credential = Get-Credential
```

Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -Credential $Credential

### EXAMPLE 2
```
$password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
```

$Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
Get-OSPlatformModules -ServiceCenterHost "8.8.8.8" -Credential $Credential

## PARAMETERS

### -ServiceCenter
{{ Fill ServiceCenter Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Host, Environment, ServiceCenterHost

Required: False
Position: 1
Default value: 127.0.0.1
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Modules
{{ Fill Modules Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Credential
Username or PSCredential object with credentials for Service Center.
If not specified defaults to admin/admin

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $OSSCCred
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Wait
{{ Fill Wait Description }}

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

### -StopOnWarning
{{ Fill StopOnWarning Description }}

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

### -StagingName
{{ Fill StagingName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: OutSystems_SetupTools_Staging
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
You can run this cmdlet on any machine with HTTP access to Service Center.

## RELATED LINKS
