# ABOUT
**EUQ** stands for *Extension Update Qlik Sense*, this script help to easy update an extension deleting the old one and importing selected,
with this powershell we can create a zip and import it.

This automate some repetitive and time-consuming mashup maintenance tasks from QMC such as "search, delete, generate zip and upload", everytime you make a change with this you don't need even to open the browser for update, so you can focus in developing new features.

# EXAMPLE
When you write `.\euq.ps1` on the cmd it will show a menu but you can also execute with parameters if you want.

``` PowerShell
.\euq.ps1 "server_domain" "domain\user" "extension_name"  "extension_path" "zip_path"
```

# NEEDs
 - 7-ZIP installed
 - A *valid* server certificate
 - Port 4242 *on Qlik Sense Server* open to public
 - Install Qlik-Cli
   - https://github.com/ahaydon/Qlik-Cli-Windows
        <details>
        <summary>Copy of that repo:</summary>  
        
        ``` PowerShell
        $PSVersionTable.PSVersion
        ```
        Ensure you can run script by changing the execution policy, you can change this for the machine by running PowerShell as Administrator and executing the command

        ``` PowerShell
        Set-ExecutionPolicy RemoteSigned
        ```
        If you do not have administrator rights you can change the policy for your user rather than the machine using

        ``` PowerShell
        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
        ```

        If you have PowerShell 5 or later you can install the module from NuGet using the following command.

        ``` PowerShell
        Get-PackageProvider -Name NuGet -ForceBootstrap
        Install-Module Qlik-Cli
        ```

        Otherwise, the module can be installed by downloading and extracting the files to C:\Program Files\WindowsPowerShell\Modules\Qlik-Cli, the module will then be loaded the next time you open a PowerShell console. You can also load the module for the current session using the Import-Module command and providing the name or path to the module.

        ``` PowerShell
        Import-Module Qlik-Cli
        Import-Module .\Qlik-Cli.psd1
        ```
        Once the module is loaded you can view a list of available commands by using the Get-Help PowerShell command.

        ``` PowerShell
        Get-Help Qlik
        ```

        </details>  