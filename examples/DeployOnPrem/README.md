# OutSystems On-Prem installation

This is a set of scripts to install OutSystems On-Prem using this module in a semi-unattend way.

The scripts will do all the hard work of installing the pre-requisites, the platform and post-configuration, and will let you configure the platform using the OutSystems configuration tool.

In case you need a fully unattended setup, check [this](https://github.com/OutSystems/OutSystems.SetupTools/tree/dev/examples/FullUnattended) example script used on our Azure templates.

## Online machines

Use this scripts if your machine is connected to Internet.

### Download

* [Deployment Controller](https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem/OnPrem-Online-DC.ps1) ( Right-Click and "Save Link As" )

* [Frontend](https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem/OnPrem-Online-FE.ps1) ( Right-Click and "Save Link As" )

* [Lifetime](https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem/OnPrem-Online-LT.ps1) ( Right-Click and "Save Link As" )

### Instructions

1. Download the script.

2. Open a new powershell window as administrator, and go to the place where you downloaded the script.

3. Since the script was downloaded from Internet you need to allow it to run by running:
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
    ```

4. Run the script ( .\\<scriptName.ps1> [parameters] )
    * The scripts takes two parameters. *-MajorVersion* and *-InstallDir*.
    * *MajorVersion* is the major OutSystems version you want to install. This must be "11" and it is a mandatory parameter.
    * *InstallDir* is the place where you want to install OutSystems. If not specified, the installation will default to %ProgramFiles%\OutSystems.
    * Example:
    ```powershell
    .\OnPrem-Online-DC.ps1 -MajorVersion 11.0 -InstallDir E:\OutSystems
    ```

5. Wait until the Configuration Tool pops on the screen. This can take 5 to 10 minutes depending on the machine speed.

6. Configure the platform normally using the Configuration Tool. When finish, click "Apply and Exit".
    * **IMPORTANT**: Say NO when the configuration tool ask you to install Service Center

7. Go back to the powershell window and press any key to finish the setup.

## Offline machines

Use this section if the machine you want to install OutSystems has no direct internet connection or is completly offline.

### Offline bundle

The way to install OutSystems in offline machines is to use an offline bundle containning all the necessary files to perform the installation.

To create the bundle:

1. Download [this](https://raw.githubusercontent.com/OutSystems/OutSystems.SetupTools/dev/examples/DeployOnPrem/CreateOfflineBundle.ps1) script ( Right-Click and "Save Link As" ).

2. Open a new powershell window as administrator, and go to the place where you downloaded the script.

3. Since the script was downloaded from Internet you need to allow it to run by running:
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
    ```

4. Run the script ( .\\CreateOfflineBundle.ps1> [parameters] ).
    * The scripts takes one parameters. *-MajorVersion*.
    * *MajorVersion* is the major OutSystems version that will be downloaded to the bundle. This must be "11" and it is a mandatory parameter.

5. When the script finish you will have a file named *OfflineBundle.zip* in the same path where you ran the script with everything inside needed to install OutSystems.

6. Copy the file to the offline machine and unzip.

7. Inside you have three files like the *Online* installation. Those scripts do not require parameters. You have an optional parameter *-InstallDir* to specify where you want to install OutSystems.
    * Example:
    ```powershell
    .\OnPrem-Offline-DC.ps1 -InstallDir E:\OutSystems
    ```
