---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Publish-OSPlatformSolutionPack

## SYNOPSIS
Deploys a solution pack

## SYNTAX

### PSCred (Default)
```
Publish-OSPlatformSolutionPack [-Solution <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

### UserAndPass
```
Publish-OSPlatformSolutionPack [-Solution <String>] [-ServiceCenterUser <String>] [-ServiceCenterPass <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This will deploy a solution pack to an OutSystems environment.
It will not stop on any error.
It proceeds till the end and outputs all errors found during the deployment.

## EXAMPLES

### EXAMPLE 1
```
$Credential = Get-Credential
```

Publish-OSPlatformSolutionPack -Solution 'c:\solution.osp' -Credential $Credential

### EXAMPLE 2
```
$password = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
```

$Credential = New-Object System.Management.Automation.PSCredential ("username", $password)
Publish-OSPlatformSolutionPack -Solution 'c:\solution.osp' -Credential $Credential

## PARAMETERS

### -Solution
Solution path.
This can be an OSP or an OAP file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceCenterUser
{{Fill ServiceCenterUser Description}}

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
{{Fill ServiceCenterPass Description}}

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
Username or PSCredential object with credentials for Service Center.
If not specified defaults to admin/admin

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

### Outsystems.SetupTools.PublishResult
## NOTES
This script has to be executed locally on the server in which you wish to publish to.
This environment needs to have the osptool present

The cmdlet will return an object with an ExitCode property that will match one of the following values:
-1 = Error while trying to publish the solution
0  = Success

This cmdlet does not check the integrity of the solution pack before starting.
Trusts on the Service Center to make all the checks.

## RELATED LINKS
