---
external help file: OutSystems.SetupTools-help.xml
Module Name: OutSystems.SetupTools
online version:
schema: 2.0.0
---

# Set-OSServerPerformanceTunning2

## SYNOPSIS
Configures Windows and IIS with the recommended performance settings for OutSystems.

## SYNTAX

```
Set-OSServerPerformanceTunning2 [[-IISNetCompilationPath] <String>] [[-IISHttpCompressionPath] <String>]
 [[-AdvancedConfigurations] <Object>] [<CommonParameters>]
```

## DESCRIPTION
This will configure Windows and IIS with the recommended performance settings for the OutSystems platform.
An advanced configuration object can be used to control which sections are and are not done.
Also, some values (namely, .NET and IIS upload size limits) can be set that will used to fine tune the respective settings.

## EXAMPLES

### EXAMPLE 1
```
Set-OSServerPerformanceTunning
```

### EXAMPLE 2
```
Set-OSServerPerformanceTunning -IISNetCompilationPath d:\IISTemp\Compilation -IISHttpCompressionPath d:\IISTemp\Compression
```

### EXAMPLE 3
```
Set-OSServerPerformanceTunning -AdvancedConfigurations  @{ "Sections" = @{ "NETConfig" = @{ "ShouldBeSkipped" = $True } ; "IISConnectionsConfig" = @{ "ShouldBeSkipped" = $True } ; "ProcessSchedulingConfig" = @{ "ShouldBeSkipped" = $True } ; "IISUploadSizeLimitsConfig" = @{ "NewMaxAllowedContentLength" = 10000000 ; "ShouldBeSkipped" = $True } ; "AppPoolsConfig" = @{ "ShouldBeSkipped" = $True } } ; "SkipPlatformCheck" = $True ; "SkipMoveAppsToOSAppPools" = $True }
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

### -AdvancedConfigurations
Sets which of the sections should be completed, also allowing more specific configurations for some of these sections.

This parameter is represent by an object with the following structure type (semi-JSONfied with the expected types enclosed in \<\>):

{

    "SkipPlatformCheck" :  \<BOOL\>,
    "Sections" :
    {
        "ProcessSchedulingConfig" :
        {
            "ShouldBeSkipped" : \<BOOL\>
        },
        "NETConfig" :
        {
            "ShouldBeSkipped" :  \<BOOL\>,
            "NewMaxRequestLength" : \<INT\>
        },
        "IISUploadSizeLimitsConfig" :
        {
            "ShouldBeSkipped" : \<BOOL\>,
            "NewMaxAllowedContentLength" : \<INT\>
        },
        "IISConnectionsConfig" :
        {
            "ShouldBeSkipped" :  \<BOOL\>
        },
        "AppPoolsConfig" :
        {
            "ShouldBeSkipped" : \<BOOL\>,
            "SkipMoveAppsToOSAppPools" : \<BOOL\>
            "AppPoolsToForciblyCreateAndConfig" : \<STRING\[\]\>,
        }
    }
}

The aboved properties have the following semantic:

\> SkipPlatformCheck
    If true, proceeds even if the platform is not yet installed.


\> ProcessSchedulingConfig
    \> ShouldBeSkipped
    If true, skips the section where Windows processor scheduling priority is set to 'background services'.


\> NETConfig
    \> ShouldBeSkipped
    If true, skips the section where .NET upload size limits and execution timeout are configured.

    \> NewMaxRequestLength
    The value in KBytes that applied to the .NET Framework "MaxRequestLength" property.


\> IISUploadSizeLimitsConfig
    \> ShouldBeSkipped
    If true, skips the section where IIS upload size limits are configured.

    \> NewMaxAllowedContentLength
    The value in Bytes that applied to the .NET Framework "MaxRequestLength" property.


\> IISConnectionsConfig
    \> ShouldBeSkipped
    If true, skips the section where IIS is configured for unlimited connections.


\> AppPoolsConfig
    \> ShouldBeSkipped
    If true, skips the section where OutSystems apps are moved to the respective OutSystems app pool.

    \> SkipMoveAppsToOSAppPools
    If true, will not move OutSytems apps to the corresponding IIS app pools created by OutSystems (e.g.
'ServiceCenter' to 'ServiceCenterAppPool').

    \> AppPoolsToForciblyCreateAndConfig
    If this list is not empty and has valid app pool names, will force the creation and configuration of the app pools.
    Valid app pool names: "OutSystemsApplications", "ServiceCenterAppPool", "LifeTimeAppPool".

```yaml
Type: Object
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

## RELATED LINKS
