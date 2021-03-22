# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
# https://github.com/microsoft/Get-ExchangeBuildNumber

function Get-ExchangeBuildNumber {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [string]$ProductName
    )

    Begin {
        function CreateLogString {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Get-ExchangeBuildNumber : " + $Message
        }

        function Setup {
            Write-Verbose (CreateLogString "Beginning processing.")

            $FileName = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber`\ExchangeBuildNumbers.csv"

            if (!(Test-Path $FileName)) {
                Write-Verbose (CreateLogString "Definition file was not found. Invoke Update-ExchangeBuildNumberDefinition to download definition file.")
                Update-ExchangeBuildNumberDefinition
            }

            Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1

            if ((Test-ExchangeBuildNumberDefinition $Builds) -eq $false) {
                Write-Verbose (CreateLogString "Definition file was updated. Reloading definition file.")
                Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1
            }

            Set-Variable -Name SetupDone -Value $true -Scope 1

            Write-Verbose (CreateLogString "Setup was completed.")
        }

        Setup
    }

    Process {
        if (-not $SetupDone) { Setup }
        
        $Found = $false

        foreach ($Build in $Builds) {
            if ($Build."Product Name" -like "*$ProductName*") {
                Write-Output $Build | Select-Object "Product Name", "Build Number", @{n = "Date"; e = { $Release = $_."Date"; $Release.ToString("yyyy/MM/dd") } }, "KB", "Blog"
                $found = $true
            }
        }

        if (-not $found) {
            Write-Warning "Not found."
        }
    }

    End
    { }
}

function Get-ExchangeProductName {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [System.Version]$BuildNumber
    )

    Begin {
        function CreateLogString {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Get-ExchangeProductName : " + $Message
        }

        function Setup {
            Write-Verbose (CreateLogString "Beginning processing.")

            $FileName = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber`\ExchangeBuildNumbers.csv"

            if (!(Test-Path $FileName)) {
                Write-Verbose (CreateLogString "Definition file was not found. Invoke Update-ExchangeBuildNumberDefinition to download definition file.")
                Update-ExchangeBuildNumberDefinition
            }

            Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1

            if ((Test-ExchangeBuildNumberDefinition $Builds) -eq $false) {
                Write-Verbose (CreateLogString "Definition file was updated. Reloading definition file.")
                Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1
            }

            Set-Variable -Name SetupDone -Value $true -Scope 1

            Write-Verbose (CreateLogString "Setup was completed.")
        }

        Setup
    }

    Process {
        if (-not $SetupDone) { Setup }

        $BuildString = $BuildNumber.Revision + $BuildNumber.Build * 1000 + $BuildNumber.Minor * 10000000 + $BuildNumber.Major * 1000000000 
        $Results = $null

        for ($i = 0; $i -le $Builds.Length; $i++) {
            if ($BuildString -lt $Builds[$i]."BuildNumberInt") {
                if ($i -eq 0) {
                    Write-Error ($BuildNumber.ToString() + " is too old.")
                    break
                }
                else {
                    $Results = @($Builds[$i - 1], $Builds[$i])
                    Write-Warning ($BuildNumber.ToString() + " is greater than " + $Results[0]."Product Name" + " and less than " + $Results[1]."Product Name")
                    
                    if (Test-SecurityOrInterimUpdate -BaseBuild $Builds[$i - 1]."Build Number" -BuildToBeCompared $BuildNumber) {
                        Write-Warning ("It seems that " + $BuildNumber.ToString() + " is " + $Builds[$i - 1]."Product Name" + ", and a security update (SU) or an interim update (IU) is installed.")
                    }

                    break
                }
            }
            elseif ($BuildString -eq $Builds[$i]."BuildNumberInt") {
                $Results = $Builds[$i]
                break
            }
        }

        if ($null -eq $Results) {
            if (Test-SecurityOrInterimUpdate -BaseBuild $Builds[-1]."Build Number" -BuildToBeCompared $BuildNumber) {
                $Results = $Builds[-1]
                Write-Warning ("It seems that " + $BuildNumber.ToString() + " is " + $Builds[-1]."Product Name" + ", and a security update (SU) or an interim update (IU) is installed.")
            }
            else {
                Write-Warning "Not found."
                return
            }
        }
        
        Write-Output $Results | Select-Object "Product Name", "Build Number", @{n = "Date"; e = { $Release = $_."Date"; $Release.ToString("yyyy/MM/dd") } }, "KB", "Blog"
    }

    End { }
}

