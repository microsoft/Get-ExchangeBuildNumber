# Get-ExchangeBuildNumber

You can search build numbers of Exchange Server.

## Usage

1. Download [Get-ExchangeBuildNumber.ps1](https://raw.githubusercontent.com/Microsoft/Get-ExchangeBuildNumber/master/Get-ExchangeBuildNumber.ps1) and save on your computer. Set the extention of the file to .ps1.
2. Start PowerShell and go to the folder where you saved the file.
3. Run the following command and load the Get-ExchangeBuildNumber Cmdlet.

  ~~~powershell
. D:\GitHub\Get-ExchangeBuildNumber\Get-ExchangeBuildNumber.ps1
  ~~~

4. If you want to know the build number of Exchange 2013 CU11, run the following command.

  ~~~powershell
Get-ExchangeBuildNumber -ProductName "Exchange 2013 CU11"
  ~~~

5. If you want to know the product name of 15.0.1156.6, run the following command.

  ~~~powershell
Get-ExchangeProductName 15.0.1156.6
  ~~~

6. If you want to update the definition file manually, run the following command.

  ~~~powershell
Update-ExchangeBuildNumberDefinition
  ~~~

## Problems running the script
By default, PowerShell restricts script execution to help protect against script based attacks.  It does this via the _execution policy_.  To validate your system's current policy setting use the `Get-ExecutionPolicy` cmdlet:

  ~~~powershell
Get-ExecutionPolicy
  ~~~

If you receive a result of _Restricted_ you'll need to either set a new policy (one of _AllSigned_, _RemoteSigned_ or _Unrestricted_ (*not recommended*)) or bypass the policy for this script.  _AllSigned_ will run any signed script whereas _RemoteSigned_ only requires a script to be signed it if comes from a remote system (downloaded from the Internet or via a file share).  _Unrestricted_ is not recommended as all scripts would be permitted to run, including those from malicious actors.

__Note:__ This script is not signed.

To change your execution policy (adjust the level to suit):

  ~~~powershell
Set-ExecutionPolicy RemoteSigned
  ~~~

Alternatively, start a `PowerShell` session (from the run prompt) in execution policy bypass mode, then run script as above:

~~~
powershell –ExecutionPolicy Bypass
~~~

---
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
