---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Get-OSPlatformApplications

## SYNOPSIS
Returns the list of applications installed on an Outsystems environment.

## SYNTAX

```
Get-OSPlatformApplications [-ServiceCenter <String>] [-Credential <PSCredential>] [-Filter <ScriptBlock>]
 [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
This will return the list of applications installed on an OutSystems environment.
The function can be used to query a remote Outsystems environment for the list of applications installed using the ServiceCenterHost parameter.
If not specified, the function will query the local machine.

## EXAMPLES

### EXAMPLE 1
```
$Credential = Get-Credential
```

Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -Credential $Credential

### EXAMPLE 2
```
$password = ConvertTo-SecureString "superpass" -AsPlainText -Force
```

$Credential = New-Object System.Management.Automation.PSCredential ("superuser", $password)
Get-OSPlatformApplications -ServiceCenterHost "8.8.8.8" -Credential $Credential

### EXAMPLE 3
```
Get-OSPlatformModules -Credential $SCCreds -Filter {$_.StatusMessages.Id -eq 6}
```

## PARAMETERS

### -ServiceCenter
Service Center hostname or IP.
If not specified, defaults to localhost.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Host, Environment, ServiceCenterHost

Required: False
Position: Named
Default value: 127.0.0.1
Accept pipeline input: True (ByValue)
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
Position: Named
Default value: $OSSCCred
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Filter script block

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
{{Fill PassThru Description}}

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

### OutSystems.PlatformServices.CS_Application
### OutSystems.PlatformServices.Modules
## NOTES
You can run this cmdlet on any machine with HTTP access to Service Center.

## RELATED LINKS
