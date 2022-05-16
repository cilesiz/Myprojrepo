function Test-Module
{
    <#
    .Synopsis
        Runs ScriptCop and module test cases
    .Description
        Runs ScriptCop static analysis on a module, and then runs test cases included with the module.


        Tests can be declared in many ways.  
        
        
        ScriptCop will look for a file in each module: 
            ModuleName.ScriptCop.psd1        

        This file contains information about how the module will be tested.

        If this file is present, it will be used to declare test passes that can be run.  For example:


            @{
                'BuildVerificationTests' = '/Tests/BVT*.test.ps1', 'Getting_Started', 'Test-Function:1'
                'ScriptCop' = 'Test-CommandNamingConvention', 'Test-ForCommonParameterMistake', 'Test-ForPipelineParameter', 
                    'Test-ForParameterSetAmbiguity', 'Test-ParameterNamingConvention', 'Test-Help', 'Test-ProcessBlockImplemented'
            }

        The above file declares a test pass called BuildVerifiationTests, that runs any files in /Tests/BVT, the Getting_Started demo, and the first the function example of Test-Function.

        
        It also declares the static analysis of the module only uses the a subset of the available rules.
               
        
        If the ScriptCop.psd1 file is not present, several test passes will be automatically created:

        - A test pass will be generated from each demo file
        - A test pass will be generated from all examples in each function


        Unless the -TestPass parameter is provided, all test passes declared will be run.
        

    #>
    param(
    # The name of the module
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        if (-not (Get-Module "$_")) {
            $isavailable = Get-Module -ListAvailable "$_"
            if ($isavailable) {
                $isavailable | Import-Module -Global
            }
        }
    return $true
    })]    
    [string]
    $Name,

    # If provided, will run only the specific test passes.  
    # If this is provided, and it does not include the term "ScriptCop", static analysis will not be run.
    [string[]]
    $TestPass,

    # A list of individual test cases.  Each test case can be:
    # * The name of a demo file
    # * The relative path to a .test.ps1 within the module
    # * The name of a command, and the number of it's example
    [string[]]
    $TestCase,

    # A table of test data
    [Hashtable]

    # If set, will collect script coverage information while running test cases
    [Switch]
    $GetScriptCoverage
    )


    process {
        $realModule= Get-Module $Name


        $moduleRoot =$realModule | Split-Path

        $scriptTestPass = @{}
        if (Test-Path "$moduleRoot\$name.ScriptCop.psd1") {
            $scriptTestPass += & ([ScriptBlock]::Create("
            data {
                $([IO.File]::ReadAllText("$moduleRoot\$name.ScriptCop.psd1"))
            }
            "))



            if (-not $PSBoundParameters.TestPass) {
                $TestPass = $scriptTestPass.Keys | Sort-Object
            }
        }

        $rules = Get-ScriptCopRule | Select-Object -ExpandProperty Name
        if (-not $scriptTestPass.ScriptCop -or $scriptTestPass.ScriptCop -eq '*') {
            
            $scriptTestPass.ScriptCop = $rules
        }


        $demos = Get-ChildItem "$moduleRoot" -Recurse |
            Where-Object {
                $_.Name -like "*.demo.ps1" -or $_.Name -like "*.walkthru.help.txt"
            } |
            ForEach-Object {
                $_.Name -ireplace "\.demo\.ps1", "" -ireplace "\.walkthru\.help\.txt", ""
            }

        if (-not $scriptTestPass.Demo) {
            $scriptTestPass.Demo = $demos
        }
        
        
        $exampleDict = @{}
        Get-Command -Module $name -CommandType Function, Cmdlet  | 
            ForEach-Object {
                $cmd = $_
                $help = $_ | Get-Help

                $count = 1
                $exampleTestCases = if ($help.Examples.Example) {
                    $help.examples.example | 
                        ForEach-Object {
                            "$($cmd):$count"
                            $exampleDict["$($cmd):$count"] = $_.Code + ([environment]::NewLine) + $($_.Remarks | Out-String)
                            $count++
                        }

                    
                }


                if (-not $scriptTestPass.($cmd.name)) {
                    $scriptTestPass.($cmd.name) = $exampleTestCases
                }
            }    
            
        

        $extractTestCase = {
            $testPassInfo = $_
            $c = 0
            if ($TestPassInfo.Key -eq "ScriptCop") {
                New-Object PSObject -Property @{
                    TestPass = $TestPassInfo.Key
                    TestCase = "ScriptCop"
                    ScriptBlock = [ScriptBlock]::Create("Get-Module $Name | Test-Command -Rule '$($_.Value -join "','")'")
                    Data = @(@{})
                }
                return
            }  
            foreach ($v in $_.Value) {
                $C++
                if ($exampleDict["$v"]) {
                    New-Object PSObject -Property @{
                        TestPass = $TestPassInfo.Key
                        TestCase = "$v"
                        ScriptBlock = [ScriptBlock]::Create($exampleDict["$v"])
                        Data = @(@{})
                    }  
                } else {
                    Get-ChildItem -Recurse -Path $moduleRoot |
                        ForEach-Object {
                            $relativePath = $_.FullName.Replace($moduleRoot, "").TrimStart("\")
                            if ($_.Name -like "*.walkthru.help.txt" -and $_.Name -ireplace "\.walkthru\.help\.txt" -eq "$v".Replace(" ", "_")) {
                                New-Object PSObject -Property @{
                                    TestPass = $testPassInfo.Key
                                    TestCase = $_.Name -ireplace "\.walkthru\.help\.txt" -ireplace "_", " "            
                                    ScriptBlock = [ScriptBlock]::Create([IO.File]::ReadAllText($_.FullName))
                                    Data = @(@{})
                                }
                                
                            } elseif ($_.Name -like "*.demo.ps1" -and $_.Name -ireplace "\.demo\.ps1" -eq "$v".Replace(" ", "_")) {
                                New-Object PSObject -Property @{
                                    TestPass = $testPassInfo.Key
                                    TestCase = $_.Name -ireplace "\.demo\.ps1" -ireplace "_", " "            
                                    ScriptBlock = [ScriptBlock]::Create([IO.File]::ReadAllText($_.FullName))
                                    Data = @(@{})
                                }
                            } elseif ($_.Name -like "*.test.ps1" -and $relativePath -like "*$v*") {
                                
                                New-Object PSObject -Property @{
                                    TestPass = $testPassInfo.Key
                                    TestCase = $_.Name -ireplace "\.test\.ps1" -ireplace "_", " "            
                                    ScriptBlock = [ScriptBlock]::Create([IO.File]::ReadAllText($_.FullName))
                                    Data = @(@{})
                                }
                            }
                        }
                }
            }
            
        }

        $theTestCases = 
            @(if ($TestCase) {
                $scriptTestPass.GetEnumerator() |
                    Where-Object {
                        (-not $TestPass -or 
                        $TestPass -contains $_.Key) -and $TestPass -ne 'TestData'
                    } |
                    ForEach-Object $extractTestCase |
                    Where-Object {
                        $TestCase -contains $_.TestCase
                    }
            } else {
                $scriptTestPass.GetEnumerator() |
                    Where-Object {
                        (-not $TestPass -or 
                        $TestPass -contains $_.Key) -and $TestPass -ne 'TestData'
                    } | 
                    ForEach-Object $extractTestCase
            })
                
            



        $c = 0
        foreach ($testCaseInfo in $theTestCases) {
            $perc = $c * 100 / $theTestCases.Count
            Write-Progress "Running Tests - $($testCaseInfo.TestPass)" "$($TestCaseInfo.TestCase)" -PercentComplete $perc
            $c++
            $testOutput = @(try {
                & $testCaseInfo.ScriptBlock 2>&1
            } catch {
                $_
            })

            $errorList = @(if ($testCaseInfo.testPass -ne 'ScriptCop') {
                if ($testOutput | ?{ $_ -is [Management.Automation.ErrorRecord]}) {
                    $testOutput | ? {$_ -is  [Management.Automation.ErrorRecord]}
                } elseif ($testOutput | ?{ $_ -is [Exception]}) {
                    $testOutput | ? {$_ -is  [Exception]}
                }

            } else {
                $testOutput | ? {$_ -isnot [Management.Automation.ErrorRecord]}
            })

            
            $testCaseOutput = New-Object PSObject -Property @{
                Passed = $errorList.Count -eq 0  
                Errors = $errorList
                Output = $testOutput
                TestPass = $testCaseInfo.TestPass
                TestCase= $testCaseInfo.TestCase
            }
            $testCaseOutput.pstypenames.clear()
            $testCaseOutput.pstypenames.add('ScriptCop.Test.Output')
            $testCaseOutput
        }

    }
} 
