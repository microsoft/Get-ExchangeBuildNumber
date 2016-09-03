# Get-ExchangeBuildNumber

You can search build numbers of Exchange Server.

## Usage

1. Download [Get-ExchangeBuildNumber.ps1](.\Get-ExchangeBuildNumber.ps1) and save on your computer.
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
