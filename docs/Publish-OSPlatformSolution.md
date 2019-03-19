---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Publish-OSPlatformSolution

## SYNOPSIS
Deploys a solution pack

## SYNTAX

```
Publish-OSPlatformSolution [[-ServiceCenter] <String>] [[-Solution] <String>] [[-Credential] <PSCredential>]
 [-Wait] [-StopOnWarnings] [<CommonParameters>]
```

## DESCRIPTION
This will deploy a solution pack to an OutSystems environment
The cmdlet checks for compilation errors and will stop the deployment on any if the Wait switch is specified

## EXAMPLES

### EXAMPLE 1
```
$Credential = Get-Credential
```

Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential

### EXAMPLE 2
```
$password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
```

$Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential -Wait

### EXAMPLE 3
```
$Credential = Get-Credential
```

Publish-OSPlatformSolution -ServiceCenterHost "8.8.8.8" -Solution 'c:\solution.osp' -Credential $Credential -StopOnWarnings

## PARAMETERS

### -ServiceCenter
Service Center hostname or IP.
If not specified, defaults to localhost.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Host, Environment, ServiceCenterHost

Required: False
Position: 1
Default value: 127.0.0.1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Solution
Solution file.
This can be an OSP or an OAP file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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
Position: 3
Default value: $OSSCCred
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
Will waits for the deployment to finish and reports back the deployment result

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

### -StopOnWarnings
Treat warnings as errors.
Deployment will stop on compilation warnings and return success false

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

### Outsystems.SetupTools.PublishResult
## NOTES
You can run this cmdlet on any machine with HTTP access to Service Center.

The cmdlet will return an object with an ExitCode property that will match one of the following values:
-1 = Error while trying to publish the solution
0  = Success
1  = Solution published with warnings
2  = Solution published with errors

This cmdlet does not check the integrity of the solution pack before starting.
Trusts on the Service Center to make all the checks.

## RELATED LINKS
