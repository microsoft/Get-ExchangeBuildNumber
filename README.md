# ExchangeBuildNumber PowerShell Module

You can search build numbers of Exchange Server.

## Installing ExchangeBuildNumber PowerShell Module

The module is published on the PowerShell Gallery.

```powershell
Install-Module ExchangeBuildNumber
```

## Example

If you want to know the build number of Exchange 2013 CU11, run the following command.

```powershell
Get-ExchangeBuildNumber -ProductName "Exchange 2013 CU11"
```

If you want to know the product name of 15.0.1156.6, run the following command.

```powershell
Get-ExchangeProductName 15.0.1156.6
```

If you want to update the definition file manually, run the following command.

```powershell
Update-ExchangeBuildNumberDefinition
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.