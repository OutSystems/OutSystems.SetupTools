# OutSystems On-Prem installation

This is a set of scripts to install Outsystems On-Prem.

The scripts will do all the hard part of installing all the pre-requisites, the platform and the post configuration and will let you configure the platform using the Configuration Tool.

For a complete unattend setup use the DeployOnAzure examples.

## Online machines

Use this scripts if your machine is connected to Internet.

### Download

* [Deployment Controller](https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem/DC-OnPrem.ps1) ( Right-Click and "Save Link As" )

* [Frontend](https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem/FE-OnPrem.ps1) ( Right-Click and "Save Link As" )

* [Lifetime](https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem/LT-OnPrem.ps1) ( Right-Click and "Save Link As" )

### Instructions

1. Download the script

2. Open a new powershell window and go to the place where you downloaded the script

3. Since the script was downloaded from Internet you need to allow it to run. Type on powershell:
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
    ```

4. Run the script ( .\\<scriptName.ps1> [parameters] )
    * The scripts takes two parameters. -MajorVersion and -InstallDir
    * "MajorVersion" is the major version you want to install. This can be "10.0" or "11.0". This parameter is mandatory
    * "InstallDir" is the place where you want to install OutSystems. If you dont specify this parameter it will default to %ProgramFiles%\OutSystems
    * Example:
    ```powershell
    .\DC-OnPrem.ps1 -MajorVersion 11.0 -InstallDir E:\OutSystems
    ```

5. Wait until the Configuration Tool pops on the screen. This can take 5 to 10 minutes depending on the machine speed.

6. Configure the platform normally."Apply and Exit"
    * **IMPORTANT**: Say NO when the configuration tool ask you to install Service Center

7. Go back to the powershell and press ENTER to finish the setup.

## Offline machines

Under-construction
