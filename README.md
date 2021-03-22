# ExchangeBuildNumber PowerShell Module

You can search build numbers of Exchange Server. Not only that, but you can also get the relevant KB numbers and blog posts.

```
PS C:\> Get-ExchangeBuildNumber "2019 CU9"


Product Name : Exchange 2019 CU9
Build Number : 15.2.858.5
Date         : 2021/03/16
KB           : KB4602570
Blog         : https://techcommunity.microsoft.com/t5/exchange-team-blog/released-march-2021-quarterly-exchange-updates/ba-p/2205283
```

## Installing ExchangeBuildNumber PowerShell Module

The module is published on the PowerShell Gallery.

```powershell
Install-Module ExchangeBuildNumber
```

## Updating ExchangeBuildNumber PowerShell Module

```powershell
Update-Module ExchangeBuildNumber
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