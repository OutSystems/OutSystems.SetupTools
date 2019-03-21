---
external help file: OutSystems.SetupTools-help.xml
Module Name: Outsystems.SetupTools
online version:
schema: 2.0.0
---

# Set-OSServerPerformanceTunning

## SYNOPSIS
Configures Windows and IIS with the recommended performance settings for OutSystems.

## SYNTAX

```
Set-OSServerPerformanceTunning [[-IISNetCompilationPath] <String>] [[-IISHttpCompressionPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This will configure Windows and IIS with the recommended performance settings for the OutSystems platform.

## EXAMPLES

### EXAMPLE 1
```
Set-OSServerPerformanceTunning
```

### EXAMPLE 2
```
Set-OSServerPerformanceTunning -IISNetCompilationPath d:\IISTemp\Compilation -IISHttpCompressionPath d:\IISTemp\Compression
```

## PARAMETERS

### -IISNetCompilationPath
Sets the IIS compilation folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IISHttpCompressionPath
Sets the IIS compression folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
