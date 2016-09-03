function Get-ExchangeBuildNumber
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
        [string]$ProductName
    )

    Begin
    {
        function CreateLogString
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Get-ExchangeBuildNumber : " + $Message
        }

        function Setup
        {
            Write-Verbose (CreateLogString "Beginning processing.")

            $FileName = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber`\ExchangeBuildNumbers.csv"

	        if(!(Test-Path $FileName))
	        {
                Write-Verbose (CreateLogString "Definition file was not found. Invoke Update-ExchangeBuildNumberDefinition to download definition file.")
		        Update-ExchangeBuildNumberDefinition
	        }

            Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1

            if ((Test-ExchangeBuildNumberDefinition $Builds) -eq $false)
            {
                Write-Verbose (CreateLogString "Definition file was updated. Reloading definition file.")
                Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1
            }

            Set-Variable -Name SetupDone -Value $true -Scope 1

            Write-Verbose (CreateLogString "Setup was completed.")
        }

        Setup
    }

    Process
    {
        if (-not $SetupDone) { Setup }
        
        $Found = $false

	    foreach($Build in $Builds)
	    {
		    if($Build."Product Name" -like "*$ProductName*")
		    {
                Write-Output $Build | select "Product Name", "Build Number", @{n="Date"; e={$Release = $_."Date"; $Release.ToString("yyyy/MM/dd")}}, "KB"
                $found = $true
		    }
	    }

        if (-not $found)
        {
            Write-Warning "Not found."
        }
    }

    End
    {}
}

function Get-ExchangeProductName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
        [System.Version]$BuidNumber
    )

    Begin
    {
        function CreateLogString
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Get-ExchangeProductName : " + $Message
        }

        function Setup
        {
            Write-Verbose (CreateLogString "Beginning processing.")

            $FileName = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber`\ExchangeBuildNumbers.csv"

	        if(!(Test-Path $FileName))
	        {
                Write-Verbose (CreateLogString "Definition file was not found. Invoke Update-ExchangeBuildNumberDefinition to download definition file.")
		        Update-ExchangeBuildNumberDefinition
	        }

            Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1

            if ((Test-ExchangeBuildNumberDefinition $Builds) -eq $false)
            {
                Write-Verbose (CreateLogString "Definition file was updated. Reloading definition file.")
                Set-Variable -Name Builds -Value:(Import-ExchangeBuildNumberDefinition -FileName $FileName) -Scope 1
            }

            Set-Variable -Name SetupDone -Value $true -Scope 1

            Write-Verbose (CreateLogString "Setup was completed.")
        }

        Setup
    }

    Process
    {
        if (-not $SetupDone) { Setup }

        $BuildString = $BuidNumber.Revision + $BuidNumber.Build * 1000 + $BuidNumber.Minor * 10000000 + $BuidNumber.Major * 1000000000 
        $Results = $null

	    for($i = 0; $i -le $Builds.Length; $i++)
	    {
		    if($BuildString -lt $Builds[$i]."BuildNumberInt")
		    {
                if ($i -eq 0)
                {
                    Write-Error ($BuidNumber.ToString() + " is too old.")
                    break
                }
                else
                {
			        $Results = @($Builds[$i - 1], $Builds[$i])
                    Write-Warning ($BuidNumber.ToString() + " is greater than " + $Results[0]."Product Name" + " and less than " + $Results[1]."Product Name")
                    break
                }
            }
            elseif($BuildString -eq $Builds[$i]."BuildNumberInt")
            {
                $Results = $Builds[$i]
                break
            }
	    }

        if ($Results -eq $null)
        {
            Write-Warning "Not found."
            return
        }
        else
        {
            Write-Output $Results | select "Product Name", "Build Number", @{n="Date"; e={$Release = $_."Date"; $Release.ToString("yyyy/MM/dd")}}, "KB"
        }
    }

    End {}
}

function Import-ExchangeBuildNumberDefinition
{
    [CmdletBinding()]
    param
    (
        [string]$FileName = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber`\ExchangeBuildNumbers.csv"
    )

    Begin
    {
        function CreateLogString
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Import-ExchangeBuildNumberDefinition : " + $Message
        }
    }

    Process
    {
        Write-Verbose (CreateLogString ("Loading the definition file from " + $FileName + "."))
        return Import-Csv $FileName | Select "Product Name", @{n="Build Number"; e={[System.Version]$_."Build Number"}}, @{n="BuildNumberInt";e={$Version = [System.Version]$_."Build Number"; $Version.Revision + $Version.Build * 1000 + $Version.Minor * 10000000 + $Version.Major * 1000000000}}, "KB", @{n="Date";e={Get-Date $_."Date"}}
    }

    End
    {}
}

function Update-ExchangeBuildNumberDefinition
{
    [CmdletBinding()]
    param
    ()

    Begin
    {
        function CreateLogString
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Update-ExchangeBuildNumberDefinition : " + $Message
        }
    }

    Process
    {
	    $Dest = [Environment]::GetFolderPath('MyDocuments') + "`\Get-ExchangeBuildNumber"
	
	    if(!(Test-Path $Dest))
	    {
            Write-Verbose (CreateLogString ("Definition folder was not found. Creating '" + $Dest + "'"))
		    New-Item $Dest -Type directory > $Null
	    }
	
	    $FileName = $Dest + "`\ExchangeBuildNumbers.csv"
        Write-Verbose (CreateLogString "Downloading the definition file.")
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Microsoft/Get-ExchangeBuildNumber/master/ExchangeBuildNumbers.csv" -OutFile $FileName
    }

    End
    {}
}

# Return $false if the definition file was updatedd.
function Test-ExchangeBuildNumberDefinition
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True)][Object[]]$BuildNumberDifinition
    )

    Begin
    {
        function CreateLogString
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
                [string]$Message
            )

            return (Get-Date).ToUniversalTime().ToString("[HH:mm:ss.fff") + " GMT] Test-ExchangeBuildNumberDefinition : " + $Message
        }
    }

    Process
    {
        $LastReleaseDate = Get-Date $BuildNumberDifinition[$BuildNumberDifinition.Count - 1]."Date"
        Write-Verbose (CreateLogString ("Last release date in the definition file is " + $LastReleaseDate.ToString("yyyy/MM/dd") +"."))
        $Today = Get-Date

        $DaysFromLastRelease = $Today - $LastReleaseDate
        Write-Verbose (CreateLogString ("Last release was " + $DaysFromLastRelease.Days +" days ago."))

        if ($DaysFromLastRelease.Days -ge 100)
        {
            
            $Caption  = "Confirm"
            $Message = "Current definition file is too old. Do you want to update?"

            $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            if ($Host.UI.PromptForChoice($Caption, $Message, $Choices, 0) -eq 0)
            {
                Write-Verbose (CreateLogString ("User decided to update the definition file."))
                Update-ExchangeBuildNumberDefinition

                return $false
            }
            else
            {
                Write-Verbose (CreateLogString ("User decided not to update the definition file."))
                return $true
            }
        }
    }

    End
    {}
}