function Test-SecurityOrInterimUpdate {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True)]
        [version]$BaseBuild,

        [Parameter(Mandatory = $True)]
        [version]$BuildToBeCompared
    )

    return (
        ($BaseBuild.Major -eq $BuildToBeCompared.Major) -and 
        ($BaseBuild.Minor -eq $BuildToBeCompared.Minor) -and 
        ($BaseBuild.Build -eq $BuildToBeCompared.Build) -and 
        ($BaseBuild.Revision -lt $BuildToBeCompared.Revision)
    )
}

function Import-ExchangeBuildNumberDefinition {
    [CmdletBinding()]
    param
    (
        [string]$FileName = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber`\ExchangeBuildNumbers.csv"
    )

    Begin {
        function CreateLogString {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Import-ExchangeBuildNumberDefinition : " + $Message
        }
    }

    Process {
        Write-Verbose (CreateLogString ("Loading the definition file from " + $FileName + "."))
        return Import-Csv $FileName | Select-Object "Product Name", @{n = "Build Number"; e = { [System.Version]$_."Build Number" } }, @{n = "BuildNumberInt"; e = { $Version = [System.Version]$_."Build Number"; $Version.Revision + $Version.Build * 1000 + $Version.Minor * 10000000 + $Version.Major * 1000000000 } }, "KB", @{n = "Date"; e = { Get-Date $_."Date" } }, "Blog"
    }

    End
    { }
}

function Update-ExchangeBuildNumberDefinition {
    [CmdletBinding()]
    param
    ()

    Begin {
        function CreateLogString {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Update-ExchangeBuildNumberDefinition : " + $Message
        }
    }

    Process {
        $Dest = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber"
	
        if (!(Test-Path $Dest)) {
            Write-Verbose (CreateLogString ("Definition folder was not found. Creating '" + $Dest + "'"))
            New-Item $Dest -Type directory > $Null
        }
	
        $FileName = $Dest + "`\ExchangeBuildNumbers.csv"
        Write-Verbose (CreateLogString "Downloading the definition file.")
        Invoke-WebRequest -Uri "https://exchangebuildnumbersg.blob.core.windows.net/exchangebuildnumbercontainer/ExchangeBuildNumbers.csv" -OutFile $FileName
    }

    End
    { }
}

# Return $false if the definition file was updatedd.
function Test-ExchangeBuildNumberDefinition {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True)][Object[]]$BuildNumberDifinition
    )

    Begin {
        function CreateLogString {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Test-ExchangeBuildNumberDefinition : " + $Message
        }
    }

    Process {
        $LastReleaseDate = Get-Date $BuildNumberDifinition[$BuildNumberDifinition.Count - 1]."Date"
        Write-Verbose (CreateLogString ("Last release date in the definition file is " + $LastReleaseDate.ToString("yyyy/MM/dd") + "."))
        $Today = Get-Date

        $DaysFromLastRelease = $Today - $LastReleaseDate
        Write-Verbose (CreateLogString ("Last release was " + $DaysFromLastRelease.Days + " days ago."))

        if ($DaysFromLastRelease.Days -ge 100) {
            
            $Caption = "Confirm"
            $Message = "Current definition file is too old. Do you want to update?"

            $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            if ($Host.UI.PromptForChoice($Caption, $Message, $Choices, 0) -eq 0) {
                Write-Verbose (CreateLogString ("User decided to update the definition file."))
                Update-ExchangeBuildNumberDefinition

                return $false
            }
            else {
                Write-Verbose (CreateLogString ("User decided not to update the definition file."))
                return $true
            }
        }
    }

    End
    { }
}